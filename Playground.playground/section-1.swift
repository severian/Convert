// Playground - noun: a place where people can play

import Foundation
import LibConvert

if let c = run(conversionParser(), "pounds in meters")?.val {
  if c.isValid() {
    "\(c.from.value) \(c.from.unit.name) = \(c.convert()) \(c.to.name)"
  } else {
    "INVALID!"
  }
}


let trie = Trie<String>()
trie.put("foo", val: "foo")
trie.put("food", val: "food")
trie.put("good", val: "good")
trie.put("goodly", val: "goodly")
trie.put("goodlier", val: "goodlier")

let parser = findInTrie(trie)

run(parser, "goodl")?.val