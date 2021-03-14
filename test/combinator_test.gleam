import combiner/combinator
import combiner/char
import combiner/test
import combiner/prim.{ParseError}
import gleam/should

pub fn alt_test() {
  let take_integer = char.take_while(test.is_digit)
  let take_alphabetic = char.take_while(test.is_alphabetic)

  combinator.alt([take_integer, take_alphabetic])("11aa22bb")
  |> should.equal(Ok(tuple("aa22bb", "11")))

  combinator.alt([take_alphabetic, take_integer])("11cc22dd")
  |> should.equal(Ok(tuple("cc22dd", "11")))
}

pub fn sequence_test() {
  let parser_a = char.char("A")
  let parser_1 = char.char("1")
  let parser_b = char.char("B")

  combinator.sequence([parser_a, parser_1, parser_b])("A1B2")
  |> should.equal(Ok(tuple("2", ["A", "1", "B"])))

  combinator.sequence([parser_a, parser_1, parser_b])("A2B2")
  |> should.equal(Error(ParseError("2B2", "CharError")))

  combinator.sequence([])("A1B2")
  |> should.equal(Ok(tuple("A1B2", [])))
}

pub fn many_test() {
  let parser_a = char.char("A")

  combinator.many(parser_a)("A1B2")
  |> should.equal(Ok(tuple("1B2", ["A"])))

  combinator.many(parser_a)("AAA1B2")
  |> should.equal(Ok(tuple("1B2", ["A", "A", "A"])))

  combinator.many(parser_a)("1B2")
  |> should.equal(Ok(tuple("1B2", [])))

  combinator.many(parser_a)("")
  |> should.equal(Ok(tuple("", [])))
}
