//
//  Upload.swift
//  Noted
//
//  Created by Derek Marble on 4/27/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class Upload {
    var titleOrDescription: String
    var postingUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["titleOrDescription": titleOrDescription, "postingUserID": postingUserID, "date": timeIntervalDate]
    }
    
    init(titleOrDescription: String, postingUserID: String, date: Date, documentID: String) {
        self.titleOrDescription = titleOrDescription
        self.postingUserID = postingUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let postingUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(titleOrDescription: "", postingUserID: postingUserID, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let titleOrDescription = dictionary["titleOrDescription"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(titleOrDescription: titleOrDescription, postingUserID: postingUserID, date: date, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user Id
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("Error: could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        //create the dictionary representing the data we want to save
        let dataToSave: [String:Any] = self.dictionary
        //if we have a record, we'll have an ID, otherwise, .addDocument will create one
        if self.documentID == "" { //create a new document via .addDocument
            var ref: DocumentReference? = nil
            ref = db.collection("uploads").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("Error: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("💨Added document \(self.documentID)") // It worked!
                completion(true)
            }
        } else { //else save to the existing documentId with .setData
            let ref = db.collection("uploads").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("Error: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("💨Updated document \(self.documentID)") // It worked!
                completion(true)
                
            }
        }
    }
}
