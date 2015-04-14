//
//  ViewController.swift
//  Convert
//
//  Created by James Baird on 4/4/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import UIKit
import LibConvert

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  private var inputField: UITextField!
  private var conversionLabel: UILabel!
  
  private var fromUnitTableView: UITableView!
  private var quantityPrefix: QuantityPrefix?
  
  private var observerToken: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    inputField = UITextField()
    inputField.backgroundColor = UIColor.lightGrayColor()
    inputField.addTarget(self, action: "inputChanged", forControlEvents: .EditingChanged)
    
    conversionLabel = UILabel()
    conversionLabel.backgroundColor = UIColor.lightGrayColor()
    
    fromUnitTableView = UITableView(frame: CGRectZero, style: .Plain)
    fromUnitTableView.delegate = self
    fromUnitTableView.dataSource = self
    fromUnitTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UnitCell")
    
    view.addSubview(inputField)
    view.addSubview(conversionLabel)
    view.addSubview(fromUnitTableView)
    
    updateFromAppState(AppStore.sharedInstance.state)
  }
  
  @objc private func inputChanged() {
    AppStore.sharedInstance.updateQuery(inputField.text)
  }
  
  override func viewWillLayoutSubviews() {
    view.frame = UIScreen.mainScreen().bounds
    var rect = CGRectInset(self.view.bounds, 20, 50)
    
    var inputFrame = CGRectZero
    CGRectDivide(rect, &inputFrame, &rect, 40, .MinYEdge)
    inputField!.frame = inputFrame
    
    rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    
    fromUnitTableView.frame = rect
    
    var labelFrame = CGRectZero
    CGRectDivide(rect, &labelFrame, &rect, 40, .MinYEdge)
    conversionLabel!.frame = labelFrame
  }
  
  override func viewWillAppear(animated: Bool) {
    observerToken = AppStore.sharedInstance.addObserver({ state in self.updateFromAppState(state) })
  }
  
  override func viewDidAppear(animated: Bool) {
    inputField.becomeFirstResponder()
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
  
  private func updateFromConversion(conversion: UnitConversion?) {
    conversionLabel.text = textForConversion(conversion)
    conversionLabel.hidden = conversion == nil
  }
  
  private func updateFromQuantityPrefix(prefix: QuantityPrefix?) {
    quantityPrefix = prefix
    fromUnitTableView.reloadData()
    fromUnitTableView.hidden = prefix == nil
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let prefix = quantityPrefix {
      return count(prefix.candidates)
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("UnitCell", forIndexPath: indexPath) as! UITableViewCell
    cell.textLabel?.text = quantityPrefix!.candidates[indexPath.row].name
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let unit = quantityPrefix!.candidates[indexPath.row]
    let query = "\(quantityPrefix!.value) \(unit.name)"
    AppStore.sharedInstance.updateQuery(query)
  }
  
  private func updateFromAppState(state: AppState) {
    inputField.text = state.query
    
    var conversion: UnitConversion?
    var prefix: QuantityPrefix?
    
    if let parsed = state.parsed {
      switch parsed {
      case .Left(let l):
        conversion = l.value
      case .Right(let r):
        prefix = r.value
      }
    }
    
    updateFromConversion(conversion)
    updateFromQuantityPrefix(prefix)
  }

}

