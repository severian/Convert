// Playground - noun: a place where people can play

import Foundation
import LibConvert

struct SiPrefix {
  let name: String
  let factor: Double
}

let siPrefixes = [
  SiPrefix(name: "yotta", factor: 10e24),
  SiPrefix(name: "zetta", factor: 10e21),
  SiPrefix(name: "exa", factor: 10e18),
  SiPrefix(name: "peta", factor: 10e15),
  SiPrefix(name: "tera", factor: 10e12),
  SiPrefix(name: "giga", factor: 10e9),
  SiPrefix(name: "mega", factor: 10e6),
  SiPrefix(name: "kilo", factor: 10e3),
  SiPrefix(name: "hecto", factor: 10e2),
  SiPrefix(name: "deca", factor: 10),
  
  SiPrefix(name: "deci", factor: 10e-1),
  SiPrefix(name: "centi", factor: 10e-2),
  SiPrefix(name: "milli", factor: 10e-3),
  SiPrefix(name: "micro", factor: 10e-6),
  SiPrefix(name: "nano", factor: 10e-9),
  SiPrefix(name: "pico", factor: 10e-12),
  SiPrefix(name: "femto", factor: 10e-15),
  SiPrefix(name: "atto", factor: 10e-18),
  SiPrefix(name: "zepto", factor: 10e-21),
  SiPrefix(name: "yocto", factor: 10e-24)
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

let quantities = [
  "length": makeUnits(Unit(name: "meter", factor: 1.0, alternateNames: ["m"]), [
    Unit(name: "thou", factor: 2.54e-5, alternateNames: ["mil"]),
    Unit(name: "inch", factor: 0.0254, alternateNames: ["inches", "in", "\""]),
    Unit(name: "yard", factor: 0.9144, alternateNames: []),
    Unit(name: "foot", factor: 0.3048, alternateNames: ["feet", "ft", "'"]),
    Unit(name: "mile", factor: 1609.344, alternateNames: []),
    Unit(name: "light year", factor: 9.4605284e15, alternateNames: ["light-year", "lightyear", "ly", "l.y."]),
    Unit(name: "parsec", factor: 3.08567758e16, alternateNames: [])
  ])
]





