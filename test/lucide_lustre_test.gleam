import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamyshell
import globlin
import html_lustre_converter
import javascript_dom_parser/deno_polyfill
import simplifile

pub fn main() {
  io.println("Cloning icons locally...")

  let assert Ok(_) =
    gleamyshell.execute("git", in: ".", args: [
      "clone", "https://github.com/lucide-icons/lucide.git",
    ])

  deno_polyfill.install_polyfill()

  let assert Ok(pattern) = globlin.new_pattern("./lucide/icons/*.svg")
  let assert Ok(icons_folder) = simplifile.get_files("./lucide/icons")
  io.println("Deleting old icons...")
  let _ = simplifile.delete("./src/lucide_lustre.gleam")

  io.println("Generating new icons...")

  let _ =
    icons_folder
    |> list.filter(keeping: globlin.match_pattern(pattern:, path: _))
    |> list.map(fn(path) { #(path, simplifile.read(path)) })
    |> list.map(fn(file) {
      let assert Ok(svg) = file.1
      let name = case file.0 {
        // Replace icons with the names of keywords as their names with an underscore at the end
        "./lucide/icons/type.svg" -> "type_"
        "./lucide/icons/import.svg" -> "import_"
        "./lucide/icons/" <> path ->
          string.split(path, ".")
          |> list.first
          |> result.unwrap("")
          |> string.replace("-", "_")
        _ -> ""
      }

      "pub fn "
      <> name
      <> "(attributes: List(Attribute(a))) {"
      <> html_lustre_converter.convert(svg)
      <> "}"
    })
    |> string.join("\n")
    |> fn(contents) {
      io.println("Writing new icons to lucide_lustre.gleam...")

      simplifile.write(
        "./src/lucide_lustre.gleam",
        "import lustre/attribute.{type Attribute, attribute}
import lustre/element/svg\n" <> string.replace(
          contents,
          "attribute(\"xmlns\", \"http://www.w3.org/2000/svg\"),",
          "..attributes",
        ),
      )
    }

  io.println("Removing cloned icons...")

  let assert Ok(_) =
    gleamyshell.execute("rm", in: ".", args: ["-rf", "./lucide"])

  io.println("Removing cloned icons...")

  let assert Ok(_) = gleamyshell.execute("gleam", in: ".", args: ["format"])

  io.println("Finished generating icons")
}
