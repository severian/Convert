// Playground - noun: a place where people can play

import Foundation

struct InputState {
  let input: String
  var pos: Int
  
  func advanceBy(n: Int) -> InputState {
    return InputState(input: input, pos: pos + n)
  }
  
  func first() -> Character? {
    if pos < countElements(input) {
      return input[advance(input.startIndex, pos)]
    } else {
      return nil
    }
  }
}

struct Result<A> {
  let state: InputState
  let val: A
}

struct Parser<A> {
  let parser: InputState -> Result<A>?
  
  func parse(state: InputState) -> Result<A>? {
    return parser(state)
  }
  
  func flatMap<B>(f: A -> Parser<B>) -> Parser<B> {
    let parser = self.parser
    return Parser<B> { input in
      if let r = parser(input) {
        return f(r.val).parse(r.state)
      } else {
        return nil
      }
    }
  }
}

infix operator >>> { associativity left }
func >>><A,B>(parser: Parser<A>, f: A -> Parser<B>) -> Parser<B> {
  return parser.flatMap(f)
}

func char(c: Character) -> Parser<Character> {
  return Parser<Character>() { state in
    if c == state.first() {
//      print("returning " + [c])
      return Result(state: state.advanceBy(1), val: c)
    } else {
      return nil;
    }
  }
}

func token(consume: Character -> Bool) -> Parser<Character> {
  return Parser<Character>() { state in
    if let c = state.first() {
      if consume(c) {
        return Result(state: state.advanceBy(1), val: c)
      }
    }
    return nil
  }
}

func many<A>(parser: Parser<A>) -> Parser<[A]> {
  return Parser<[A]> { state in
    var a = [A]()
    var s = state
    while let r = parser.parse(s) {
      s = r.state
      a.append(r.val)
    }
    return Result(state: s, val: a)
  }
}

func many1<A>(parser: Parser<A>) -> Parser<[A]> {
  return parser >>> { a in
    return many(parser) >>> { rest in
      return always([a] + rest)
    }
  }
}

func charSet(cs: NSCharacterSet) -> Parser<Character> {
  return token() { c in
    return cs.characterIsMember(String(c).utf16[0])
  }
}

func letter() -> Parser<Character> {
  return charSet(NSCharacterSet.letterCharacterSet())
}

func digit() -> Parser<Character> {
  return charSet(NSCharacterSet.decimalDigitCharacterSet())
}

func always<A>(val: A) -> Parser<A> {
  return Parser<A>() { state in
    return Result(state: state, val: val)
  }
}

func choice<A>(parsers: Parser<A>...) -> Parser<A> {
  return Parser<A>() { state in
    for parser in parsers {
      if let r = parser.parse(state) {
        return r
      }
    }
    return nil
  }
}

func run<A>(parser: Parser<A>, input: String) -> A? {
  return parser.parse(InputState(input: input, pos: 0))?.val
}

let a = charSet(NSCharacterSet.uppercaseLetterCharacterSet())

let c:Parser<String> = a >>> { upper in
  let lower = String(upper).lowercaseString
  return many(char(lower[lower.startIndex])) >>> { letters in
    return always("Got \(countElements(letters) + 1) \(upper)'s")
  }
}

run(c, "Z")

//func mapper<P1: Parser where P1.T == Character>(c: Character) -> P1 {
//  if (c == "A") {
//    return Char(c: "a") as P1
//  } else {
//    return Char(c: "b") as P1
//  }
//}
//
//if let z = b.parse(InputState(input: "Aa", pos: 0)) {
//  print(z)
//} else {
//  print("NOPE!")
//}


//struct Many<A, P1: Parser where P1.T == A>: Parser {
//  typealias T = [A]
//
//  let parser: P1
//
//  func parse(state: InputState) -> Result<T>? {
//    let m = FlatMap(parser: parser, f: { a in return FlatMap(parser: Many(self.parser), f: { b in return b.insert(a) }) })
//  }
//}


