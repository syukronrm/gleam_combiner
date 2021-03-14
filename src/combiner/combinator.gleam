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
