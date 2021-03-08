import combiner.{Color, IntegerErr, ParseError, TagErr}
import gleam/should

pub fn tag_test() {
  combiner.tag("#EXAMPLE", "#")
  |> should.equal(Ok(tuple("EXAMPLE", "#")))

  combiner.tag("EXAMPLE", "#")
  |> should.equal(Error(ParseError("EXAMPLE", TagErr)))

  combiner.tag("", "#")
  |> should.equal(Error(ParseError("", TagErr)))
}

pub fn integer_test() {
  combiner.integer("982", 3)
  |> should.equal(Ok(tuple("", 982)))

  combiner.integer("982100", 3)
  |> should.equal(Ok(tuple("100", 982)))

  combiner.integer("10", 4)
  |> should.equal(Error(ParseError("10", IntegerErr)))

  combiner.integer("Yesn't?", 4)
  |> should.equal(Error(ParseError("Yesn't?", IntegerErr)))
}

pub fn integration_test() {
  combiner.color_parser("#101010")
  |> should.equal(Ok(Color(10, 10, 10)))
}
