//
//  Photos.swift
//  Noted
//
//  Created by Derek Marble on 4/27/22.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(upload: Upload, completed: @escaping () -> ()) {
        guard upload.documentID != "" else {
            return
        }
        db.collection("uploads").document(upload.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = [] // clean out existing photoArray since new data will load
            //there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                //you'll have to make sure you have a dictionary initializer in the singular class
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
        }
        
    }
}


