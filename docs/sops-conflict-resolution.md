# Resolving sops Conflicts

`modules/sops/secrets.yaml` (and any other sops-encrypted file) re-encrypts
the **entire file** with fresh nonces every time it's saved, even if only
one key changed. Two independent edits to the file will conflict on lines
that are semantically unrelated, and the ciphertext itself is useless for
figuring out what actually changed — you can't tell by looking whether two
ENC blobs encrypt the same plaintext or something completely different.

Never hand-merge ciphertext or pick a side by guessing. Decrypt both sides
to plaintext, diff _that_, merge by hand, then re-encrypt fresh as one
clean write.

## Steps

1. **Get both sides' full file content** at their respective revisions.

   jj:

   ```
   jj file show -r <revision> modules/sops/secrets.yaml > /tmp/side-a.yaml
   jj file show -r <revision> modules/sops/secrets.yaml > /tmp/side-b.yaml
   ```

   git:

   ```
   git show <rev>:modules/sops/secrets.yaml > /tmp/side-a.yaml
   git show <rev>:modules/sops/secrets.yaml > /tmp/side-b.yaml
   ```

2. **Decrypt both to plaintext:**

   ```
   sops -d /tmp/side-a.yaml > /tmp/plain-a.yaml
   sops -d /tmp/side-b.yaml > /tmp/plain-b.yaml
   ```

3. **Diff the plaintext** — this is the real, readable diff:

   ```
   diff -u /tmp/plain-a.yaml /tmp/plain-b.yaml
   ```

   Anything that differs, figure out _why_ (stale branch vs. intentional
   change, rotated credential, etc.) before deciding what to keep.

4. **Build the merged plaintext** by hand (copy one side, apply the pieces
   of the other side you want to keep).

5. **Write the merged plaintext to the real path and re-encrypt in place:**

   ```
   cp /tmp/plain-merged.yaml modules/sops/secrets.yaml
   sops -e -i modules/sops/secrets.yaml
   ```

   `sops -e -i` picks up the right key groups from `.sops.yaml` based on
   the file's path, so it must be encrypted at the real repo path, not a
   scratch path.

6. **Verify** the re-encrypted file round-trips to exactly the merged
   plaintext you intended:

   ```
   sops -d modules/sops/secrets.yaml | diff /tmp/plain-merged.yaml -
   ```

7. **Clean up** every plaintext scratch file (`/tmp/side-*.yaml`,
   `/tmp/plain-*.yaml`) — they contain decrypted secrets.

8. Confirm the VCS conflict is actually cleared (`jj status` / `git status`
   should no longer show the file as conflicted).

## Why this always works

The conflict only exists at the ciphertext/byte level. At the plaintext
level it's almost always either (a) truly identical values that just
re-encrypted differently, or (b) two non-overlapping additions/edits that
a normal 3-way text merge would have handled fine if sops didn't obscure
the content. Decrypting first turns an unreadable conflict into an
ordinary YAML diff.
