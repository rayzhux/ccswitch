# ccswitch

Switch between multiple Claude Code accounts on macOS without manual logout/login.

Useful when you share a machine, hit the 5-hour usage window, or juggle personal/work/family accounts. No plaintext secrets on disk, no self-updater, ~100 lines of auditable shell + Swift.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/rayzhux/ccswitch/main/install.sh | sh
```

Or read before running (recommended):

```sh
git clone https://github.com/rayzhux/ccswitch
cd ccswitch
./install.sh
```

Requires macOS, [`jq`](https://stedolan.github.io/jq/) (`brew install jq`), and Xcode Command Line Tools (`xcode-select --install`).

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

Recommended aliases in `~/.zshrc`:

```zsh
alias ccr='ccswitch use raymond && claude'
alias cck='ccswitch use karen   && claude'
alias ccw='ccswitch current'
alias ccl='ccswitch list'
```

## How it works

Claude Code on macOS stores its OAuth token in the Keychain (service `Claude Code-credentials`) and account metadata in `~/.claude.json`. `ccswitch` snapshots both per profile and swaps them atomically:

- OAuth tokens stay in Keychain under `ccswitch:<name>`; never written to disk in plaintext.
- Tokens are passed to the Keychain helper via **stdin**, never argv, so they're invisible to `ps`.
- `~/.claude.json` is merged (only `oauthAccount` + `userID`), not overwritten — project history and global settings are preserved.
- Refuses to run while `claude` is running, to avoid racing its writes.
- Backs up `~/.claude.json` before each swap and rolls back on failure.
- Uses `flock` to prevent concurrent `ccswitch` invocations.

## Security notes

- Threat model: a trusted personal Mac, single macOS user account. Not designed for shared/multi-tenant machines.
- Profiles are device-local (Keychain is not synced across Macs by design). Run setup on each Mac separately.
- The first time a profile is used, macOS will prompt to allow Keychain access for `ccswitch-keychain` — click **Always Allow**.
- Uninstall: `./uninstall.sh` (removes binaries; see script output for wiping profile data).

## Files

- `bin/ccswitch` — the zsh CLI (~100 lines).
- `src/ccswitch-keychain.swift` — tiny Swift helper using Security.framework; compiled at install time.
- `install.sh` / `uninstall.sh` — self-contained installer.

## License

[MIT](./LICENSE)
