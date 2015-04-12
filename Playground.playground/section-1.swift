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



