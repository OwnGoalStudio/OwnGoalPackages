# Package pool

Place distributable `.deb` files in this directory, then run:

```sh
./scripts/update-repository.sh
```

The generated `_site/Packages` index records paths relative to the published
repository root. Only the `.deb` inputs are tracked; all indexes are build
artifacts.

Each package must define the following fields in `DEBIAN/control`:

```debcontrol
Package: dev.owngoal.example
Name: Example Package
Version: 1.0.0
Architecture: iphoneos-arm64
Description: A short package description.
Maintainer: OwnGoal Studio <not-gonna-reply@owngoal.dev>
Author: OwnGoal Studio <not-gonna-reply@owngoal.dev>
Section: Tweaks
```

Sileo uses `Section` as the software category. Common values include
`Applications`, `Tweaks`, `Themes`, and `Utilities`.

The following optional fields enrich the package page:

```debcontrol
Icon: https://apt.owngoal.dev/icons/example.png
Depiction: https://apt.owngoal.dev/depictions/example/
SileoDepiction: https://apt.owngoal.dev/depictions/example/native.json
```

`Icon` points to the package artwork. `Depiction` provides a web depiction, and
`SileoDepiction` provides a native Sileo depiction.
