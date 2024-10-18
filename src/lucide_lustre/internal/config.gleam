import argv
import gleam/io
import gleam/string
import simplifile
import tom

pub type Config {
  Config(output_module: String, output_type: OutputType)
}

pub type OutputType {
  Single
  Multiple
}

pub fn get_config(ignore_first_arg: Bool) -> Config {
  let assert Ok(gleam_toml_raw) = simplifile.read("./gleam.toml")
  let assert Ok(gleam_toml) = tom.parse(gleam_toml_raw)

  let static_output_module =
    tom.get_string(gleam_toml, ["lucide_lustre", "output_module"])
  let static_output_type =
    tom.get_string(gleam_toml, ["lucide_lustre", "output_type"])

  let args = argv.load().arguments

  let arg_output_module = case ignore_first_arg {
    True ->
      case args {
        [_, output_module, ..] -> Ok(output_module)
        _ -> Error(Nil)
      }
    False ->
      case args {
        [output_module, ..] -> Ok(output_module)
        _ -> Error(Nil)
      }
  }
  let arg_output_type = case ignore_first_arg {
    True ->
      case args {
        [_, _, output_type, ..] -> Ok(output_type)
        _ -> Error(Nil)
      }
    False ->
      case args {
        [_, output_type, ..] -> Ok(output_type)
        _ -> Error(Nil)
      }
  }

  Config(
    output_module: case arg_output_module {
      Ok(output_module) -> output_module
      Error(_) ->
        case static_output_module {
          Ok(output_module) -> output_module
          Error(_) -> "lucide_lustre"
        }
    },
    output_type: output_type_to_type(case arg_output_type {
      Ok(output_type) -> output_type
      Error(_) ->
        case static_output_type {
          Ok(output_type) -> output_type
          Error(_) -> "single"
        }
    }),
  )
}

fn output_type_to_type(output_type: String) {
  case string.lowercase(output_type) {
    "single" -> Single
    "multiple" -> Multiple
    _ -> {
      io.println(
        "Invalid output_type found "
        <> output_type
        <> " expected, single or multiple",
      )
      panic
    }
  }
}
