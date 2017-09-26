//
//  ReviewsViewController.swift
//  Gerrit-Check
//
//  Created by Tim Mok on 2017-05-31.
//  Copyright © 2017 Tim Mok. All rights reserved.
//

import Cocoa

class ReviewsViewController: ViewController, NSUserNotificationCenterDelegate {
  @IBOutlet weak var server: NSTextField!
  @IBOutlet weak var user: NSTextField!
  @IBOutlet weak var project: NSTextField!
  
  let projectKey = "project"
  let serverKey = "server"
  let userKey = "user"
  
  @IBAction func apply(_ sender: Any) {
    UserDefaults.standard.setValue(server.stringValue, forKey: serverKey)
    UserDefaults.standard.setValue(project.stringValue, forKey: projectKey)
    UserDefaults.standard.setValue(user.stringValue, forKey: userKey)
    model.applyChanges(server: server.stringValue, project: project.stringValue, user: user.stringValue)
    update()
    self.view.window?.close()
  }
  
  @IBAction func quit(_ sender: Any) {
    NSApplication.shared().terminate(sender)
  }
  
  var pendingReviews : Int = 0 {
    didSet {
      if (pendingReviews == 0) {
        resetIcon()
        return
      }
      let title = "Pending Reviews"
      let commitDescriptor = pendingReviews > 1 ? "commits" : "commit"
      let description = "\(pendingReviews) \(commitDescriptor) to review"
      let image = NSImage(named: "Pending")
      scheduleNotification(title: title, description: description, image: image!)
    }
  }
  var submittableReviews : Int = 0 {
    didSet {
      if (submittableReviews == 0) {
        resetIcon()
        return
      }
      let title = "Ready to submit"
      let commitDescriptor = pendingReviews > 1 ? "commits" : "commit"
      let description = "\(submittableReviews) \(commitDescriptor) ready to submit"
      let image = NSImage(named: "Ready")
      scheduleNotification(title: title, description: description, image: image!)
    }
  }
  var model : ReviewsModel = ReviewsModel()
  var refreshTimer : Timer!
  var statusItem : NSStatusItem!
  
  func resetIcon() {
    self.statusItem.button?.image = NSImage(named: "StatusIcon")
  }
  
  func scheduleNotification(title: String, description: String, image: NSImage) {
    let notification = NSUserNotification()
    
    notification.title = title
    notification.informativeText = description
    self.statusItem.button?.image = image
    
    NSUserNotificationCenter.default.scheduleNotification(notification)
    NSUserNotificationCenter.default.delegate = self
  }
  
  func update() {
    model.updateModel(sender: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    project.stringValue = model.project
    user.stringValue = model.user
    server.stringValue = model.server
  }
  
  func setup(statusItem: NSStatusItem) {
    model = ReviewsModel()
    let defaults = UserDefaults.standard
    if let serverText = defaults.string(forKey: serverKey) {
      model.server = serverText
    }
    if let projectText = defaults.string(forKey: projectKey) {
      model.project = projectText
    }
    if let userText = defaults.string(forKey: userKey) {
      model.user = userText
    }
    
    self.statusItem = statusItem
    update()
    refreshTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(refresh(sender:)), userInfo: nil, repeats: true)
  }
  
  func refresh(sender: Any) {
    update()
  }
  
  func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
    return true
  }
}

// MARK: Actions

extension ReviewsViewController {
}
