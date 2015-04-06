//
//  Parser.swift
//  Convert
//
//  Created by James Baird on 4/4/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

struct InputState {
  let input: String
  var pos: Int
  
  func advanceBy(n: Int) -> InputState {
    return InputState(input: input, pos: pos + n)
  }
  
  func first() -> Character {
    return input[advance(input.startIndex, pos)]
  }
}

struct Result<T> {
  let state: InputState
  let val: T
}

protocol Parser {
  typealias T
  
  func parse(state: InputState) -> Result<T>?
}

struct Char: Parser {
  let c: Character
  
  func parse(state: InputState) -> Result<Character>? {
    if c == state.first() {
      return Result(state: state.advanceBy(1), val: c)
    } else {
      return nil
    }
  }
}

struct Token: Parser {
  let consume: Character -> Bool
  
  func parse(state: InputState) -> Result<Character>? {
    let c = state.first()
    if consume(c) {
      return Result(state: state.advanceBy(1), val: c)
    } else {
      return nil
    }
  }
}

struct Always<A>: Parser {
  let val: A
  
  func parse(state: InputState) -> Result<A>? {
    return Result(state: state, val: val)
  }
}

func letter<P1: Parser where P1.T == Character>() -> P1 {
  return Token { c in return NSCharacterSet.letterCharacterSet().characterIsMember(String(c).utf16[0]) } as P1
}

func digit<P1: Parser where P1.T == Character>() -> P1 {
  return Token { c in return NSCharacterSet.decimalDigitCharacterSet().characterIsMember(String(c).utf16[0]) } as P1
}

struct FlatMap<A, B, P1: Parser, P2: Parser where P1.T == A, P2.T == B>: Parser {
  typealias T = B
  
  let parser: P1
  let f: A -> P2
  
  func parse(state: InputState) -> Result<T>? {
    if let r = parser.parse(state) {
      return f(r.val).parse(r.state)
    } else {
      return nil
    }
  }
}

func flatMap<A, B, P1: Parser, P2: Parser where P1.T == A, P2.T == B>(parser: P1, f: A -> P2) -> P2 {
  return FlatMap(parser: parser, f: f) as P2
}

//struct Many<A, P1: Parser where P1.T == A>: Parser {
//  typealias T = [A]
//  
//  let parser: P1
//  
//  func parse(state: InputState) -> Result<T>? {
//    let m = FlatMap(parser: parser, f: { a in return FlatMap(parser: Many(self.parser), f: { b in return b.insert(a) }) })
//  }
//}


