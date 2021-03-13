import combiner/prim.{ParseError}
import combiner/char
import gleam/should
import gleam/string

pub fn test_then() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")

  prim.then(parser_a, parser_1, string.append)("A1B2")
  |> should.equal(Ok(tuple("B2", "A1")))

  prim.then(parser_a, parser_1, string.append)("B2")
  |> should.equal(Error(ParseError("B2", "CharError")))
}
