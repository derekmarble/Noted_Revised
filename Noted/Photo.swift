//
//  Photo.swift
//  Noted
//
//  Created by Derek Marble on 4/27/22.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var titleOrDescription: String
    var photoUserID: String
    var date: Date
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        
        return ["titleOrDescription": titleOrDescription, "photoUserID": photoUserID,"date": timeIntervalDate, "photoURL": photoURL, "documentID": documentID]
    }
    
    init(image: UIImage, titleOrDescription: String, photoUserID: String, date: Date, photoURL: String, documentID: String) {
        
        self.image = image
        self.titleOrDescription = titleOrDescription
        self.photoUserID = photoUserID
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(), titleOrDescription: "", photoUserID: photoUserID, date: Date(), photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let titleOrDescription = dictionary["titleOrDescription"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        
        self.init(image: UIImage(), titleOrDescription: titleOrDescription, photoUserID: photoUserID, date: date, photoURL: photoURL, documentID: "")
    }
    
    func saveData(upload: Upload, completion: @escaping (Bool) -> ()) {
        let storage = Storage.storage()
        //convert photo.image to a Data Type so that it can be saved in Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("Error: could not convert photo.image to data")
            return
        }
        
        //create metadata so that we can see images in the firebase storage console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        //create a file name if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        //create a storage reference to upload this image file to the spot's folder
        let storageRef = storage.reference().child(upload.documentID).child(documentID)
        
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
                let ref = db.collection("spots").document(upload.documentID).collection("photos").document(self.documentID)
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
    
    func loadImage(upload: Upload, completion: @escaping(Bool) -> ()) {
        guard upload.documentID != "" else {
            print("Error: did not pass a valid spot into load image")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(upload.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error: an error occured while reading from file ref: \(storageRef). \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
        
    }
    func deleteData(upload: Upload, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("uploads").document(upload.documentID).collection("photos").document(documentID).delete { error in
            if let error = error {
                print("Error deleting photo document ID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                self.deleteImage(upload: upload)
                print("Successfully deleted document \(self.documentID)")
                    completion(true)
            }
        }
    }
    
    private func deleteImage(upload: Upload) {
        guard upload.documentID != "" else {
            print("Error: did not pass a valid spot into deleteImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(upload.documentID).child(documentID)
        storageRef.delete { error in
            if let error = error {
                print("Error: could not delete photo. \(error.localizedDescription)")
            } else {
                print("Photo successfully deleted")
            }
        }
    }
}


