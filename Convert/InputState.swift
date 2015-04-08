//
//  InputState.swift
//  Convert
//
//  Created by James Baird on 4/7/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

struct InputState {
  let input: String
  let pos: String.Index
  
  func advanceBy(n: Int) -> InputState {
    return InputState(input: input, pos: advance(pos, 1))
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
}
