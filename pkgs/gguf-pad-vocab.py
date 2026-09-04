#!@python@
import argparse
import shutil
import sys
from pathlib import Path

import gguf
from tqdm import tqdm

TOKENS = gguf.Keys.Tokenizer.LIST
SCORES = gguf.Keys.Tokenizer.SCORES
TOKEN_TYPE = gguf.Keys.Tokenizer.TOKEN_TYPE


def pad_values(key, start, stop):
    if key == TOKENS:
        return [f"[PAD{i}]" for i in range(start, stop)]
    if key == SCORES:
        return [-10000.0] * (stop - start)
    return [int(gguf.TokenType.UNUSED)] * (stop - start)


def main():
    ap = argparse.ArgumentParser(
        description="Pad a GGUF's tokenizer arrays up to its token embedding row count"
    )
    ap.add_argument("input", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--tensor", default="token_embd.weight")
    args = ap.parse_args()

    reader = gguf.GGUFReader(args.input, "r")

    tensor = next((t for t in reader.tensors if t.name == args.tensor), None)
    if tensor is None:
        sys.exit(f"{args.input}: no tensor named {args.tensor}")
    target = int(tensor.shape[-1])

    tokens = reader.get_field(TOKENS)
    if tokens is None:
        sys.exit(f"{args.input}: no {TOKENS}")
    have = len(tokens.data)

    if have == target:
        print(f"{args.input}: already consistent at {target} tokens", file=sys.stderr)
        shutil.copyfile(args.input, args.output)
        return
    if have > target:
        sys.exit(
            f"{args.input}: {TOKENS} has {have} entries but {args.tensor} only has "
            f"{target} rows; padding cannot fix a tokenizer that is too long"
        )

    print(f"{args.tensor} rows: {target}", file=sys.stderr)
    print(f"{TOKENS} entries: {have} (+{target - have})", file=sys.stderr)

    arch = reader.get_field(gguf.Keys.General.ARCHITECTURE).contents()
    writer = gguf.GGUFWriter(args.output, arch=arch, endianess=reader.endianess)

    alignment = reader.get_field(gguf.Keys.General.ALIGNMENT)
    if alignment is not None:
        writer.data_alignment = alignment.contents()

    for field in reader.fields.values():
        if field.name == gguf.Keys.General.ARCHITECTURE or field.name.startswith(
            "GGUF."
        ):
            continue
        value = field.contents()
        sub_type = (
            field.types[-1] if field.types[0] == gguf.GGUFValueType.ARRAY else None
        )
        if field.name in (TOKENS, SCORES, TOKEN_TYPE):
            if len(value) != have:
                sys.exit(
                    f"{args.input}: {field.name} has {len(value)} entries, expected {have}"
                )
            value = value + pad_values(field.name, have, target)
        writer.add_key_value(field.name, value, field.types[0], sub_type=sub_type)

    for tensor in reader.tensors:
        writer.add_tensor_info(
            tensor.name,
            tensor.data.shape,
            tensor.data.dtype,
            tensor.data.nbytes,
            tensor.tensor_type,
        )

    writer.write_header_to_file()
    writer.write_kv_data_to_file()
    writer.write_ti_data_to_file()

    bar = tqdm(
        desc="writing",
        total=sum(t.n_bytes for t in reader.tensors),
        unit="byte",
        unit_scale=True,
    )
    for tensor in reader.tensors:
        writer.write_tensor_data(tensor.data, tensor_endianess=reader.endianess)
        bar.update(tensor.n_bytes)
    writer.close()


if __name__ == "__main__":
    main()
