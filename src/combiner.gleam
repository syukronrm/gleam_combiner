import gleam/string
import gleam/bit_string
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/io

pub type ParseError(a) {
  ParseError(input: a, message: String)
}

pub type Parser(i, o, e) =
  fn(i) -> Result(tuple(i, o), e)

// Basic Elements
pub fn tag(str) -> Parser(BitString, BitString, ParseError(BitString)) {
  fn(input) {
    let len = bit_string.byte_size(str)
    case bit_string.part(input, 0, len) {
      Ok(bytes) ->
        case bytes == str {
          True -> {
            let input_len = bit_string.byte_size(input)
            case bit_string.part(input, len, input_len - len) {
              Ok(result) -> Ok(tuple(result, bytes))
              Error(_) -> Error(ParseError(input, "TagError"))
            }
          }
          False -> Error(ParseError(input, "TagError"))
        }
      Error(_) -> Error(ParseError(input, "TagError"))
    }
  }
}

pub fn tag_string(str) -> Parser(String, String, ParseError(String)) {
  fn(input) {
    let len = string.length(str)
    case string.slice(input, 0, len) == str {
      True -> Ok(tuple(string.drop_left(input, len), str))
      False -> Error(ParseError(input, "TagError"))
    }
  }
}

pub fn take(len: Int) -> Parser(BitString, BitString, ParseError(BitString)) {
  fn(input) {
    case bit_string.part(input, 0, len) {
      Ok(matched) -> {
        let input_len = bit_string.byte_size(input)
        case bit_string.part(input, len, input_len - len) {
          Ok(remain) -> Ok(tuple(remain, matched))
          _ -> Error(ParseError(input, "TakeError"))
        }
      }
      _ -> Error(ParseError(input, "TakeError"))
    }
  }
}

pub fn take_string(len: Int) -> Parser(String, String, ParseError(String)) {
  fn(input) {
    let taken_str = string.slice(input, 0, len)
    case string.length(taken_str) == len {
      True -> Ok(tuple(string.drop_left(input, len), taken_str))
      False -> Error(ParseError(input, "TakeError"))
    }
  }
}

pub fn take_while(
  fun: fn(String) -> Bool,
) -> Parser(String, String, ParseError(String)) {
  fn(input) {
    let matched_graphemes =
      input
      |> string.to_graphemes
      |> list.fold_until(
        [],
        fn(i, acc) {
          case fun(i) {
            True -> Continue([i, ..acc])
            _ -> Stop(acc)
          }
        },
      )

    case matched_graphemes {
      [] -> Error(ParseError(input, "TakeWhileError"))
      _ -> {
        let matched =
          matched_graphemes
          |> list.reverse()
          |> string.join("")
        let remain =
          input
          |> string.drop_left(string.length(matched))
        Ok(tuple(remain, matched))
      }
    }
  }
}

pub fn take_till(
  fun: fn(String) -> Bool,
) -> Parser(String, String, ParseError(String)) {
  fn(input) {
    let matched_graphemes =
      input
      |> string.to_graphemes
      |> list.fold_until(
        [],
        fn(i, acc) {
          case fun(i) {
            False -> Continue([i, ..acc])
            _ -> Stop(acc)
          }
        },
      )

    case matched_graphemes {
      [] -> Error(ParseError(input, "TakeTillError"))
      _ -> {
        let matched =
          matched_graphemes
          |> list.reverse()
          |> string.join("")
        let remain =
          input
          |> string.drop_left(string.length(matched))
        Ok(tuple(remain, matched))
      }
    }
  }
}

// Choice combinator
pub fn alt(parsers: List(Parser(i, o, e))) -> Parser(i, o, e) {
  let [first, ..rest] = parsers
  list.fold(rest, first, fn(p, acc) { or(acc, p) })
}

// Test functions
pub fn is_digit(c) {
  list.contains(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], c)
}

pub fn is_alphabetic(c) -> Bool {
  list.contains(
    [
      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
      "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    ],
    string.lowercase(c),
  )
}

// Basic Combinator
fn run(parser: fn(a) -> b, input) {
  parser(input)
}

pub fn then(
  parser1: Parser(i, o, e),
  parser2: Parser(i, o, e),
  fun: fn(o, o) -> o,
) -> Parser(i, o, e) {
  fn(input) {
    let result1 = run(parser1, input)
    case result1 {
      Error(err) -> Error(err)
      Ok(tuple(remain1, matched1)) -> {
        let result2 = run(parser2, remain1)
        case result2 {
          Error(err) -> Error(err)
          Ok(tuple(remain2, matched2)) -> {
            let combined = fun(matched1, matched2)
            Ok(tuple(remain2, combined))
          }
        }
      }
    }
  }
}

pub fn or(parser1: Parser(i, o, e), parser2: Parser(i, o, e)) -> Parser(i, o, e) {
  fn(input) {
    let result = run(parser1, input)
    case result {
      Ok(_) -> result
      Error(_) -> run(parser2, input)
    }
  }
}

pub fn map(
  parser: Parser(a, b, ParseError(a)),
  fun: fn(b) -> Result(c, e),
) -> Parser(a, c, ParseError(a)) {
  fn(input) {
    let result = run(parser, input)
    case result {
      Ok(tuple(remain, matched1)) -> {
        let matched2 = fun(matched1)
        case matched2 {
          Error(_) -> Error(ParseError(input, "MapError"))
          Ok(result) -> Ok(tuple(remain, result))
        }
      }
      Error(e) -> Error(e)
    }
  }
}
//
