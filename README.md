# nixos-config

bloq's NixOS machines, as one flake. Each machine gets a **role** (dev, prod or
personal) on top of a shared base. [deploy-rs](https://github.com/serokell/deploy-rs)
pushes configs to machines and [sops-nix](https://github.com/Mic92/sops-nix)
handles secrets.

## Layout

```
flake.nix                    inputs, the host table, mkHost, deploy-rs nodes, checks
.sops.yaml                   which age keys can decrypt which secrets files
modules/common.nix           every machine: user bloq + SSH key, openssh, firewall,
                             nix flakes, timezone, base CLI tools, sops-nix
roles/dev.nix                dev toolchain (C/C++, neovim tools, nodejs, claude-code, ...)
roles/prod.nix               lean hardened server baseline; services go here
roles/personal.nix           personal machines (no hosts use it yet)
hosts/<name>/default.nix     per-machine settings: network, stateVersion
hosts/<name>/hardware-configuration.nix
hosts/placeholder-hardware.nix   stand-in for machines not yet installed
```

| Host  | Role | Address        | Hardware |
|-------|------|----------------|----------|
| dev1  | dev  | 192.168.1.77   | Proxmox VM (real hardware config) |
| dev2  | dev  | TODO           | placeholder |
| prod1 | prod | TODO           | placeholder |
| prod2 | prod | TODO           | placeholder |

dev1 is the machine that used to be called `nixos`.

**Before deploying to dev2, prod1 or prod2**, replace its
`hosts/<name>/hardware-configuration.nix` with the output of
`nixos-generate-config --show-hardware-config` from that machine, set its network
config in `hosts/<name>/default.nix`, and put its real address in the `hosts`
table in `flake.nix`. The placeholder hardware only exists so the flake evaluates;
deploying it would leave the machine unbootable.

## Adding a host

1. Add one line to the `hosts` table in `flake.nix`:
   ```nix
   prod3 = { role = "prod"; address = "203.0.113.10"; };
   ```
2. Create `hosts/prod3/default.nix` (copy one of the existing ones) and
   `hosts/prod3/hardware-configuration.nix` (from `nixos-generate-config` on the
   machine).
3. `git add` the new files (flakes only see tracked files) and run `nix flake check`.

The host's `networking.hostName` defaults to its name in the table, and it gets both
a `nixosConfigurations.<name>` and a `deploy.nodes.<name>` entry.

## Deploying

The target machine must already run NixOS with user `bloq` and its SSH key (install
it by hand or with nixos-anywhere first). deploy-rs connects as `bloq` and uses
`sudo` to activate as root; it prompts for bloq's sudo password.

```sh
nix run github:serokell/deploy-rs -- .#dev1        # one host
nix run github:serokell/deploy-rs -- .             # every host
```

deploy-rs runs `nix flake check` first and rolls back automatically if the new
config breaks the SSH connection. To build without deploying:

```sh
nix build .#nixosConfigurations.dev1.config.system.build.toplevel
```

Locally on a machine, `sudo nixos-rebuild switch --flake .#dev1` still works.

## Secrets (sops-nix)

Secrets are encrypted in the repo with [sops](https://github.com/getsops/sops) and
decrypted on each machine at activation, using that machine's SSH host key converted
to an age key. No secrets are committed yet.

1. **Your admin key** (to edit secrets from your workstation):
   ```sh
   mkdir -p ~/.config/sops/age
   nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
   nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt   # prints age1...
   ```
2. **Each host's key**, from its SSH host key:
   ```sh
   ssh-keyscan -t ed25519 192.168.1.77 | nix shell nixpkgs#ssh-to-age -c ssh-to-age
   ```
3. Put those `age1...` values in `.sops.yaml`, uncomment the `creation_rules`, and
   create a secrets file:
   ```sh
   mkdir -p secrets
   nix shell nixpkgs#sops -c sops secrets/prod.yaml
   ```
4. Declare the secret in a role or host module:
   ```nix
   sops.secrets."db-password" = { sopsFile = ../secrets/prod.yaml; };
   # available on the machine at /run/secrets/db-password
   ```
5. After adding a host key to `.sops.yaml`, re-encrypt existing files for it:
   `nix shell nixpkgs#sops -c sops updatekeys secrets/prod.yaml`.

Never commit `~/.config/sops/age/keys.txt` or any unencrypted secret.
