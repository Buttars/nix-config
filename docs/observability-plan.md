# Observability Plan: VictoriaLogs + Prometheus on Oculus

## Overview

Centralize logs, metrics, and alerting for the fleet on a dedicated Proxmox VM
(`oculus`). Every NixOS host ships journald logs and node metrics to it; `oculus`
stores, queries, and alerts.

A dedicated host rather than co-locating on `sentinel`: sentinel is the machine
whose config changes most often, and observability is most valuable in the
minutes after a change breaks something. A stack living on the broken host is
unavailable exactly when it is needed.

## Current State

| Concern         | Coverage today                        | Gap                                      |
| --------------- | ------------------------------------- | ---------------------------------------- |
| External uptime | `gatus` on sentinel, 15 endpoints     | Dies with sentinel                       |
| Backups         | `restic` → B2, 4 paths                | No alert on failure                      |
| Logs            | journald, per-host, default retention | No aggregation, no cross-host search     |
| Metrics         | none                                  | No resource history, no capacity warning |
| Alerting        | none                                  | Failures are discovered by noticing them |

Every host is NixOS and every service logs to journald, so collection is uniform
and no per-service file tailing is needed. The exceptions are noted under
[Non-NixOS hosts](#non-nixos-hosts).

## Prerequisites

- [ ] Create Proxmox VM: 2 vCPU, 4 GB RAM, 40 GB disk, `ens18`
- [ ] Assign a **static DHCP lease** — the IP is the fallback access path
- [ ] Install NixOS, generate `facter.json`
- [ ] Enroll host age key in sops
- [ ] Add `private_keys/oculus` and reuse `buttars-password` in `modules/app/sops/secrets.yaml`
- [ ] Decide alert destination (see [Open Questions](#open-questions))

## Architecture decisions

| Concern    | Choice       | Why                                                                                                      |
| ---------- | ------------ | -------------------------------------------------------------------------------------------------------- |
| Log store  | VictoriaLogs | Single binary, no object store or index sharding. Much lighter than Loki on a small VM.                  |
| Metrics    | Prometheus   | At ten hosts the scale case for VictoriaMetrics does not apply; `exporters.*` is mature and declarative. |
| Shipper    | Vector       | `services.vector.settings` is a real Nix attrset. Alloy's module is enable-plus-a-config-file (River).   |
| Dashboards | Grafana      | Reads both stores. Datasources and dashboards provisioned from Nix.                                      |
| Alerting   | Alertmanager | Packaged, with an `alertmanager-ntfy` bridge available.                                                  |
| Tracing    | none         | Earns its complexity only for services you instrument. You run packaged software.                        |

> **`services.promtail` does not exist in this repo's nixpkgs.** Grafana has
> end-of-lifed Promtail in favour of Alloy, so the conventional Loki + Promtail
> recipe fails at evaluation. Verified present: `victorialogs`, `victoriametrics`,
> `prometheus` (with `exporters` and `alertmanager`), `grafana`, `vector`,
> `alloy`, `ntfy-sh`.

## Implementation

### 1. New host (`modules/hosts/oculus/`)

Model on `modules/hosts/aegis/` — the closest existing shape and also a Proxmox
guest.

```
modules/hosts/oculus/
├── default.nix     # includes: networking, sops, telemetry, observability
├── _disko.nix      # copy from aegis, /dev/sda, btrfs
└── facter.json     # nixos-facter, generated on first boot
```

```nix
den.aspects.oculus = {
  includes = [
    <den/define-user>
    <aegix/networking>
    <aegix/sops>
    <aegix/telemetry>       # oculus monitors itself
    <aegix/observability>
  ];
};
```

### 2. Telemetry capability — every host

`modules/capability/telemetry.nix` composes two apps and goes into the default
includes in `modules/defaults.nix`, so new hosts are instrumented on creation.

```nix
# modules/app/node-exporter.nix
services.prometheus.exporters.node = {
  enable = true;
  enabledCollectors = [ "systemd" "processes" ];
  openFirewall = true;
};
```

```nix
# modules/app/vector.nix
services.vector = {
  enable = true;
  journaldAccess = true;
  settings = {
    sources.journal = {
      type = "journald";
      current_boot_only = false;
    };
    sinks.victorialogs = {
      type = "loki";
      inputs = [ "journal" ];
      # VictoriaLogs exposes a Loki-compatible push endpoint on 9428.
      # Verify the path on first deploy.
      endpoint = "http://oculus.lan:9428/insert/loki/api/v1/push";
      encoding.codec = "json";
      labels = {
        host = "{{ host }}";
        unit = "{{ _SYSTEMD_UNIT }}";
      };
    };
  };
};
```

The aggregator endpoint should be a host-level option rather than a hardcoded
address, so `buttars-laptop` can point elsewhere (or nowhere) when off-network.

### 3. Observability capability — oculus only

`modules/capability/observability.nix` includes `victorialogs`, `prometheus`,
`grafana`, and `alertmanager`. Grafana's admin password comes from sops, not
from the module default.

Prometheus scrapes node-exporter on every host plus its own exporters:

```nix
services.prometheus = {
  enable = true;
  scrapeConfigs = [
    {
      job_name = "nodes";
      static_configs = [{
        targets = [
          "sentinel.lan:9100"
          "aegis.lan:9100"
          "torrens.lan:9100"
          "theatrum.lan:9100"
          "buttars-desktop.lan:9100"
          "oculus.lan:9100"
        ];
      }];
    }
  ];
};
```

### 4. Reachability without sentinel

**This is the part that makes the separate host worth building.** Sentinel runs
_both_ the internal DNS (dnsmasq answering `*.buttars.dev` → 10.0.40.6) _and_ the
internal reverse proxy. Reaching Grafana through that path means a sentinel
outage leaves a healthy monitoring host you cannot open.

Three measures, in order of importance:

1. **Static IP, memorized.** `http://10.0.40.x:3000` must work with sentinel
   powered off. Everything else is convenience layered on top.
2. **Caddy on `oculus`.** Terminate TLS locally rather than proxying through
   sentinel. One self-contained vhost.
3. **Secondary dnsmasq on `oculus`.** A few hundred kilobytes, and internal name
   resolution stops depending on one machine. This fixes a SPOF well beyond
   observability — today a sentinel outage takes DNS down for the whole network.

Also **move `gatus` from sentinel to `oculus`**. It is uptime monitoring living
on the host most likely to be the thing that is down.

### 5. Alert rules

Start deliberately small. An alerting system you have learned to ignore is worse
than none.

| Alert               | Condition                                         | Why                                                  |
| ------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| `DiskFillingUp`     | fs usage > 85%                                    | Would have caught the 96% root before it broke rsync |
| `HostDown`          | `up == 0` for 5m                                  | Basic liveness                                       |
| `SystemdUnitFailed` | `node_systemd_unit_state{state="failed"}`         | Catches silent service death                         |
| `NFSMountStale`     | mount missing or I/O erroring on a `veritas` path | Stale NFS is a top failure mode here                 |
| `BackupFailed`      | restic timer last-run non-zero                    | Backups currently fail silently                      |
| `CertExpiringSoon`  | < 14 days                                         | Caddy renews, but confirm it did                     |
| `DeadMansSwitch`    | always firing → external heartbeat                | See below                                            |

**External dead-man's switch.** `oculus` can also fail, and if it and sentinel
share a Proxmox node a hypervisor failure takes out both. Alertmanager should
heartbeat an external endpoint (healthchecks.io free tier) that alerts when the
pings stop. This is the only mechanism that survives the whole rack going down.

## Non-NixOS hosts

`truenas.lan` serves `/mnt/veritas/services/*` and `/mnt/veritas/cognito` over
NFS to sentinel, torrens, and theatrum. It holds all service data, which makes it
the most critical host in the fleet — and it cannot run the telemetry capability.

- **Metrics:** TrueNAS SCALE can export to a remote Graphite/Prometheus target.
  Configure it to push to `oculus`.
- **Logs:** TrueNAS can forward syslog to a remote host. Vector on `oculus` can
  accept a `syslog` source and feed the same VictoriaLogs sink.
- **Failing that**, blackbox-only via gatus plus the `NFSMountStale` alert on
  the consuming hosts — which catches the failure that actually matters.

Container logs need per-host handling:

| Host              | Runtime | Approach                                         |
| ----------------- | ------- | ------------------------------------------------ |
| `buttars-desktop` | docker  | Set log driver to `journald`; Vector picks it up |
| `torrens`         | podman  | Same — podman supports the journald driver       |

## Retention Policy

Estimates, not measurements. Revise after a week of real data.

| Component     | Retention | Est. RAM | Est. disk   |
| ------------- | --------- | -------- | ----------- |
| VictoriaLogs  | 30d       | ~150 MB  | 2–5 GB      |
| Prometheus    | 90d       | ~400 MB  | 1–3 GB      |
| Grafana       | —         | ~120 MB  | < 100 MB    |
| Vector (each) | —         | ~60 MB   | buffer only |

The `*arr` stack and immich are the chatty ones. If log volume surprises you,
drop their level at the Vector filter rather than shortening global retention.

## What's NOT collected (intentionally)

- **Traces.** See architecture decisions.
- **Workstation session logs.** Hyprland, portals, and desktop noise are high
  volume and low value. If `buttars-laptop` ships at all, filter to system units.
- **Metrics from `specula` / `DRHCDGTHGJ`.** Minimal hosts; add later if wanted.

Exclude all observability data from restic. It is derived, high-churn, and
worthless once aged out — backing it up inflates the B2 bill to protect data you
would never restore. Dashboards and alert rules live in this repo, which is the
part that matters.

## Phases

Ordered by dependency. Each is independently useful.

- [ ] **Phase 1 — Metrics.** `oculus` VM, node-exporter fleet-wide, Prometheus +
      Grafana, stock Node Exporter Full dashboard. Largest payoff per unit work.
- [ ] **Phase 2 — Logs.** VictoriaLogs on `oculus`, Vector in the telemetry
      capability, container log drivers, Grafana datasource.
- [ ] **Phase 3 — Alerting.** Alertmanager + ntfy, the seven rules above, the
      external dead-man's switch. Move `gatus` here.
- [ ] **Phase 4 — Depth.** Per-service exporters (Caddy already exposes metrics;
      exporters exist for qBittorrent, Jellyfin, the `*arr` stack). TrueNAS
      integration. Log-derived metrics. Treat as a backlog, not a milestone.

## Open Questions

- [ ] Host name — `oculus` throughout this document. `custos` and `memoria` also
      fit the existing naming. Avoid `speculum`, too close to `specula`.
- [ ] Alert destination — self-hosted ntfy, hosted ntfy.sh, or home-assistant?
      Note that routing through home-assistant reintroduces a sentinel
      dependency in the alerting path.
- [ ] Do workstations ship logs, or servers only? Laptops roam and need a
      buffering/offline story the servers do not.
- [ ] Secondary dnsmasq on `oculus` — in scope, or separate work?
- [ ] Retention appetite — 30d/90d is a guess at what you would actually consult.
