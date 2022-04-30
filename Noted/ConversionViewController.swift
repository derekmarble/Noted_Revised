//
//  ConversionViewController.swift
//  Noted
//
//  Created by Derek Marble on 4/25/22.
//

import UIKit
import MLKit
import AVKit
import Vision

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
} ()

class ConversionViewController: UIViewController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var recognizedTextView: UITextView!
    
    var upload: Upload!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap out of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if upload == nil {
            upload = Upload()
        }
        upload.loadImage {
            self.imageView.image = self.upload.image
        }
        updateUserInterface()
    }

    
    func updateUserInterface() {
        fileNameTextField.text = upload.titleOrDescription
        imageView.image = upload.image
        if upload.photoID == "" {
            recognizeText(imageWithText: imageView.image)
            shareBarButton.hide()
            deleteBarButton.hide()
            
        }
        recognizedTextView.text = upload.extractedText
    }
    
    func updateFromUserInterface() {
        upload.titleOrDescription = fileNameTextField.text ?? ""
        upload.image = imageView.image!
        upload.extractedText = recognizedTextView.text
       
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        upload.deleteData { success in
            if success {
                self.leaveViewController()
            } else {
                print("Delete Unsuccessful")
            }
        }
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        upload.saveData { (success) in
            if success {
                return
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
        upload.saveImage { success in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
        }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let activityVC = UIActivityViewController(activityItems: [upload.extractedText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    func recognizeText(imageWithText: UIImage?) {
        guard let cgImage = imageWithText?.cgImage else {return}
        
        //handle
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        //request
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string //getting the top candidate for the recognized text
            }).joined(separator: ", ")
            //text is now an array for recognized strings (this is what the compact map does)
            print(text)
            DispatchQueue.main.async {
                self.recognizedTextView.text = text
            }
        }
        
        //process the request if possible
        do {
            try handler.perform([request])
        } catch {
            print("Error processing the request: \(error.localizedDescription)")
        }
        
    }
}
    

