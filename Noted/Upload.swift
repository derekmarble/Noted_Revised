//
//  Upload.swift
//  Noted
//
//  Created by Derek Marble on 4/27/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class Upload {
    var titleOrDescription: String
    var postingUserID: String
    var image: UIImage
    var photoURL: String
    var photoID: String
    var extractedText: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["titleOrDescription": titleOrDescription, "postingUserID": postingUserID, "photoURL": photoURL, "photoID": photoID, "extractedText": extractedText, "date": timeIntervalDate]
    }
    
    init(titleOrDescription: String, postingUserID: String, image: UIImage, photoURL: String, photoID: String, extractedText: String, date: Date, documentID: String) {
        self.titleOrDescription = titleOrDescription
        self.postingUserID = postingUserID
        self.image = image
        self.photoURL = photoURL
        self.photoID = photoID
        self.extractedText = extractedText
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let postingUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(titleOrDescription: "", postingUserID: postingUserID, image: UIImage(), photoURL: "", photoID: "", extractedText: "", date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let titleOrDescription = dictionary["titleOrDescription"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        let photoID = dictionary["photoID"] as! String? ?? ""
        let extractedText = dictionary["extractedText"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(titleOrDescription: titleOrDescription, postingUserID: postingUserID, image: UIImage(), photoURL: photoURL, photoID: photoID, extractedText: extractedText, date: date, documentID: "")
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
    func saveImage(completion: @escaping (Bool) -> ()) {
        let storage = Storage.storage()
        //convert upload.image to a Data Type so that it can be saved in Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("Error: could not convert photo.image to data")
            return
        }
        
        //create metadata so that we can see images in the firebase storage console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        //create a file name if necessary
        if photoID == "" {
            photoID = UUID().uuidString
        }
        
        //create a storage reference to upload this image file to the upload's folder
        let storageRef = storage.reference().child(self.documentID).child(photoID)
        print("the storage reference for this saveData function is \(storageRef)")
        
        //create an upload task
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { metaData, error in
            if let error = error {
                print("Error: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
                
            }
        }
        uploadTask.observe(.success) { snapshot in
            print("Upload to Firebase Storage was Successful")
            
            storageRef.downloadURL { url, error in
                guard error == nil else {
                    print("Error: couldn't create a download url. \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("Error: url was nil")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                //create the dictionary representing the data we want to save
                let db = Firestore.firestore()
                let dataToSave = self.dictionary
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
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("ERROR: \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(completion: @escaping () -> ()) {
        guard self.documentID != "" else {
            print("Error: did not pass a valid upload into load image")
            return
        }
        print("The document id for this upload is \(self.documentID)")
        print("The photo ID for this upload is \(self.photoID)")
        let storage = Storage.storage()
        let storageRef = storage.reference().child(photoID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error: an error occured while reading from file ref: \(storageRef). \(error.localizedDescription)")
                return completion()
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion()
            }
        }
        
    }
    func deleteData(completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("uploads").document(self.documentID).delete { error in
            if let error = error {
                print("Error deleting photo document ID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted document \(self.documentID)")
                    completion(true)
            }
        }
    }
//
//    private func deleteImage() {
//        guard self.documentID != "" else {
//            print("Error: did not pass a valid upload into deleteImage")
//            return
//        }
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child(self.documentID).child(self.photoID)
//        storageRef.delete { error in
//            if let error = error {
//                print("Error: could not delete photo. \(error.localizedDescription)")
//            } else {
//                print("Photo successfully deleted")
//            }
//        }
//    }
}
