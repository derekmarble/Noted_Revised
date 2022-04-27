//
//  ConversionViewController.swift
//  Noted
//
//  Created by Derek Marble on 4/25/22.
//

import UIKit
import MLKit
import AVKit

class ConversionViewController: UIViewController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var recognizedTextView: UITextView!
    
    var upload: Upload!
    var photo: Photo!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if upload == nil {
            upload = Upload()
        }
        
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        fileNameTextField.text = upload.titleOrDescription
        imageView.image = photo.image
    }
    
    func updateFromUserInterface() {
        upload.titleOrDescription = fileNameTextField.text ?? ""
        photo.image = imageView.image!
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
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    

//    func imageOrientation( deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation {
//      switch deviceOrientation {
//      case .portrait:
//        return cameraPosition == .front ? .leftMirrored : .right
//      case .landscapeLeft:
//        return cameraPosition == .front ? .downMirrored : .up
//      case .portraitUpsideDown:
//        return cameraPosition == .front ? .rightMirrored : .left
//      case .landscapeRight:
//        return cameraPosition == .front ? .upMirrored : .down
//      case .faceDown, .faceUp, .unknown:
//        return .up
//      }
//    }
//
//    func processImageAndExtractText(image: UIImage) {
//        let textRecognizer = TextRecognizer.textRecognizer()
//        let visionImage = VisionImage(image: image)
//        textRecognizer.process(visionImage) { result, error in
//          guard error == nil, let result = result else {
//            // Error handling
//            return
//          }
//            let resultText = result.text
//            for block in result.blocks {
//                let blockText = block.text
//                let blockLanguages = block.recognizedLanguages
//                let blockCornerPoints = block.cornerPoints
//                let blockFrame = block.frame
//                for line in block.lines {
//                    let lineText = line.text
//                    let lineLanguages = line.recognizedLanguages
//                    let lineCornerPoints = line.cornerPoints
//                    let lineFrame = line.frame
//                    for element in line.elements {
//                        let elementText = element.text
//                        let elementCornerPoints = element.cornerPoints
//                        let elementFrame = element.frame
//                    }
//                }
//            }
//        }
//    }
}

