//
//  ViewController.swift
//  Convert
//
//  Created by James Baird on 4/4/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import UIKit
import LibConvert

class ViewController: UIViewController {
  
  private var inputField: UITextField?
  private var conversionLabel: UILabel?
  
  private var observerToken: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    inputField = UITextField()
    inputField!.backgroundColor = UIColor.lightGrayColor()
    inputField!.addTarget(self, action: "inputChanged", forControlEvents: .EditingChanged)
    
    conversionLabel = UILabel()
    conversionLabel!.backgroundColor = UIColor.lightGrayColor()
    
    view.addSubview(inputField!)
    view.addSubview(conversionLabel!)
    
    updateFromAppState(AppStore.sharedInstance.state)
  }
  
  @objc private func inputChanged() {
    AppStore.sharedInstance.queryChanged(inputField!.text)
  }
  
  override func viewWillLayoutSubviews() {
    view.frame = UIScreen.mainScreen().bounds
    var rect = CGRectInset(self.view.bounds, 20, 50)
    
    var inputFrame = CGRectZero
    CGRectDivide(rect, &inputFrame, &rect, 40, .MinYEdge)
    inputField!.frame = inputFrame
    
    rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    
    var labelFrame = CGRectZero
    CGRectDivide(rect, &labelFrame, &rect, 40, .MinYEdge)
    conversionLabel!.frame = labelFrame
  }
  
  override func viewWillAppear(animated: Bool) {
    observerToken = AppStore.sharedInstance.addObserver({ state in self.updateFromAppState(state) })
  }
  
  override func viewDidAppear(animated: Bool) {
    inputField!.becomeFirstResponder()
  }
  
  override func viewWillDisappear(animated: Bool) {
    AppStore.sharedInstance.removeObserver(observerToken!)
  }
  
  private func textForConversion(conversion: UnitConversion?) -> String {
    if let c = conversion {
      if c.isValid() {
        return "\(c.from.value) \(c.from.unit.name) = \(c.convert()) \(c.to.name)"
      } else {
        return "INVALID!"
      }
    } else {
      return ""
    }
  }
  
  private func updateFromAppState(state: AppState) {
    NSLog("update from app state")
    inputField?.text = state.query
    conversionLabel?.text = textForConversion(state.conversion)
  }

}

