import argv
import gleam/bool
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamyshell
import html_lustre_converter
import javascript_dom_parser/deno_polyfill
import lucide_lustre/internal/config
import simplifile

@internal
pub fn install_single(icon_name: String, config: config.Config) {
  io.println("Cloning " <> icon_name <> " locally...")

  let download_path = "lucide_lustre_download"
  let icons_file_path = "./src/" <> config.output_module <> ".gleam"

  deno_polyfill.install_polyfill()

  let file = case simplifile.read(icons_file_path) {
    Ok(file) -> file
    Error(_) -> {
      let _ =
        simplifile.write(
          icons_file_path,
          "import lustre/attribute.{type Attribute, attribute}
import lustre/element/svg",
        )

      "import lustre/attribute.{type Attribute, attribute}
import lustre/element/svg"
    }
  }

  let name = case icon_name {
    // Replace icons with the names of keywords as their names with an underscore at the end
    "type" -> "type_"
    "import" -> "import_"
    _ ->
      icon_name
      |> string.replace("-", "_")
  }

  use <- bool.guard(
    case string.contains(file, "pub fn " <> name) {
      True -> {
        io.println("Icon " <> icon_name <> " is already installed")
        True
      }
      False -> False
    },
    Error(Nil),
  )

  let _ =
    gleamyshell.execute("curl", in: ".", args: [
      "-o",
      download_path,
      "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/"
        <> string.replace(icon_name, "_", "-")
        <> ".svg",
    ])
  let assert Ok(svg) = simplifile.read(download_path)

  use <- bool.guard(
    case string.contains(svg, "404: Not Found") {
      True -> {
        let assert Ok(_) =
          gleamyshell.execute("rm", in: ".", args: [download_path])
        io.println("Icon " <> icon_name <> " doesn't exist")
        True
      }
      False -> False
    },
    Error(Nil),
  )

  let function =
    "pub fn "
    <> name
    <> "(attributes: List(Attribute(a))) {"
    <> html_lustre_converter.convert(svg)
    <> "}"

  io.println(
    "Writing " <> icon_name <> " to " <> config.output_module <> ".gleam...",
  )

  let _ =
    simplifile.write(
      icons_file_path,
      file
        <> "\n"
        <> string.replace(
        function,
        "attribute(\"xmlns\", \"http://www.w3.org/2000/svg\"),",
        "..attributes",
      ),
    )

  io.println("Removing cloned icon...")

  let assert Ok(_) = gleamyshell.execute("rm", in: ".", args: [download_path])

  io.println("Formatting gleam code...")

  let assert Ok(_) = gleamyshell.execute("gleam", in: ".", args: ["format"])

  io.println("Finished generating " <> icon_name)

  Ok("")
}
