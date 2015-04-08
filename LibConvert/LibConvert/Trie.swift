//
//  Trie.swift
//  Convert
//
//  Created by James Baird on 4/7/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

struct TrieEdge<T> {
  let edge: Character
  let node: Trie<T>
}

public class Trie<T> {
  var value: T?
  var children = [TrieEdge<T>]()
  
  public init() { }
  
  func childForChar(c: Character) -> Trie? {
    for child in children {
      if c == child.edge {
        return child.node
      }
    }
    return nil
  }
  
  public func get(state: InputState) -> (T, InputState)? {
    var node = self
    var s = state
    while let c = s.first() {
      if let child = node.childForChar(c) {
        node = child
        s = s.advanceBy(1)
      } else {
        break
      }
    }
    
    if let v = node.value {
      return (v, s)
    } else {
      return nil
    }
  }
  
  public func put(key: String, val: T) {
    var node = self
    var i = key.startIndex
    
    while i < key.endIndex {
      if let child = node.childForChar(key[i]) {
        node = child
        i = advance(i, 1)
      } else {
        break
      }
    }
    
    while i < key.endIndex {
      let newNode = Trie()
      node.children.append(TrieEdge(edge: key[i], node: newNode))
      node = newNode
      i = advance(i, 1)
    }
    
    node.value = val
  }
}

