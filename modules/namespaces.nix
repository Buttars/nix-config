{ inputs, den, ... }:
{
  imports = [
    (inputs.den.namespace "hosts" false)
    (inputs.den.namespace "users" false)
    (inputs.den.namespace "shared" false)
  ];
}
