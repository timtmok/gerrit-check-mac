//
//  ReviewsModel.swift
//  Gerrit-Check
//
//  Created by Tim Mok on 2017-05-31.
//  Copyright © 2017 Tim Mok. All rights reserved.
//

import Foundation

class ReviewsModel {
  var server = ""
  var project = ""
  var user = ""
  var pendingReviews = 0
  var submittableReviews = 0
  var pendingReviewToPatchSets = [Int: Int]()
  
  func applyChanges(server: String, project: String, user: String) {
    self.server = server
    self.project = project
    self.user = user
  }
  
  func updateModel(sender: ReviewsViewController) {
    if (project.isEmpty || server.isEmpty || user.isEmpty) {
      return
    }
    checkPendingReviews(completionHandler: {result in
      var reviewCount = 0
      var newPatchSets = 0
      for review in (result as NSArray as! [NSDictionary]) {
        if let submittable = review["submittable"] as? Bool {
          if (!submittable) {
            reviewCount += 1
            let revisions = review["revisions"] as! NSDictionary
            let oldCount = self.pendingReviewToPatchSets.updateValue(revisions.count, forKey: review["_number"] as! Int)
            if (oldCount != revisions.count) {
              newPatchSets += 1
            }
          }
        }
      }
      if (reviewCount != self.pendingReviews || newPatchSets != 0) {
        self.pendingReviews = reviewCount
        sender.pendingReviews = self.pendingReviews
      }
    })
    checkOwnedReviews(completionHandler: {result in
      var submittableCount = 0
      for review in (result as NSArray as! [NSDictionary]) {
        if let submittable = review["submittable"] as? Bool {
          if (submittable) {
            submittableCount += 1
          }
        }
      }
      if (submittableCount != self.submittableReviews) {
        self.submittableReviews = submittableCount
        sender.submittableReviews = self.submittableReviews
      }
    })
  }
  
  func buildPendingQuery() -> URLRequest? {
    let query = ("\(server)/changes/?q=status:open+project:\(project)+reviewer:\(user)&o=all_revisions")
    guard let url = URL(string: query) else {
      print("Error: cannot create URL")
      return nil
    }
    return URLRequest(url: url)
  }
  
  func buildOwnedQuery() -> URLRequest? {
    let query = ("\(server)/changes/?q=status:open+project:\(project)+owner:\(user)")
    guard let url = URL(string: query) else {
      print("Error: cannot create URL")
      return nil
    }
    return URLRequest(url: url)
  }
  
  func executeRequest(request: URLRequest, type: ReviewType, completionHandler: @escaping (_ result: NSArray) -> Void) -> Void {
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
      if response != nil {
        guard let responseData = data else {
          print("Error: did not receive data")
          return
        }
        let responseString: String? = String(data: responseData, encoding: String.Encoding.utf8)
        let responseDataClean = responseString?.replacingOccurrences(of: ")]}'", with: "") ?? "{}"
        guard let jsonData = responseDataClean.data(using: String.Encoding.utf8) else {
          print("Error converting back to JSON")
          return
        }
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! NSArray else {
          print("Error trying to convert data to JSON")
          return
        }
        completionHandler(jsonResponse)      }
      if let error = error {
        print(error)
      }
    }
    task.resume()
  }
  
  func checkOwnedReviews(completionHandler: @escaping (_ result: NSArray) -> Void) -> Void {
    let urlRequest = buildOwnedQuery()
    if (urlRequest == nil) {
      return
    }
    executeRequest(request: urlRequest!, type: ReviewType.pendingSubmission, completionHandler: completionHandler)
  }
  
  func checkPendingReviews(completionHandler: @escaping (_ result: NSArray) -> Void) -> Void {
    let urlRequest = buildPendingQuery()
    if (urlRequest == nil) {
      return
    }
    executeRequest(request: urlRequest!, type: ReviewType.pendingReview, completionHandler: completionHandler)
  }
}
