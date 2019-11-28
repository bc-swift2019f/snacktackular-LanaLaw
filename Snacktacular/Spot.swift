//
//  Spot.swift
//  Snacktacular
//
//  Created by Ellana Lawrence on 11/7/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit


class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID:  String
    var documentID: String
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var latitude:  CLLocationDegrees {
        return coordinate.latitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    var dictionary: [String: Any] {
        return ["name" : name, "address" : address, "longitude":  longitude, "latitude": latitude, "averageRating":  averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init () {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    
    convenience init(dictionary:[String:Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary ["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""

            
        
        
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData (completed: @escaping (Bool) -> () ) {
        print("Saving")
        let db = Firestore.firestore()
        
        
        //Grab User ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completed (false)
        }
        print("Got user ID")

        self.postingUserID = postingUserID
        // Create the dictionary representing the data to save
        let dataToSave = self.dictionary
        //if we have saved a record, we'll have a documentID
        if self.documentID != "" {
            print("Has document ID")
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("***ERROR: updating document \(self.documentID) \(error.localizedDescription)")
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
            ref = db.collection("spots").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("***ERROR: creating new document \(error.localizedDescription)")
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
