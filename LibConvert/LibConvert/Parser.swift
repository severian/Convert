//
//  Parser.swift
//  Convert
//
//  Created by James Baird on 4/4/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public struct Result<A> {
  public let state: InputState
  public let val: A
}

public struct Parser<A> {
  let parser: InputState -> Result<A>?
  
  func parse(state: InputState) -> Result<A>? {
    return parser(state)
  }
  
  public func flatMap<B>(f: A -> Parser<B>) -> Parser<B> {
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

infix operator >>= { associativity left }
public func >>=<A,B>(parser: Parser<A>, f: A -> Parser<B>) -> Parser<B> {
  return parser.flatMap(f)
}

public func run<A>(parser: Parser<A>, input: String) -> Result<A>? {
  return parser.parse(InputState(input: input, pos: input.startIndex))
}

public func always<A>(val: A) -> Parser<A> {
  return Parser<A>() { state in
    return Result(state: state, val: val)
  }
}

public func never<A>() -> Parser<A> {
  return Parser<A>() { state in
    return nil
  }
}

public func maybe<A>(parser: Parser<A>) -> Parser<A?> {
  return Parser<A?> { state in
    if let r = parser.parse(state) {
      return Result(state: r.state, val: r.val)
    } else {
      return Result(state: state, val: nil)
    }
  }
}

public func char(c: Character) -> Parser<Character> {
  return Parser<Character>() { state in
    if c == state.first() {
      return Result(state: state.advanceBy(1), val: c)
    } else {
      return nil;
    }
  }
}

public func string(str: String) -> Parser<String> {
  return Parser<String>() { state in
    if state.startsWith(str) {
      return Result(state: state.advanceBy(count(str)), val: str)
    } else {
      return nil
    }
  }
}

public func choice<A>(parsers: Parser<A>...) -> Parser<A> {
  return Parser<A>() { state in
    for parser in parsers {
      if let r = parser.parse(state) {
        return r
      }
    }
    return nil
  }
}

public func token(consume: Character -> Bool) -> Parser<Character> {
  return Parser<Character>() { state in
    if let c = state.first() {
      if consume(c) {
        return Result(state: state.advanceBy(1), val: c)
      }
    }
    return nil
  }
}

public func many<A>(parser: Parser<A>) -> Parser<[A]> {
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

public func many1<A>(parser: Parser<A>) -> Parser<[A]> {
  return parser >>= { a in
    return many(parser) >>= { rest in
      return always([a] + rest)
    }}
}

public func charSet(cs: NSCharacterSet) -> Parser<Character> {
  return token() { c in
    let str = String(c)
    return cs.characterIsMember(str.utf16[str.utf16.startIndex])
  }
}

public func letter() -> Parser<Character> {
  return charSet(NSCharacterSet.letterCharacterSet())
}

public func word() -> Parser<String> {
  return many1(letter()) >>= { letters in
    return always(String(letters))
  }
}

public func whitespace() -> Parser<Character> {
  return charSet(NSCharacterSet.whitespaceCharacterSet())
}

public func digit() -> Parser<Character> {
  return charSet(NSCharacterSet.decimalDigitCharacterSet())
}

public func consumeTrailing<A,B>(parser: Parser<A>, consume: Parser<B>) -> Parser<A> {
  return parser >>= { a in
  return consume >>= { _ in
    return always(a)
  }}
}

public func consumeTrailingWhitespace<A>(parser: Parser<A>) -> Parser<A> {
  return consumeTrailing(parser, many(whitespace()))
}

public func parsedInfo<A>(parser: Parser<A>) -> Parser<ParsedInfo<A>> {
  return Parser<ParsedInfo<A>> { state in
    if let r = parser.parse(state) {
      let info = ParsedInfo(val: r.val, source: state.consumedFrom(r.state), pos: state.pos)
      return Result(state: r.state, val: info)
    } else {
      return nil
    }
  }
}

