import combiner/combinator
import combiner/char
import combiner/test
import gleam/should

pub fn alt_test() {
  let take_integer = char.take_while(test.is_digit)
  let take_alphabetic = char.take_while(test.is_alphabetic)

  combinator.alt([take_integer, take_alphabetic])("11aa22bb")
  |> should.equal(Ok(tuple("aa22bb", "11")))

  combinator.alt([take_alphabetic, take_integer])("11cc22dd")
  |> should.equal(Ok(tuple("cc22dd", "11")))
}
