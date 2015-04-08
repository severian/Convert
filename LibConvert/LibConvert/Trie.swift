//
//  Trie.swift
//  Convert
//
//  Created by James Baird on 4/7/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

struct TrieEdge {
  let edge: Character
  let node: TrieNode
}

public class TrieNode {
  var terminal: Bool = false
  var children = [TrieEdge]()
  
  class func fromStrings(strings: [String]) -> TrieNode {
    let t = TrieNode()
    for s in strings {
      t.insert(s)
    }
    return t
  }
  
  private func childForChar(c: Character) -> TrieNode? {
    for child in children {
      if c == child.edge {
        return child.node
      }
    }
    return nil
  }
  
  func find(state: InputState) -> InputState? {
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
    
    return node.terminal ? s : nil
  }
  
  func insert(s: String) {
    var node = self
    var i = s.startIndex
    
    while i < s.endIndex {
      if let child = node.childForChar(s[i]) {
        node = child
        i = advance(i, 1)
      } else {
        break
      }
    }
    
    while i < s.endIndex {
      let newNode = TrieNode()
      node.children.append(TrieEdge(edge: s[i], node: newNode))
      node = newNode
      i = advance(i, 1)
    }
    
    node.terminal = true
  }
}

public typealias Trie = TrieNode
