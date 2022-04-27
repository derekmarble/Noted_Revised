//
//  Uploads.swift
//  Noted
//
//  Created by Derek Marble on 4/27/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Uploads {
    var uploadArray: [Upload] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("uploads").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.uploadArray = [] // clean out existing spot array since new data will load
            //there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                //you'll have to make sure you have a dictionary initializer in the singular class
                let upload = Upload(dictionary: document.data())
                upload.documentID = document.documentID
                self.uploadArray.append(upload)
            }
            completed()
        }
        
    }
}
