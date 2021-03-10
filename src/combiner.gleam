import gleam/string
import gleam/int
import gleam/io

pub type ParseError {
  ParseError(input: String, message: String)
}

pub type Output(a) =
  Result(tuple(a, a), ParseError)

pub type Parser(a) =
  fn(a) -> Output(a)

pub fn tag(str) -> Parser(String) {
  fn(input) {
    let len = string.length(str)
    case string.slice(input, 0, len) == str {
      True -> Ok(tuple(string.drop_left(input, len), str))
      False -> Error(ParseError(input, "TagError"))
    }
  }
}

pub fn take(len: Int) -> Parser(String) {
  fn(input) {
    let taken_str = string.slice(input, 0, len)
    case string.length(taken_str) == len {
      True -> Ok(tuple(string.drop_left(input, len), taken_str))
      False -> Error(ParseError(input, "TakeError"))
    }
  }
}

pub fn digit1(_count) -> Parser(String) {
  todo
}

fn run(parser: fn(a) -> b, input) {
  parser(input)
}

pub fn then(parser1: Parser(String), parser2: Parser(String)) -> Parser(String) {
  fn(input) {
    let result1 = run(parser1, input)
    case result1 {
      Error(err) -> Error(err)
      Ok(tuple(remain1, matched1)) -> {
        let result2 = run(parser2, remain1)
        case result2 {
          Error(err) -> Error(err)
          Ok(tuple(remain2, matched2)) -> {
            let combined = string.append(matched1, matched2)
            Ok(tuple(remain2, combined))
          }
        }
      }
    }
  }
}

pub fn or(parser1: Parser(a), parser2: Parser(a)) -> Parser(a) {
  fn(input) {
    let result = run(parser1, input)
    case result {
      Ok(_) -> result
      Error(_) -> run(parser2, input)
    }
  }
}

pub fn map(_parser: Parser(a), _fun: fn(a) -> b) -> Parser(b) {
  // fn(input) {
  //   let result = run(parser, input)
  //   case result {
  //     Ok(tuple(remain, matched1)) -> {
  //       let matched2 = fun(matched1)
  //       Ok(tuple(remain, matched2))
  //     }
  //     Error(err) -> {
  //       let ParseError(input, message) = err
  //       Error(ParseError(input, message))
  //     }
  //   }
  // }
  todo
}
