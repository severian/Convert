// Playground - noun: a place where people can play

import Foundation
import LibConvert

if let c = run(conversionParser(), "pounds in ounces")?.val {
  "\(c.from.value) \(c.from.unit.name) = \(c.convert()) \(c.to.name)"
}



