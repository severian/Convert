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
  let conversion: UnitConversion?
}

typealias AppStateObserver = AppState -> ()

class AppStore {
  static let sharedInstance = _instance
  
  private (set) var state: AppState
  
  init() {
    state = AppState(query: "", conversion: nil)
  }
  
  func queryChanged(newQuery: String) {
    let conversion = run(conversionParser(), newQuery)?.val
    state = AppState(query: newQuery, conversion: conversion)
    emitChange()
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