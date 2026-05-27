# jj Workflows

## Core Concepts

- The working copy _is_ the current change (`@`) — no staging step
- `jj new` finalizes the current change and starts a fresh one on top
- Changes are identified by immutable change IDs, not commit hashes
- Bookmarks are optional labels that map to git branches on push

## Starting Work

```bash
jj new master -m "feat(scope): description"   # new change off master
jj new -m "next piece"                         # new change off current @
```

## Checking State

```bash
jj log              # graph with @ marking your position
jj status           # files modified in @
jj diff             # content diff of @
jj diff --stat      # summary of changes
```

## Describing Changes

```bash
jj describe -m "new description"         # set/update description on @
jj describe @- -m "fix parent message"   # update parent's description
```

## Splitting a Change

Split the current change into two:

```bash
jj split <files>       # named files go to parent, rest stays in @
jj split               # interactive hunk selection (no args)
```

Move specific files into an existing change:

```bash
jj squash --into <change-id> <files>
```

## Combining Changes

```bash
jj squash             # merge @ into its parent
jj squash --into <id> # merge @ into a specific change
```

## Switching Between Changes

```bash
jj edit <change-id>    # move working copy to that change
jj edit <bookmark>     # if you've named it
```

## Parallel Lines of Work

```bash
jj new master -m "feature A"    # start feature A off master
# work...
jj new master -m "feature B"    # start feature B off master (independent)
```

Switch with `jj edit`. They share history up to master but are otherwise independent.

## Syncing with Upstream

```bash
jj git fetch                        # pull latest from all remotes
jj rebase -d master                 # rebase current change onto updated master
jj rebase -s <root> -d master      # rebase a whole stack
```

If master moved and you want to update your branch:

```bash
jj git fetch
jj rebase -d master
```

## Bookmarks (Branches)

```bash
jj bookmark set <name> -r @         # point bookmark at current change
jj bookmark set <name> -r <id>      # point at a specific change
jj bookmark list                     # list all bookmarks
jj bookmark delete <name>           # remove a bookmark
```

## Pushing

```bash
jj git push --bookmark <name>       # push a specific bookmark
jj git push --change @              # push current change (auto-creates bookmark)
jj git push --all                   # push all bookmarks
```

## Workflow: Push to Master (Personal Projects)

```bash
jj bookmark set master -r <change-id>
jj git push --bookmark master
```

## Workflow: Feature Branch for PR

```bash
jj new master -m "feat(scope): description"
# work...
jj bookmark set my-feature -r @
jj git push --bookmark my-feature
# open PR targeting master
```

## Abandoning Changes

```bash
jj abandon <change-id>    # remove a change from the graph
jj abandon @              # abandon current change
```

## Undoing Mistakes

```bash
jj undo                   # revert the last jj operation
jj op log                 # see operation history
jj op restore <op-id>    # restore to a specific operation
```

## Moving a Change Off the Stack

If you split out a change but want it independent (not a parent):

```bash
jj split <files>                  # extract into parent
jj rebase -r @- -d master        # move that parent to be a sibling off master
```

## Identity Configuration

```bash
jj config set --repo user.name "Name"
jj config set --repo user.email "email@example.com"
```
