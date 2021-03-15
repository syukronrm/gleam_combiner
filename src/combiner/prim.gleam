import gleam/string
import gleam/bit_string
import gleam/int
import gleam/io

pub type ParseLabel =
  String

pub type ParseError(a) {
  ParseError(input: a, message: String, label: ParseLabel)
}

pub type ParseResult(i, o, e) =
  Result(tuple(i, o), e)

pub type Parser(i, o, e) {
  Parser(parse_fn: fn(i) -> ParseResult(i, o, e), label: ParseLabel)
}

// Basic Combinator
pub fn run(parser: Parser(i, o, e), input: i) {
  parser.parse_fn(input)
}

pub fn get_label(parser: Parser(i, o, e)) {
  parser.label
}

pub fn default_label2(parser1, str, parser2) -> String {
  string.concat([get_label(parser1), str, get_label(parser2)])
}

pub fn default_label1(parser, str) -> String {
  string.concat([str, " ", get_label(parser)])
}

pub fn then(
  parser1: Parser(i, o1, e),
  parser2: Parser(i, o2, e),
  fun: fn(o1, o2) -> o3,
) -> Parser(i, o3, e) {
  let fun = fn(input) {
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
  let label = default_label2(parser1, " then ", parser2)
  Parser(fun, label)
}

pub fn or(parser1: Parser(i, o, e), parser2: Parser(i, o, e)) -> Parser(i, o, e) {
  let fun = fn(input) {
    let result = run(parser1, input)
    case result {
      Ok(_) -> result
      Error(_) -> run(parser2, input)
    }
  }
  let label = default_label2(parser1, " or ", parser2)
  Parser(fun, label)
}

pub fn map(
  parser: Parser(a, b, ParseError(a)),
  fun: fn(b) -> Result(c, e),
) -> Parser(a, c, ParseError(a)) {
  let label = default_label1(parser, "map")
  let fun = fn(input) {
    let result = run(parser, input)
    case result {
      Ok(tuple(remain, matched1)) -> {
        let matched2 = fun(matched1)
        case matched2 {
          Error(_) -> Error(ParseError(input, "MapError", label))
          Ok(result) -> Ok(tuple(remain, result))
        }
      }
      Error(e) -> Error(e)
    }
  }
  Parser(fun, label)
}

pub fn return(o) -> Parser(i, o, e) {
  let fun = fn(input) { Ok(tuple(input, o)) }
  Parser(fun, "Lifted")
}

pub fn print_result(result: ParseResult(String, String, ParseError(String))) {
  case result {
    Ok(tuple(_input, output)) -> io.debug(output)
    Error(parse_error) -> {
      io.debug(string.append("Error parsing ", parse_error.label))
      io.debug(parse_error.message)
      io.debug(string.append("Input ", parse_error.input))
    }
  }
}

pub fn label(parser: Parser(i, o, e), label) -> Parser(i, o, e) {
  Parser(..parser, label: label)
}
