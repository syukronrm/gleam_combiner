import combiner/prim.{Parser}
import gleam/list

pub fn alt(parsers: List(Parser(i, o, e))) -> Parser(i, o, e) {
  let [first, ..rest] = parsers
  list.fold(rest, first, fn(p, acc) { prim.or(acc, p) })
}

pub fn sequence(parsers: List(Parser(i, o, e))) -> Parser(i, List(o), e) {
  let concat_list = fn(head, tail) { [head, ..tail] }

  case parsers {
    [] -> prim.return([])
    [head, ..tail] -> prim.then(head, sequence(tail), concat_list)
  }
}

fn match_zero_or_more(parser1, parser2, input) {
  let concat_list = fn(head, tail) { [head, ..tail] }
  case prim.then(parser1, parser2, concat_list)(input) {
    Error(_) -> parser2(input)
    Ok(tuple(input2, output)) ->
      match_zero_or_more(parser1, prim.return(output), input2)
  }
}

pub fn many(parser: Parser(i, o, e)) -> Parser(i, List(o), e) {
  match_zero_or_more(parser, prim.return([]), _)
}
