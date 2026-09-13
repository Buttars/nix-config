{ __findFile, ... }:
{
  # Everything a host needs in order to be observed. Log shipping joins this
  # once an aggregator exists to ship to.
  aegix.telemetry = {
    includes = [
      <aegix/node-exporter>
    ];
  };
}
