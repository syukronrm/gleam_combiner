import combiner.{ParseError}
import gleam/should

pub fn tag_test() {
  combiner.tag("#")("#Example")
  |> should.equal(Ok(tuple("Example", "#")))

  combiner.tag("#X")("#Example")
  |> should.equal(Error(ParseError("#Example", "TagError")))
}

pub fn take_test() {
  combiner.take(4)("#Example")
  |> should.equal(Ok(tuple("mple", "#Exa")))

  combiner.take(10)("#Example")
  |> should.equal(Error(ParseError("#Example", "TakeError")))

  combiner.take(0)("#Example")
  |> should.equal(Ok(tuple("#Example", "")))
}
