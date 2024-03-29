//
//  Photos.swift
//  Snacktacular
//
//  Created by Ellana Lawrence on 11/29/19.
//  Copyright © 2019 Ellana Lawrence. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = [] // Same as: var photoArray: [Photo]()
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
}
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {

        guard spot.documentID != "" else {
            return
        }
        let storage = Storage.storage()
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("***ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            var loadAttempts = 0
            let storageRef = storage.reference().child(spot.documentID)
            //there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let photo = Photo (dictionary: document.data())
                photo.documentUUID = document.documentID
                self.photoArray.append(photo)
                
                
                //Loading in Firebase Storage images
                let photoRef = storageRef.child(photo.documentUUID)
                photoRef.getData(maxSize: 25 * 1025 * 1025){ data, error in
                    if let error = error {
                        print("*** ERROR: An error occurred while reading data from file ref: \(photoRef) \(error.localizedDescription)")
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count) {
                            return completed()
                        }
                    } else {
                        let image = UIImage(data: data!)
                        photo.image = image!
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count) {
                            return completed()
                    }
                
                    
                }
                
            }
        }
    }
}
}
