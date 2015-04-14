//
//  Either.swift
//  LibConvert
//
//  Created by James Baird on 4/13/15.
//  Copyright (c) 2015 James Baird. All rights reserved.
//

import Foundation

public final class Box<T> {
  public let value: T
  
  public init(_ value: T) {
    self.value = value
  }
}

public enum Either<L,R> {
  case Left(Box<L>)
  case Right(Box<R>)
}

public func either<L,R>(left: Parser<L>, right: Parser<R>) -> Parser<Either<L,R>> {
  return Parser<Either<L,R>>() { state in
    if let l = left.parse(state) {
      return Result(state: l.state, val: .Left(Box(l.val)))
    } else if let r = right.parse(state) {
      return Result(state: r.state, val: .Right(Box(r.val)))
    } else {
      return nil
    }
  }
}