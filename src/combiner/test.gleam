import gleam/list
import gleam/string

pub fn is_digit(c) {
  list.contains(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], c)
}

pub fn is_alphabetic(c) -> Bool {
  list.contains(
    [
      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
      "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    ],
    string.lowercase(c),
  )
}
