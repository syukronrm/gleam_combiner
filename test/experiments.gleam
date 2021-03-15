import combiner/combinator
import combiner/char
import combiner/test
import combiner/prim
import gleam/string
import gleam/should

fn parse_three_chars_as_str(input) {
  let concat_output = fn(o1, o2) { string.append(o1, o2) }

  let parsers = fn(input) {
    char.char("A")
    |> prim.then(char.char("B"), concat_output)
    |> prim.then(char.char("B"), concat_output)
    |> prim.run(input)
  }

  parsers(input)
}

pub fn parse_three_chars_as_str_test() {
  parse_three_chars_as_str("ABBA")
  |> should.equal(Ok(tuple("A", "ABB")))
}
