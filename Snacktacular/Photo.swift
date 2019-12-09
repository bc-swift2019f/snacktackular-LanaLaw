//
//  Photo.swift
//  Snacktacular
//
//  Created by Ellana Lawrence on 11/29/19.
//  Copyright © 2019 Ellana Lawrence. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String
    var dictionary : [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        // let date = dictionary["date"] as! Date? ?? Date()
        
      //  let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
     //   let date = Date(timeIntervalSince1970: timeIntervalDate)
        print(dictionary["date"]!)
        print(type(of: dictionary["date"]!))
        let timeIntervalDate = dictionary["date"] as! Timestamp
        let date: Date = timeIntervalDate.dateValue()
      //  let date: Date = dictionary["date"] as! Date
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> () ) {
        print("Saving")
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo.image to a data type so it can be saved by firebase storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("***ERROR: could not convert image to data format")
            return completed(false)
        }
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        documentUUID = UUID().uuidString // generate a unique ID to use for the photo image's name
        //create a ref to upload storage to spot.documentID's folder (bucket), with the name we created
        
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetadata)
        {metadata, error in
            guard error == nil else {
                print("***ERROR during .putData storage upload for reference \(storageRef). Error: \(error!)")
                return
            }
            print("upload worked! Metadata is \(metadata)")
        }
        
        
        
        uploadTask.observe(.success) { (snapshot) in
            
            // Create the dictionary representing the data to save
            let dataToSave = self.dictionary
            //this will either create a new doc at documentUUID or update the existing doc with that name
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { error in
                if let error = error {
                    print("***ERROR: updating document \(self.documentUUID) in spot \(spot.documentID)")
                    completed(false)
                } else {
                    print("^^^^Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        }
        
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("***ERROR: upload task for file \(self.documentUUID) failed, in spot \(spot.documentID)")
            }
            return completed(false)
        }
        

    }
}
