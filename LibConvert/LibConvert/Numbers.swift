//
//  Numbers.swift
//  LibConvert
//
//  Created by James Baird on 4/27/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public func positiveInteger() -> Parser<Int> {
  return many1(digit()) >>= { digits in
    return always(String(digits).toInt()!)
  }
}

public func negativeInteger() -> Parser<Int> {
  return char("-") >>= { _ in
  return positiveInteger() >>= { i in
    return always(i * -1)
  }}
}

public func integer() -> Parser<Int> {
  return choice(positiveInteger(), negativeInteger())
}

public func fraction() -> Parser<Double> {
  return integer() >>= { numerator in
  return char("/") >>= { _ in
  return integer() >>= { denominator in
    if (denominator != 0) {
      return always(Double(numerator) / Double(denominator))
    } else {
      return never()
    }
  }}}
}

public func decimal() -> Parser<Double> {
  let dec: Parser<Double> =
  choice(integer(), always(0)) >>= { intDigits in
  return char(".") >>= { _ in
  return positiveInteger() >>= { decDigits in
    return always(("\(intDigits).\(decDigits)" as NSString).doubleValue)
  }}}
  
  return choice(dec, integer() >>= { n in return always(Double(n)) })
}

public func numericNumber() -> Parser<Double> {
  return choice(fraction(), decimal())
}

let numberTrie: Trie<Double> = {
  let trie = Trie<Double>()
  trie.put("zero", val: 0)
  trie.put("one", val: 1)
  trie.put("two", val: 2)
  trie.put("three", val: 3)
  trie.put("four", val: 4)
  trie.put("five", val: 5)
  trie.put("six", val: 6)
  trie.put("seven", val: 7)
  trie.put("eight", val: 8)
  trie.put("nine", val: 9)
  trie.put("ten", val: 10)
  trie.put("eleven", val: 11)
  trie.put("twelve", val: 12)
  trie.put("thirteen", val: 13)
  trie.put("fourteen", val: 14)
  trie.put("fifteen", val: 15)
  trie.put("sixteen", val: 16)
  trie.put("seventeen", val: 17)
  trie.put("eighteen", val: 18)
  trie.put("nineteen", val: 19)
  trie.put("twenty", val: 20)
  trie.put("thirty", val: 30)
  trie.put("forty", val: 40)
  trie.put("fifty", val: 50)
  trie.put("sixty", val: 60)
  trie.put("seventy", val: 70)
  trie.put("eighty", val: 80)
  trie.put("ninety", val: 90)
  trie.put("dozen", val: 12)
  trie.put("hundred", val: 100)
  trie.put("thousand", val: 1_000)
  trie.put("million", val: 1_000_000)
  trie.put("billion", val: 1_000_000_000)
  trie.put("trillion", val: 1_000_000_000_000)
  
  return trie
}()

public func wordNumber() -> Parser<Double> {
  return consumeTrailingWhitespace(choice(numericNumber(), always(1))) >>= { coefficient in
  return many1(consumeTrailing(matchTrie(numberTrie), many(choice(whitespace(), char("-"))))) >>= { n in
    return always(n.reduce(coefficient, combine: {
      if ($0 <= $1) {
        return $0 * $1
      } else {
        return $0 + $1
      }
    }))
  }}
}

public func number() -> Parser<Double> {
  return choice(wordNumber(), numericNumber())
}

