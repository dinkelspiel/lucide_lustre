import argv
import gleam/io
import lucide_lustre/internal/config
import lucide_lustre/internal/install_single

pub fn main() {
  let config = config.get_config(True)

  case argv.load().arguments {
    [icon_name, ..] -> {
      let _ = install_single.install_single(icon_name, config)
      Nil
    }
    _ ->
      io.println(
        "No icon name provided, usage: gleam run -m lucide_lustre/add [icon_name] {output_module default: lucide_lustre}",
      )
  }
}
