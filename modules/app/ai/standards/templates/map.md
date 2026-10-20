# <domain> — map

Where things live. The point is to replace exploration with a lookup, so prefer
exact paths over descriptions and keep entries short enough to scan.

Earn its length: a domain spread across five repos needs a long map, one
contained in a single tree needs a short one.

## Repos

| What                 | Where           | Notes                             |
| -------------------- | --------------- | --------------------------------- |
| <role in the domain> | `<path or url>` | <branch, worktree layout, gotcha> |

## Entry points

The files to open first for the most common tasks. Not an inventory — a shortlist.

| Task          | Start at |
| ------------- | -------- |
| <common task> | `<path>` |

## Runtime

Services, environments, dashboards, logs, runbooks. Where the thing actually
runs and how to see it.

| What                     | Where           |
| ------------------------ | --------------- |
| <environment or service> | `<url or path>` |

## Conventions

Naming, layout, or wiring rules that are consistent within this domain and would
otherwise have to be inferred from examples.

## Traps

Things that look wrong and are correct, or look correct and are wrong. Anything
that cost someone an hour belongs here.
