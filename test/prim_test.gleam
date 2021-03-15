import combiner/prim.{ParseError}
import combiner/char
import gleam/should
import gleam/string
import gleam/int

pub fn test_then() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")

  parser_a
  |> prim.then(parser_1, string.append)
  |> prim.run("A1B2")
  |> should.equal(Ok(tuple("B2", "A1")))

  prim.then(parser_a, parser_1, string.append)
  |> prim.run("B2")
  |> should.equal(Error(ParseError("B2", "CharError", "Char")))
}

pub fn test_or() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")

  prim.or(parser_a, parser_1)
  |> prim.run("A1B2")
  |> should.equal(Ok(tuple("1B2", "A")))

  prim.or(parser_1, parser_a)
  |> prim.run("A1B2")
  |> should.equal(Ok(tuple("1B2", "A")))

  prim.or(parser_a, parser_1)
  |> prim.run("B2")
  |> should.equal(Error(ParseError("B2", "CharError", "Char")))
}

pub fn test_map() {
  let parser_1 = char.char("1")

  prim.map(parser_1, int.parse)
  |> prim.run("1A")
  |> should.equal(Ok(tuple("A", 1)))

  prim.map(parser_1, int.parse)
  |> prim.run("A1")
  |> should.equal(Error(ParseError("A1", "CharError", "Char")))

  prim.map(parser_1, fn(_c) { Error(False) })
  |> prim.run("1")
  |> should.equal(Error(ParseError("A1", "MapError", "Char")))
}

pub fn test_label() {
  let parse_one = fn(input) {
    char.char("1")
    |> prim.label("Parse One")
    |> prim.run(input)
  }

  parse_one("B2")
  |> should.equal(Error(ParseError("B2", "CharError", "Parse One")))
}
