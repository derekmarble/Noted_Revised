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

class ConversionViewController: UIViewController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var recognizedTextView: UITextView!
    
    var upload: Upload!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        recognizeText(imageWithText: imageView.image)
    }
    
    func updateFromUserInterface() {
        upload.titleOrDescription = fileNameTextField.text ?? ""
        upload.image = imageView.image!
       
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
    
    
//    func convert(imageWithText: UIImage) {
//        guard let cgImage = imageWithText.cgImage else {return}
//        // creating request with cgImage
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        let request = VNRecognizeTextRequest { request, error in
//            guard let observations = (request.results ?? [VNObservation()]) as? [VNRecognizedTextObservation], error == nil else {return}
//            let text = observations.compactMap({$0.topCandidates(1).first?.string}).joined(separator: ", ")
//            print(text) // text we get from image
//        }
//        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
//        do {
//            try handler.perform([request])
//        } catch {
//            print("Error performing request")
//        }
//    }
}
    

