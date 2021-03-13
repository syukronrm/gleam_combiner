import gleam/string
import gleam/bit_string
import gleam/int
import gleam/io

pub type ParseError(a) {
  ParseError(input: a, message: String)
}

pub type Parser(i, o, e) =
  fn(i) -> Result(tuple(i, o), e)

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
