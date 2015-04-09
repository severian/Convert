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
public func >>><A,B>(parser: Parser<A>, f: A -> Parser<B>) -> Parser<B> {
  return parser.flatMap(f)
}

infix operator >>! { associativity left }
public func >>!<A,B>(parser: Parser<A>, ignore: Parser<B>) -> Parser<A> {
  return parser >>> { val in
  return ignore >>> { _ in
    return always(val)
  }}
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

public func maybe<A>(val: A?) -> Parser<A> {
  if let v = val {
    return always(v)
  } else {
    return never()
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
  return parser >>> { a in
    return many(parser) >>> { rest in
      return always([a] + rest)
    }}
}

public func option<A>(parser: Parser<A>) -> Parser<A?> {
  return Parser<A?> { state in
    if let r = parser.parse(state) {
      return Result(state: r.state, val: r.val)
    } else {
      return Result(state: state, val: nil)
    }
  }
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
  return many1(letter()) >>> { letters in
    return always(String(letters))
  }
}

public func digit() -> Parser<Character> {
  return charSet(NSCharacterSet.decimalDigitCharacterSet())
}

public func positiveInteger() -> Parser<Int> {
  return many1(digit()) >>> { digits in
    return always(String(digits).toInt()!)
  }
}

public func negativeInteger() -> Parser<Int> {
  return char("-") >>> { _ in
    return positiveInteger() >>> { i in
      return always(i * -1)
    }}
}

public func integer() -> Parser<Int> {
  return choice(positiveInteger(), negativeInteger())
}

public func fraction() -> Parser<Double> {
  return integer() >>> { numerator in
    return char("/") >>> { _ in
      return integer() >>> { denominator in
        if (denominator != 0) {
          return always(Double(numerator) / Double(denominator))
        } else {
          return never()
        }
      }}}
}

public func decimal() -> Parser<Double> {
  let dec: Parser<Double> =
  choice(integer(), always(0)) >>> { intDigits in
    return char(".") >>> { _ in
      return positiveInteger() >>> { decDigits in
        return always(("\(intDigits).\(decDigits)" as NSString).doubleValue)
      }}}
  
  return choice(dec, integer() >>> { n in return always(Double(n)) })
}

public func number() -> Parser<Double> {
  return choice(fraction(), decimal())
}

public func matchTrie<A>(trie: Trie<A>) -> Parser<A> {
  return Parser<A> { state in
    if let (val, matchedState) = trie.get(state) {
      return Result(state: matchedState, val: val)
    } else {
      return nil
    }
  }
}

