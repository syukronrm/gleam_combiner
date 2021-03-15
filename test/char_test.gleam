import combiner/prim.{ParseError}
import combiner/char
import combiner/test
import gleam/should
import gleam/bit_string

pub fn string_test() {
  char.string(<<"#":utf8>>)
  |> prim.run(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"Example":utf8>>, <<"#":utf8>>)))

  char.string(<<"#ß":utf8>>)
  |> prim.run(<<"#ß↑e̊":utf8>>)
  |> should.equal(Ok(tuple(<<"↑e̊":utf8>>, <<"#ß":utf8>>)))

  char.string(<<"#X":utf8>>)
  |> prim.run(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "StringError", "String")))
}

pub fn take_test() {
  char.take(4)
  |> prim.run(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"mple":utf8>>, <<"#Exa":utf8>>)))

  char.take(10)
  |> prim.run(<<"#Example":utf8>>)
  |> should.equal(Error(ParseError(<<"#Example":utf8>>, "TakeError", "Take")))

  char.take(0)
  |> prim.run(<<"#Example":utf8>>)
  |> should.equal(Ok(tuple(<<"#Example":utf8>>, <<"":utf8>>)))
}

pub fn take_while_test() {
  char.take_while(test.is_alphabetic)
  |> prim.run("Aa100")
  |> should.equal(Ok(tuple("100", "Aa")))

  char.take_while(test.is_alphabetic)
  |> prim.run("100Aa")
  |> should.equal(Error(ParseError("100Aa", "TakeWhileError", "TakeWhile")))

  char.take_while(test.is_alphabetic)
  |> prim.run("")
  |> should.equal(Error(ParseError("", "TakeWhileError", "TakeWhile")))
}

pub fn take_till_test() {
  char.take_till(test.is_alphabetic)
  |> prim.run("100Aa")
  |> should.equal(Ok(tuple("Aa", "100")))

  char.take_till(test.is_alphabetic)
  |> prim.run("Aa100")
  |> should.equal(Error(ParseError("Aa100", "TakeTillError", "TakeTill")))

  char.take_till(test.is_alphabetic)
  |> prim.run("")
  |> should.equal(Error(ParseError("", "TakeTillError", "TakeTill")))
}

pub fn char_test() {
  char.char("E")
  |> prim.run("Example")
  |> should.equal(Ok(tuple("xample", "E")))

  char.char("x")
  |> prim.run("Example")
  |> should.equal(Error(ParseError("Example", "CharError", "Char")))

  char.char("E")
  |> prim.run("")
  |> should.equal(Error(ParseError("", "CharError", "Char")))
}

pub fn any_of_test() {
  char.any_of("AOE")
  |> prim.run("Example")
  |> should.equal(Ok(tuple("xample", "E")))

  char.any_of("AO")
  |> prim.run("Example")
  |> should.equal(Error(ParseError("Example", "AnyOfError", "AnyOf")))
}
