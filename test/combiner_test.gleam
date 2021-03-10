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
  |> should.equal(Error(ParseError("100Aa", "TakeWhileError")))

  combiner.take_while(combiner.is_alphabetic)("")
  |> should.equal(Error(ParseError("", "TakeWhileError")))
}

pub fn take_till_test() {
  combiner.take_till(combiner.is_alphabetic)("100Aa")
  |> should.equal(Ok(tuple("Aa", "100")))

  combiner.take_till(combiner.is_alphabetic)("Aa100")
  |> should.equal(Error(ParseError("Aa100", "TakeTillError")))

  combiner.take_till(combiner.is_alphabetic)("")
  |> should.equal(Error(ParseError("", "TakeTillError")))
}

pub fn alt_test() {
  let take_integer = combiner.take_while(combiner.is_digit)
  let take_alphabetic = combiner.take_while(combiner.is_alphabetic)

  combiner.alt([take_integer, take_alphabetic])("11aa22bb")
  |> should.equal(Ok(tuple("aa22bb", "11")))

  combiner.alt([take_alphabetic, take_integer])("11cc22dd")
  |> should.equal(Ok(tuple("cc22dd", "11")))
}
