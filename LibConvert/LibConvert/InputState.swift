//
//  InputState.swift
//  Convert
//
//  Created by James Baird on 4/7/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public struct InputState {
  let input: String
  let pos: String.Index
  
  func advanceBy(n: Int) -> InputState {
    return InputState(input: input, pos: advance(pos, n))
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
  
  func startsWith(str: String) -> Bool {
    if let r = input.rangeOfString(str, options: .allZeros, range: nil, locale: nil) {
      return r.startIndex == pos
    } else {
      return false
    }
  }
}
