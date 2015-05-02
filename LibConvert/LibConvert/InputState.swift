//
//  InputState.swift
//  Convert
//
//  Created by James Baird on 4/7/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public struct Result<A> {
  public let state: InputState
  public let val: A
}

struct MemoKey: Hashable {
  let name: String
  let pos: Int
  
  var hashValue: Int {
    return name.hashValue ^ pos
  }
}

func ==(lhs: MemoKey, rhs: MemoKey) -> Bool {
  return lhs.name == rhs.name && lhs.pos == rhs.pos
}

class MemoTable {
  var table = [MemoKey: Any?]()
}

class CountTable {
  var table = [MemoKey: Int]()
}

public struct InputState {
  let input: String
  let pos: String.Index
  
  let memotable: MemoTable
  let ctable: CountTable
  
  init(input: String) {
    self.input = input
    self.pos = input.startIndex
    self.memotable = MemoTable()
    self.ctable = CountTable()
  }
  
  init(input: String, pos: String.Index, memotable: MemoTable, ctable: CountTable) {
    self.input = input
    self.pos = pos
    self.memotable = memotable
    self.ctable = ctable
  }
  
  func advanceBy(n: Int) -> InputState {
    return InputState(input: input, pos: advance(pos, n), memotable: memotable, ctable: ctable)
  }
  
  func empty() -> Bool {
    return pos >= input.endIndex
  }
  
  func first() -> Character? {
    if !empty() {
      return input[pos]
    } else {
      return nil
    }
  }
  
  func consumedFrom(other: InputState) -> String {
    return input[pos..<other.pos]
  }
  
  func unconsumed() -> String {
    if !empty() {
      return input[pos..<input.endIndex]
    } else {
      return ""
    }
  }
  
  func unconsumedCount() -> Int {
    return distance(pos, input.endIndex)
  }
  
  func startsWith(str: String) -> Bool {
    if let r = input.rangeOfString(str, options: .allZeros, range: nil, locale: nil) {
      return r.startIndex == pos
    } else {
      return false
    }
  }
  
  func memoKey(name: String) -> MemoKey {
    return MemoKey(name: name, pos: distance(input.startIndex, pos))
  }
}

public struct ParsedInfo<T> {
  public let val: T
  public let source: String
  public let pos: String.Index
}
