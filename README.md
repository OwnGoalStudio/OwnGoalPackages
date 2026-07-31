# OwnGoal Packages

Flat APT repository for OwnGoal Studio iOS packages.

## Repository URL

Use the GitHub Pages repository URL:

```text
https://apt.owngoal.dev/
```

The equivalent APT source entry for the unsigned repository is:

```text
deb [trusted=yes] https://apt.owngoal.dev/ ./
```

## Add a package

1. Copy each `.deb` file into `debs/`.
2. Commit and push the `.deb` file to `main`.
3. The `Build and Deploy APT Repository` workflow reads the package control
   metadata, builds the complete repository in `_site/`, and deploys that build
   artifact directly to GitHub Pages.

The tracked files in `debs/` are the single source of truth. `Packages`,
`Packages.bz2`, the other compressed indexes, and `Release` are generated during
the build and are intentionally excluded from Git.

For local generation, install `apt-utils`, `bzip2`, `xz-utils`, and `zstd` on
Debian or Ubuntu, then run `./scripts/update-repository.sh`. The complete site is
written to the ignored `_site/` directory.

Signed releases can be created with
`./scripts/sign-repository.sh <GPG_KEY_ID>` after a local build.

Rebuilding `_site/` removes existing signatures because every metadata change
requires a fresh signature.

## Sileo metadata

Sileo reads repository information from files at the repository root:

- `CydiaIcon.png` is the repository icon.
- `_site/Release` provides the repository name, description, and supported
  architectures.
- `_site/Packages` provides each package name, category, icon, and depiction.

Every package control file must include `Section`. Sileo uses that value to build
software categories. See [`debs/README.md`](debs/README.md) for the supported
package fields.
