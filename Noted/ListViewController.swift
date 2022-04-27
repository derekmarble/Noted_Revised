//
//  ListViewController.swift
//  Noted
//
//  Created by Derek Marble on 4/25/22.
//

import UIKit
import Firebase
import FirebaseAuthUI
import GoogleSignIn

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var imagePickerController = UIImagePickerController()
    var upload: Upload!
    var uploads: Uploads!
    var photo: Photo!
    var photos: Photos!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploads = Uploads()
        tableView.delegate = self
        tableView.dataSource = self
        imagePickerController.delegate = self
        if upload == nil {
            upload = Upload()
        }
        photos = Photos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        uploads.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "AddImage":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ConversionViewController
            destination.photo = self.photo
        case "ShowImageAndText":
            let destination = segue.destination as! ConversionViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.upload = uploads.uploadArray[selectedIndexPath.row]
        default:
            print("Could not find a segue for that identifier")
        }
    }
    
    
    
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        cameraOrLibraryAlert()
    }
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
    }
    
    
}
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploads.uploadArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UploadTableViewCell
        cell.upload = uploads.uploadArray[indexPath.row]
        return cell
    }
}

extension ListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        photo = Photo()
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = originalImage
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "AddImage", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            self.oneButtonAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}

