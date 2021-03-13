import combiner/prim.{ParseError}
import combiner/char
import combiner/test
import gleam/should
import gleam/bit_string

pub fn string_test() {
  char.string(<<"#":utf8>>)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"Example":utf8>>, <<"#":utf8>>)))

  char.string(<<"#ß":utf8>>)(<<"#ß↑e̊":utf8>>)
  |> should.equal(Ok(tuple(<<"↑e̊":utf8>>, <<"#ß":utf8>>)))

  char.string(<<"#X":utf8>>)(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "TagError")))
}

pub fn take_test() {
  char.take(4)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"mple":utf8>>, <<"#Exa":utf8>>)))

  char.take(10)(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "TakeError")))

  char.take(0)(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"#Example":utf8>>, <<"":utf8>>)))
}

pub fn take_while_test() {
  char.take_while(test.is_alphabetic)("Aa100")
  |> should.equal(Ok(tuple("100", "Aa")))

  char.take_while(test.is_alphabetic)("100Aa")
  |> should.equal(Error(ParseError("100Aa", "TakeWhileError")))

  char.take_while(test.is_alphabetic)("")
  |> should.equal(Error(ParseError("", "TakeWhileError")))
}

pub fn take_till_test() {
  char.take_till(test.is_alphabetic)("100Aa")
  |> should.equal(Ok(tuple("Aa", "100")))

  char.take_till(test.is_alphabetic)("Aa100")
  |> should.equal(Error(ParseError("Aa100", "TakeTillError")))

  char.take_till(test.is_alphabetic)("")
  |> should.equal(Error(ParseError("", "TakeTillError")))
}

pub fn char_test() {
  char.char("E")("Example")
  |> should.equal(Ok(tuple("xample", "E")))

  char.char("x")("Example")
  |> should.equal(Error(ParseError("Example", "CharError")))

  char.char("E")("")
  |> should.equal(Error(ParseError("", "CharError")))
}
