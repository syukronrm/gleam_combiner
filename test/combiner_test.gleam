import combiner
import gleam/should

pub fn tag_test() {
  combiner.tag("#")("#EXAMPLE")
  |> should.equal(Ok(tuple("EXAMPLE", "#")))
}
