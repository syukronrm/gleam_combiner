import combiner.{ParseError}
import gleam/should
import gleam/bit_string

pub fn tag_test() {
  combiner.tag(<<"#":utf8>>)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"Example":utf8>>, <<"#":utf8>>)))

  combiner.tag(<<"#ß":utf8>>)(<<"#ß↑e̊":utf8>>)
  |> should.equal(Ok(tuple(<<"↑e̊":utf8>>, <<"#ß":utf8>>)))

  combiner.tag(<<"#X":utf8>>)(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "TagError")))
}

pub fn take_test() {
  combiner.take(4)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"mple":utf8>>, <<"#Exa":utf8>>)))

  combiner.take(10)(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "TakeError")))

  combiner.take(0)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"#Example":utf8>>, <<"":utf8>>)))
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
