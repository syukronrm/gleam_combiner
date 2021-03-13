import combiner/prim.{ParseError}
import combiner/char
import gleam/should
import gleam/string
import gleam/int

pub fn test_then() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")

  prim.then(parser_a, parser_1, string.append)("A1B2")
  |> should.equal(Ok(tuple("B2", "A1")))

  prim.then(parser_a, parser_1, string.append)("B2")
  |> should.equal(Error(ParseError("B2", "CharError")))
}

pub fn test_or() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")

  prim.or(parser_a, parser_1)("A1B2")
  |> should.equal(Ok(tuple("1B2", "A")))

  prim.or(parser_1, parser_a)("A1B2")
  |> should.equal(Ok(tuple("1B2", "A")))

  prim.or(parser_a, parser_1)("B2")
  |> should.equal(Error(ParseError("B2", "CharError")))
}

pub fn test_map() {
  let parser_1 = char.char("1")

  prim.map(parser_1, int.parse)("1A")
  |> should.equal(Ok(tuple("A", 1)))

  prim.map(parser_1, int.parse)("A1")
  |> should.equal(Error(ParseError("A1", "CharError")))

  prim.map(parser_1, fn(_c) { Error(False) })("1")
  |> should.equal(Error(ParseError("A1", "MapError")))
}
