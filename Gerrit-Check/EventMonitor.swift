//
//  EventMonitor.swift
//  Gerrit-Check
//
//  Created by Tim Mok on 2017-05-31.
//  Copyright © 2017 Tim Mok. All rights reserved.
//

import Foundation
import Cocoa

public class EventMonitor {
  private var monitor: Any?
  private let mask: NSEventMask
  private let handler: (NSEvent?) -> ()
  
  public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
    self.mask = mask
    self.handler = handler
  }
  
  deinit {
    stop()
  }
  
  public func start() {
    monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
  }
  
  public func stop() {
    if monitor != nil {
      NSEvent.removeMonitor(monitor!)
      monitor = nil
    }
  }
  
}
