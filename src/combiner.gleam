import gleam/string
import gleam/int

pub type Remain =
  String

pub type ErrorKind {
  IntegerErr
  TagErr
}

pub type ParseError {
  ParseError(input: String, error_kind: ErrorKind)
}

pub fn tag(
  input: String,
  key: String,
) -> Result(tuple(Remain, String), ParseError) {
  case string.length(input) == 0 {
    True -> Error(ParseError(input, TagErr))
    _ -> {
      let key_length = string.length(key)
      let str = string.slice(input, 0, key_length)
      case key_length {
        0 -> Error(ParseError(input, TagErr))
        _ ->
          case str == key {
            True -> Ok(tuple(string.drop_left(input, key_length), key))
            _ -> Error(ParseError(input, TagErr))
          }
      }
    }
  }
}

pub fn integer(
  input: String,
  count: Int,
) -> Result(tuple(Remain, Int), ParseError) {
  case string.length(input) == 0 {
    True -> Error(ParseError(input, IntegerErr))
    _ -> {
      let str = string.slice(input, 0, count)
      case string.length(str) == count {
        True ->
          case int.parse(str) {
            Ok(num) -> Ok(tuple(string.drop_left(input, count), num))
            _err -> Error(ParseError(input, IntegerErr))
          }
        _ -> Error(ParseError(input, IntegerErr))
      }
    }
  }
}

// Example
pub type Color {
  Color(red: Int, green: Int, blue: Int)
}

pub fn color_parser(input: String) -> Result(Color, ParseError) {
  try tuple(input, _) = tag(input, "#")
  try tuple(input, red) = integer(input, 2)
  try tuple(input, green) = integer(input, 2)
  try tuple(_input, blue) = integer(input, 2)
  Ok(Color(red, green, blue))
}
