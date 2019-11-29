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
}
