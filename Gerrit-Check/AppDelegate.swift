//
//  AppDelegate.swift
//  Gerrit-Check
//
//  Created by Tim Mok on 2017-05-31.
//  Copyright © 2017 Tim Mok. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
  let popover = NSPopover()
  
  var eventMonitor: EventMonitor?
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let appImage = NSImage(named: "StatusIcon")
    NSApp.hide(self)
    NSApp.applicationIconImage = appImage
    if let button = statusItem.button {
      button.image = appImage
      button.action = #selector(togglePopover)
    }
    
    let contentViewController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
    popover.contentViewController = contentViewController
    
    contentViewController?.setup(statusItem: statusItem)
    
    eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
      if self.popover.isShown {
        self.closePopover(sender: event!)
      }
    }
    eventMonitor?.start()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }

  func terminate(sender: NSMenuItem) {
    NSApp.terminate(self)
  }
  
  func showPopover(sender: AnyObject) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
  }
  
  func closePopover(sender: AnyObject) {
    popover.performClose(sender)
  }
  
  func togglePopover(sender: AnyObject) {
    if popover.isShown {
      closePopover(sender: sender)
    } else {
      showPopover(sender: sender)
    }
  }
  
}

