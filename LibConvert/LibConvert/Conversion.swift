//
//  Convert.swift
//  LibConvert
//
//  Created by James Baird on 4/11/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public struct UnitConversion {
  public let from: Quantity
  public let to: Unit
  
  public func convert() -> Double {
    return (from.unit.val.factor / to.factor) * from.value.val
  }
  
  public func isValid() -> Bool {
    return from.unit.val.unitType == to.unitType
  }
}

public func conversionParser() -> Parser<UnitConversion> {
  let quantity = consumeTrailing(quantityParser(), many(whitespace()))
  let preposition = maybe(choice(string("to"), string("in"), string("="))) >>= { _ in many(whitespace()) }

  return quantity >>= { from in
  return preposition >>= { _ in
  return unitParser() >>= { to in
    return always(UnitConversion(from: from, to: to))
  }}}
}

