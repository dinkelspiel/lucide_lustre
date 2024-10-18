# lucide_lustre

[![Package Version](https://img.shields.io/hexpm/v/lucide_lustre)](https://hex.pm/packages/lucide_lustre)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lucide_lustre/)

```sh
gleam add --dev lucide_lustre@2
```

```sh
gleam run -m lucide_lustre/add library # Library can be replaced with any lucide icon
```

Or if you still want to install all icons

```sh
gleam run -m lucide_lustre/add_all
```

```gleam
import lucide_lustre.{library}
import lustre/element/html.{div}
import lustre/attribute.{class}

pub fn main() {
  div([], [
    library([class("size-4")])
  ])
}
```

Further documentation can be found at <https://hexdocs.pm/lucide_lustre>.

## Change output module

Configuration can be made in either the arguments

```sh
gleam run -m lucide_lustre/add [icon_name] {output_module}
gleam run -m lucide_lustre/add_all {output_module}
```

or statically in the `gleam.toml`

```toml
[lucide_lustre]
output_module = "lucide_lustre"
```
