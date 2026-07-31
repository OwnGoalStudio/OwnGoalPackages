#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

required_commands=(apt-ftparchive gzip bzip2 xz zstd)
for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 69
  fi
done

work_dir="$(mktemp -d "$repository_root/.repo-build.XXXXXX")"
site_dir="$work_dir/site"
index_dir="$work_dir/indexes"
output_dir="$repository_root/_site"
mkdir -p "$site_dir" "$index_dir"
trap 'rm -rf -- "$work_dir"' EXIT

# Scan the tracked package pool and generate every repository index. Running from the
# repository root keeps each package Filename relative (debs/<package>.deb).
apt-ftparchive packages debs > "$index_dir/Packages"

awk '
  BEGIN {
    RS = ""
    FS = "\n"
  }

  {
    package = ""
    section = ""

    for (field = 1; field <= NF; field++) {
      if ($field ~ /^Package: /) {
        package = substr($field, 10)
      }

      if ($field ~ /^Section: /) {
        section = substr($field, 10)
      }
    }

    if (package != "" && section == "") {
      printf "Package %s is missing the Section field required by Sileo.\n", package > "/dev/stderr"
      exit 1
    }
  }
' "$index_dir/Packages"

gzip -9n -c "$index_dir/Packages" > "$index_dir/Packages.gz"
bzip2 -9c "$index_dir/Packages" > "$index_dir/Packages.bz2"
xz -9e -c "$index_dir/Packages" > "$index_dir/Packages.xz"
zstd -q -19 -c "$index_dir/Packages" > "$index_dir/Packages.zst"

# Keeping Release outside the scanned directory prevents a self-referential hash.
apt-ftparchive \
  -o APT::FTPArchive::Release::Origin="OwnGoal Studio" \
  -o APT::FTPArchive::Release::Label="OwnGoal Packages" \
  -o APT::FTPArchive::Release::Suite="stable" \
  -o APT::FTPArchive::Release::Version="1.0" \
  -o APT::FTPArchive::Release::Codename="owngoal" \
  -o APT::FTPArchive::Release::Architectures="iphoneos-arm iphoneos-arm64 iphoneos-arm64e" \
  -o APT::FTPArchive::Release::Components="main" \
  -o APT::FTPArchive::Release::Description="Official iOS packages from OwnGoal Studio" \
  release "$index_dir" > "$work_dir/Release"

# Assemble the complete Pages artifact only after all metadata has been generated.
cp -R assets "$site_dir/assets"
cp -R debs "$site_dir/debs"
cp CNAME CydiaIcon.png index.html "$site_dir/"
cp "$index_dir"/Packages "$index_dir"/Packages.* "$site_dir/"
cp "$work_dir/Release" "$site_dir/Release"

rm -rf -- "$output_dir"
mv "$site_dir" "$output_dir"

echo "Built APT repository at $output_dir"
