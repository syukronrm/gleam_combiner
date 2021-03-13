import combiner/prim.{Parser}
import gleam/list

pub fn alt(parsers: List(Parser(i, o, e))) -> Parser(i, o, e) {
  let [first, ..rest] = parsers
  list.fold(rest, first, fn(p, acc) { prim.or(acc, p) })
}
