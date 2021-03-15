import combiner/prim.{ParseError, Parser}
import gleam/string
import gleam/bit_string
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/io

// Basic Elements
pub fn string(str) -> Parser(BitString, BitString, ParseError(BitString)) {
  let label = "String"
  let fun = fn(input) {
    let len = bit_string.byte_size(str)
    case bit_string.part(input, 0, len) {
      Ok(bytes) ->
        case bytes == str {
          True -> {
            let input_len = bit_string.byte_size(input)
            case bit_string.part(input, len, input_len - len) {
              Ok(result) -> Ok(tuple(result, bytes))
              Error(_) -> Error(ParseError(input, "StringError", label))
            }
          }
          False -> Error(ParseError(input, "StringError", label))
        }
      Error(_) -> Error(ParseError(input, "StringError", label))
    }
  }

  Parser(fun, label)
}

pub fn tag_string(str) -> Parser(String, String, ParseError(String)) {
  let label = "Tag"
  let fun = fn(input) {
    let len = string.length(str)
    case string.slice(input, 0, len) == str {
      True -> Ok(tuple(string.drop_left(input, len), str))
      False -> Error(ParseError(input, "TagError", label))
    }
  }

  Parser(fun, label)
}

pub fn take(len: Int) -> Parser(BitString, BitString, ParseError(BitString)) {
  let label = "Take"
  let fun = fn(input) {
    case bit_string.part(input, 0, len) {
      Ok(matched) -> {
        let input_len = bit_string.byte_size(input)
        case bit_string.part(input, len, input_len - len) {
          Ok(remain) -> Ok(tuple(remain, matched))
          _ -> Error(ParseError(input, "TakeError", label))
        }
      }
      _ -> Error(ParseError(input, "TakeError", label))
    }
  }

  Parser(fun, label)
}

pub fn take_string(len: Int) -> Parser(String, String, ParseError(String)) {
  let label = "Take"
  let fun = fn(input) {
    let taken_str = string.slice(input, 0, len)
    case string.length(taken_str) == len {
      True -> Ok(tuple(string.drop_left(input, len), taken_str))
      False -> Error(ParseError(input, "TakeError", label))
    }
  }

  Parser(fun, label)
}

pub fn take_while(
  fun: fn(String) -> Bool,
) -> Parser(String, String, ParseError(String)) {
  let label = "TakeWhile"
  let fun = fn(input) {
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
      [] -> Error(ParseError(input, "TakeWhileError", label))
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

  Parser(fun, label)
}

pub fn take_till(
  fun: fn(String) -> Bool,
) -> Parser(String, String, ParseError(String)) {
  let label = "TakeTill"
  let fun = fn(input) {
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
      [] -> Error(ParseError(input, "TakeTillError", label))
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

  Parser(fun, label)
}

pub fn char(c: String) -> Parser(String, String, ParseError(String)) {
  let label = "Char"
  let fun = fn(input) {
    case string.pop_grapheme(input) {
      Error(_) -> Error(ParseError(input, "CharError", label))
      Ok(tuple(first_char, rest)) ->
        case first_char == c {
          False -> Error(ParseError(input, "CharError", label))
          True -> Ok(tuple(rest, c))
        }
    }
  }

  Parser(fun, label)
}

pub fn any_of(chars: String) -> Parser(String, String, ParseError(String)) {
  let label = "AnyOf"
  let fun = fn(input) {
    case string.pop_grapheme(input) {
      Error(_) -> Error(ParseError(input, "AnyOfError", label))
      Ok(tuple(c, rest)) -> {
        let graphemes = string.to_graphemes(chars)
        case list.contains(graphemes, c) {
          True -> Ok(tuple(rest, c))
          _ -> Error(ParseError(input, "AnyOfError", label))
        }
      }
    }
  }

  Parser(fun, label)
}
