//
//  AppStore.swift
//  Convert
//
//  Created by James Baird on 4/12/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation
import LibConvert

private let storeChangedNotification = "AppStore.storeChangedNotification"

private let _instance = AppStore()

struct AppState {
  let query: String
  let parsed: Either<UnitConversion, QuantityPrefix>?
}

typealias AppStateObserver = AppState -> ()

class AppStore {
  static let sharedInstance = _instance
  
  private (set) var state: AppState
  
  init() {
    state = AppState(query: "", parsed: nil)
  }
  
  func updateQuery(newQuery: String) {
    let parser = either(conversionParser(), quantityPrefixParser())
    let parsed = run(parser, newQuery)?.val
    state = AppState(query: newQuery, parsed: parsed)
    emitChange()
  }
  
  func updateFromUnit(unit: Unit) {
    if let p = state.parsed {
      switch p {
      case .Right(let quantity):
        let start = quantity.value.candidates.pos
        let end = advance(start, count(quantity.value.candidates.source))
        var query = state.query
        query.replaceRange(start..<end, with: unit.name)
        
        updateQuery(query)
      default:
        break
      }
    }
  }
  
  func addObserver(observer: AppStateObserver) -> NSObjectProtocol {
    return NSNotificationCenter.defaultCenter().addObserverForName(
      storeChangedNotification,
      object: self,
      queue: nil,
      usingBlock: { _ in observer(self.state) })
  }
  
  func removeObserver(token: NSObjectProtocol) {
    NSNotificationCenter.defaultCenter().removeObserver(token, name: storeChangedNotification, object: self)
  }
  
  private func emitChange() {
    NSNotificationCenter.defaultCenter().postNotificationName(storeChangedNotification, object: self, userInfo: nil)
  }
}