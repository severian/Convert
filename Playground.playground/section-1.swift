// Playground - noun: a place where people can play

import Foundation
import LibConvert

let parser = either(conversionParser(), quantityPrefixParser())

if let val = run(parser, "10 mi")?.val {
  switch (val) {
  case .Left(let l):
    let c = l.value
    if c.isValid() {
      "\(c.from.value) \(c.from.unit.name) = \(c.convert()) \(c.to.name)"
    } else {
      "INVALID!"
    }
  case .Right(let r):
    let c = r.value
    let candidates = ", ".join(c.candidates.map { can in return can.name })
    "\(c.value) \(candidates)"
  }
  
}
