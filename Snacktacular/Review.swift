//
//  Review.swift
//  Snacktacular
//
//  Created by Ellana Lawrence on 11/21/19.
//  Copyright © 2019 Ellana Lawrence. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
//    var dictionary: [String: Any] {
//        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date, "documentID": documentID]
//    }
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date]
    }
    
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String
        print(dictionary["date"]!)
        let timestamp = dictionary["date"] as! Timestamp
        let date = timestamp.dateValue()
        // let date = dictionary["date"] as! Date? ?? Date()
//        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
//        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    
 
    
    
    
    func saveData (spot: Spot, completed: @escaping (Bool) -> () ) {
        print("Saving")
        let db = Firestore.firestore()
        
        // Create the dictionary representing the data to save
        let dataToSave = self.dictionary
        //if we have saved a record, we'll have a documentID
        if self.documentID != "" {
            print("Has document ID")
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { error in
                if let error = error {
                    print("***ERROR: updating document \(self.documentID) in spot \(spot.documentID)")
                    completed(false)
                } else {
                    print("^^^^Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            print("No document ID")
            var ref: DocumentReference? = nil //Let firestone create new documentID
            print("Adding document")
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("***ERROR: creating new document in spot  \(spot.documentID) for new review documentID \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^^ new document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
            print(ref!.documentID)
            print("This shouldn't print")
        }
    }
}
