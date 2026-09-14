# Network Topology

How names resolve, which host answers, and why a service can be healthy on the
LAN and return 502 from the internet.

## Segments

| Segment        | Holds                              |
| -------------- | ---------------------------------- |
| `10.0.20.0/24` | Workstations and laptops           |
| `10.0.30.0/24` | `veritas` — the proxmox hypervisor |
| `10.0.40.0/24` | Servers and storage                |
| `10.0.45.0/24` | `aegis` — the internet-facing edge |

| Host       | Address     | Role                                                                           |
| ---------- | ----------- | ------------------------------------------------------------------------------ |
| `truenas`  | `10.0.40.2` | ZFS storage, NFS exports                                                       |
| `theatrum` | `10.0.40.3` | jellyfin                                                                       |
| `torrens`  | `10.0.40.5` | the `*arr` stack, qbittorrent, gluetun                                         |
| `sentinel` | `10.0.40.6` | home-assistant, immich, nextcloud, dawarich, observability, dnsmasq, LAN caddy |
| `aegis`    | `10.0.45.2` | public reverse proxy, fail2ban                                                 |
| `veritas`  | `10.0.30.2` | proxmox host for the VMs above                                                 |

## Two caddy instances, two answers for one name

Every `*.buttars.dev` name resolves to a different address depending on where
the client is:

- **On the LAN**, dnsmasq on sentinel answers `*.buttars.dev` with `10.0.40.6`,
  so the request lands on **sentinel's caddy**, which proxies to services on
  loopback or to other hosts on `10.0.40.0/24`.
- **From the internet**, public DNS answers with the WAN address, which forwards
  to **aegis's caddy** on `10.0.45.2`.

The two have different vhost lists. Sentinel's covers everything; aegis's covers
only what is deliberately public.

**This is the single most confusing thing about the setup.** A service can
return 200 from your laptop and 502 from your phone on cellular, and both are
the truth about different paths. When something "works for me," establish which
caddy answered before anything else:

```bash
# LAN path
curl -o /dev/null -w '%{http_code}\n' https://<name>.buttars.dev
# public path, bypassing local dns
curl -o /dev/null -w '%{http_code}\n' --resolve <name>.buttars.dev:443:<wan-ip> https://<name>.buttars.dev
```

## Public services

Only what aegis has a vhost for is reachable from outside: `jellyfin`,
`requests`, `home`, `dawarich`, `nextcloud`, `immich`, `ntfy`. Everything else —
`grafana`, `gatus`, and the `*arr` apps — is LAN-only by design.

## The segment ACL

`10.0.45.0/24` is firewalled from `10.0.40.0/24` at the router, allowing only
specific ports. This is not visible from any NixOS config, and not from a
workstation either: a host on `10.0.20.0/24` can reach ports that aegis cannot.

That asymmetry is the trap. Testing from your laptop proves nothing about
whether aegis can reach the same service.

```bash
# from aegis, which is the only vantage point that matters for public services
ssh aegis@aegis.lan 'for p in 443 2586 8123; do
  timeout 3 bash -c "exec 3<>/dev/tcp/sentinel.lan/$p" 2>/dev/null \
    && echo "$p open" || echo "$p CLOSED"
done'
```

### Proxy through sentinel's caddy, not to raw ports

Aegis's vhosts should target **sentinel's caddy over 443**, not the service port:

```nix
viaCaddy = host: ''
  tls {
    protocols tls1.2 tls1.3
  }
  reverse_proxy https://sentinel.lan {
    header_up Host {host}
    transport http {
      tls
      tls_server_name ${host}
    }
  }
'';
```

Two reasons, both learned the hard way:

- **One router rule instead of one per service.** Exposing a new service
  otherwise means a new ACL entry every time, on a device the repo does not
  manage and nothing reminds you about.
- **It reaches services bound to loopback.** home-assistant listens on
  `127.0.0.1:8123`, so `reverse_proxy http://sentinel.lan:8123` can never
  connect from another host — sentinel's own caddy is the only thing that can
  reach it. `home.buttars.dev` was 502 publicly for an unknown length of time
  for exactly this reason, while working perfectly on the LAN.

`immich`, `nextcloud` and `dawarich` still use direct port proxies with their own
ACL entries. They work; converting them is tidy-up, not a fix.

## Failure signatures

| Symptom                               | Cause                                                   |
| ------------------------------------- | ------------------------------------------------------- |
| 200 on LAN, 502 public                | aegis cannot reach the upstream — ACL, or loopback bind |
| 502 on both                           | the service itself is down                              |
| Name resolves but nothing answers     | dnsmasq negative cache; `neg-ttl` is 30s                |
| Works, then fails after a host reboot | see [nfs-migration-plan.md](../nfs-migration-plan.md)   |

## DNS

dnsmasq on sentinel is authoritative for the LAN: `*.buttars.dev` → `10.0.40.6`,
plus `host-record` entries for each `*.lan` name, in
`modules/hosts/sentinel/default.nix`.

`neg-ttl = 30` is deliberate. The default negative cache remembers a name as
nonexistent for far longer, so a name looked up while its host was rebooting
stayed dead until the cache was flushed by hand — which is exactly what happened
with jellyfin.

Certificates come from Let's Encrypt over the cloudflare DNS-01 challenge, so no
name needs to be publicly reachable to get a valid certificate. A service can
have working TLS and still be unreachable from the internet.
