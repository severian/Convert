//
//  Unit.swift
//  LibConvert
//
//  Created by James Baird on 4/11/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public enum UnitType {
  case Length
  case Weight
}

public struct Unit {
  public let name: String
  public let unitType: UnitType
  public let factor: Double
  public let alternateNames: [String]
}

public struct Quantity {
  public let value: Double
  public let unit: Unit
}

public struct QuantityPrefix {
  public let value: Double
  public let candidates: [Unit]
}

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

struct UnitSpec {
  let name: String
  let factor: Double
  let alternateNames: [String]
}

func unitFromSpec(spec: UnitSpec, unitType: UnitType) -> Unit {
  return Unit(name: spec.name, unitType: unitType, factor: spec.factor, alternateNames: spec.alternateNames)
}

func unitsFromSpecs(unitType: UnitType, baseSIUnit: UnitSpec, otherUnits: [UnitSpec]) -> [Unit] {
  var units = [Unit]()
  units.append(unitFromSpec(baseSIUnit, unitType))
  for prefix in siPrefixes {
    let prefixSpec = UnitSpec(name: prefix.name + baseSIUnit.name, factor: prefix.factor, alternateNames: [])
    units.append(unitFromSpec(prefixSpec, unitType))
  }
  for unit in otherUnits {
    units.append(unitFromSpec(unit, unitType))
  }
  return units
}

let length = unitsFromSpecs(
  .Length,
  UnitSpec(name: "meter", factor: 1.0, alternateNames: ["m"]),
  [
    UnitSpec(name: "thou", factor: 2.54e-5, alternateNames: ["mil"]),
    UnitSpec(name: "inch", factor: 0.0254, alternateNames: ["inches", "in", "\""]),
    UnitSpec(name: "yard", factor: 0.9144, alternateNames: []),
    UnitSpec(name: "foot", factor: 0.3048, alternateNames: ["feet", "ft", "'"]),
    UnitSpec(name: "mile", factor: 1609.344, alternateNames: []),
    UnitSpec(name: "light year", factor: 9.4605284e15, alternateNames: ["light-year", "lightyear", "ly", "l.y."]),
    UnitSpec(name: "parsec", factor: 3.08567758e16, alternateNames: [])
  ]
)

let weight = unitsFromSpecs(
  .Weight,
  UnitSpec(name: "gram", factor: 1.0, alternateNames: ["g"]),
  [
    UnitSpec(name: "pound", factor: 453.59237, alternateNames: ["pound", "lb"]),
    UnitSpec(name: "ton", factor: 9071847.4, alternateNames: ["tonne"]),
    UnitSpec(name: "ounce", factor: 28.349523125, alternateNames: ["oz"])
  ]
)

let unitTrie: Trie<Unit> = {
  let trie = Trie<Unit>()
  for unit in length {
    trie.put(unit.name, val: unit)
    for name in unit.alternateNames {
      trie.put(name, val: unit)
    }
  }
  
  for unit in weight {
    trie.put(unit.name, val: unit)
    for name in unit.alternateNames {
      trie.put(name, val: unit)
    }
  }
  
  return trie
}()

let quantityValueParser: Parser<Double> = consumeTrailing(choice(number(), always(1)), many(whitespace()))

public func unitParser() -> Parser<Unit> {
  return consumeTrailing(matchTrie(unitTrie), maybe(char("s")))
}

public func unitPrefixParser() -> Parser<[Unit]> {
  return consumeTrailing(findInTrie(unitTrie), maybe(char("s")))
}

public func quantityParser() -> Parser<Quantity> {
  return quantityValueParser >>= { q in
  return unitParser() >>= { u in
    return always(Quantity(value: q, unit: u))
  }}
}

public func quantityPrefixParser() -> Parser<QuantityPrefix> {
  return quantityValueParser >>= { q in
  return unitPrefixParser() >>= { u in
    return always(QuantityPrefix(value: q, candidates: u))
  }}
}


