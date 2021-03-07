import combiner
import gleam/should

pub fn hello_world_test() {
  combiner.hello_world()
  |> should.equal("Hello, from combiner!")
}
