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
  
  public func get(key: String) -> (String, T)? {
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
    
    return node.value.map { v in
      return (key[key.startIndex..<i], v)
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

public func matchTrie<A>(trie: Trie<A>) -> Parser<A> {
  return Parser<A> { state in
    if let (matched, val) = trie.get(state.unconsumed()) {
      return Result(state: state.advanceBy(count(matched)), val: val)
    } else {
      return nil
    }
  }
}

