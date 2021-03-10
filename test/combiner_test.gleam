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

pub fn take_while_test() {
  combiner.take_while(combiner.is_alphabetic)("Aa100")
  |> should.equal(Ok(tuple("100", "Aa")))

  combiner.take_while(combiner.is_alphabetic)("100Aa")
  |> should.equal(Ok(tuple("100Aa", "")))

  combiner.take_while(combiner.is_alphabetic)("")
  |> should.equal(Ok(tuple("", "")))
}

pub fn take_till_test() {
  combiner.take_till(combiner.is_alphabetic)("Aa100")
  |> should.equal(Ok(tuple("Aa100", "")))

  combiner.take_till(combiner.is_alphabetic)("100Aa")
  |> should.equal(Ok(tuple("Aa", "100")))

  combiner.take_till(combiner.is_alphabetic)("")
  |> should.equal(Ok(tuple("", "")))
}
