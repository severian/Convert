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
  
  private func childForChar(c: Character) -> Trie? {
    for child in children {
      if c == child.edge {
        return child.node
      }
    }
    return nil
  }
  
  private func getNode(key: String) -> (String.Index, Trie) {
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
    
    return (i, node)
  }
  
  public func get(key: String) -> (String, T)? {
    let (consumed, node) = getNode(key)
    
    return node.value.map { v in
      return (key[key.startIndex..<consumed], v)
    }
  }
  
  public func find(prefix: String) -> (String, [T]) {
    let (consumed, node) = getNode(prefix)
    
    if consumed > prefix.startIndex {
      var values = [T]()
      var nodeStack = [node]
      while count(nodeStack) > 0 {
        let currentNode = nodeStack.removeLast()
        if let v = currentNode.value {
          values.append(v)
        }
        nodeStack.extend(currentNode.children.map({ edge in return edge.node }))
      }
      return (prefix[prefix.startIndex..<consumed], values)
    } else {
      return ("", [T]())
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

public func findInTrie<A>(trie: Trie<A>) -> Parser<[A]> {
  return Parser<[A]> { state in
    let (matched, vals) = trie.find(state.unconsumed())
    
    if count(vals) > 0 {
      return Result(state: state.advanceBy(count(matched)), val: vals)
    } else {
      return nil
    }
  }
}
