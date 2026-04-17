# ccswitch

Switch between multiple Claude Code accounts on macOS without manual logout/login.

Useful when you share a machine, hit the 5-hour usage window, or juggle personal/work/family accounts. No plaintext secrets on disk, no self-updater, ~100 lines of auditable shell + Swift.

## Install

Pinned to the latest release (recommended — immutable, no CDN-cache surprises):

```sh
curl -fsSL https://raw.githubusercontent.com/rayzhux/ccswitch/v0.2.1/install.sh | sh
```

Or from a local clone (read before running):

```sh
git clone https://github.com/rayzhux/ccswitch
cd ccswitch
./install.sh
```

Requires macOS and [`jq`](https://stedolan.github.io/jq/) (`brew install jq`).

## Usage

One-time setup per account (Claude Code must be stopped):

```sh
claude                          # log in as account #1
ccswitch save raymond

claude logout && claude         # log in as account #2
ccswitch save karen
```

Daily:

```sh
ccswitch use raymond && claude
ccswitch use karen   && claude
ccswitch current                # show active email
ccswitch list                   # all profiles
```

Recommended aliases in `~/.zshrc` — one per account, plus two helpers:

```zsh
# one alias per profile: cc<letter>='ccswitch use <name> && claude'
alias ccr='ccswitch use raymond && claude'
alias cck='ccswitch use karen   && claude'
alias cc3='ccswitch use mom     && claude'
alias cc4='ccswitch use dad     && claude'

# helpers
alias ccw='ccswitch current'    # who am I right now?
alias ccl='ccswitch list'       # all profiles; active marked with *
```

Reload with `source ~/.zshrc` (or open a new terminal). Then `ccr` / `cck` / `cc3` / `cc4` each swap the login and launch `claude` in one keystroke.

**Naming convention.** The profile name (`raymond`, `karen`, `mom`, `dad`) must match what you used with `ccswitch save <name>`. The alias prefix (`cc…`) is arbitrary — pick whatever your muscle memory likes. Some people prefer initials (`ccr`/`cck`/`ccm`/`ccd`); numeric suffixes (`cc1`..`cc4`) stay stable if names change later.

Adding a 5th account later is the same pattern: `ccswitch save <name>` once, add one alias line, `source ~/.zshrc`.

## How it works

Claude Code on macOS stores its OAuth token in the Keychain (service `Claude Code-credentials`) and account metadata in `~/.claude.json`. `ccswitch` snapshots both per profile and swaps them atomically:

- OAuth tokens stay in Keychain under `ccswitch:<name>`; never written to disk in plaintext.
- Tokens are piped into the Apple-signed `security` CLI via `security -i`, so they never appear in any process `argv` (invisible to `ps`).
- `~/.claude.json` is merged (only `oauthAccount` + `userID`), not overwritten — project history and global settings are preserved.
- Refuses to run while `claude` is running, to avoid racing its writes.
- Backs up `~/.claude.json` before each swap and rolls back on failure.
- Uses a `mkdir`-based lock to prevent concurrent `ccswitch` invocations.

## Security notes

- Threat model: a trusted personal Mac, single macOS user account. Not designed for shared/multi-tenant machines.
- Profiles are device-local (Keychain is not synced across Macs by design). Run setup on each Mac separately.
- The first time a profile is read, macOS will prompt to allow Keychain access for `security` — click **Always Allow**. Because `security` is Apple-signed, this grant persists across ccswitch upgrades.
- Uninstall: `./uninstall.sh --purge` wipes binaries, snapshots, and per-profile keychain entries. Plain `./uninstall.sh` removes only the binary.

## Files

- `bin/ccswitch` — the zsh CLI (~120 lines, pure shell).
- `install.sh` / `uninstall.sh` — self-contained installer.

## License

[MIT](./LICENSE)
