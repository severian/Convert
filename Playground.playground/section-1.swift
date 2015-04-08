// Playground - noun: a place where people can play

import Foundation
import LibConvert

struct SiPrefix {
  let name: String
  let factor: Double
}

let siPrefixes = [
  SiPrefix(name: "yotta", factor: pow(10, 24)),
  SiPrefix(name: "zetta", factor: pow(10, 21)),
  SiPrefix(name: "exa", factor: pow(10, 18)),
  SiPrefix(name: "peta", factor: pow(10, 15)),
  SiPrefix(name: "tera", factor: pow(10, 12)),
  SiPrefix(name: "giga", factor: pow(10, 9)),
  SiPrefix(name: "mega", factor: pow(10, 6)),
  SiPrefix(name: "kilo", factor: pow(10, 3)),
  SiPrefix(name: "hecto", factor: pow(10, 2)),
  SiPrefix(name: "deca", factor: 10),
  
  SiPrefix(name: "deci", factor: pow(10, -1)),
  SiPrefix(name: "centi", factor: pow(10, -2)),
  SiPrefix(name: "milli", factor: pow(10, -3)),
  SiPrefix(name: "micro", factor: pow(10, -6)),
  SiPrefix(name: "nano", factor: pow(10, -9)),
  SiPrefix(name: "pico", factor: pow(10, -12)),
  SiPrefix(name: "femto", factor: pow(10, -15)),
  SiPrefix(name: "atto", factor: pow(10, -18)),
  SiPrefix(name: "zepto", factor: pow(10, -21)),
  SiPrefix(name: "yocto", factor: pow(10, -24))
]

struct Unit {
  let name: String
  let factor: Double
  let alternateNames: [String]
}

func makeUnits(baseSIUnit: Unit, otherUnits: [Unit]) -> [Unit] {
  var units = otherUnits
  units.append(baseSIUnit)
  for prefix in siPrefixes {
    units.append(Unit(name: prefix.name + baseSIUnit.name, factor: prefix.factor, alternateNames: []))
  }
  return units
}


let length = makeUnits(Unit(name: "meter", factor: 1.0, alternateNames: ["m"]), [
  Unit(name: "thou", factor: 2.54e-5, alternateNames: ["mil"]),
  Unit(name: "inch", factor: 0.0254, alternateNames: ["inches", "in", "\""]),
  Unit(name: "yard", factor: 0.9144, alternateNames: []),
  Unit(name: "foot", factor: 0.3048, alternateNames: ["feet", "ft", "'"]),
  Unit(name: "mile", factor: 1609.344, alternateNames: []),
  Unit(name: "light year", factor: 9.4605284e15, alternateNames: ["light-year", "lightyear", "ly", "l.y."]),
  Unit(name: "parsec", factor: 3.08567758e16, alternateNames: [])
])

let trie = Trie<Unit>()
for unit in length {
  trie.put(unit.name, val: unit)
  for name in unit.alternateNames {
    trie.put(name, val: unit)
  }
}

struct UnitConversion {
  let quantity: Double
  let from: Unit
  let to: Unit
  
  func convert() -> Double {
    return (from.factor / to.factor) * quantity
  }
}

let quantity = choice(number(), always(1))
let unit: Parser<Unit> = matchTrie(trie) >>! option(char("s"))
let ignore = many(choice(char(" "), char(".")))
let preposition = option(choice(string("to"), string("=")))

let conversion: Parser<UnitConversion> =
  quantity >>! ignore >>> { quantity in
  return unit >>! ignore >>! preposition >>! ignore >>> { from in
  return unit >>> { to in
    return always(UnitConversion(quantity: quantity, from: from, to: to))
  }}}

if let c = run(conversion, "50 centimeters to miles")?.val {
  "\(c.quantity) \(c.from.name) = \(c.convert()) \(c.to.name)"
}

if let c = run(conversion, "light years to miles")?.val {
  "\(c.quantity) \(c.from.name) = \(c.convert()) \(c.to.name)"
}
