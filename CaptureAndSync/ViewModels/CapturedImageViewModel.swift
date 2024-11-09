//
//  CapturedImageViewModel.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import Foundation
import RealmSwift
import AVFoundation

// ViewModel for managing interactions between views and the model (CapturedImage)
class CapturedImageViewModel: NSObject, ObservableObject {
    
    // Properties for managing the camera session and photo output
    var session: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Published array to store captured images for updating the UI
    @Published var capturedImages: [CapturedImage] = []
    
    // Delegate to handle capturing images
    private var cameraDelegate: CameraCaptureDelegate?
    
    // Initializer: sets up the camera session and checks for pending uploads in Realm
    override init() {
        super.init()
        startSession() // Set up the camera session
        let realm = try! Realm()
        capturedImages = realm.objects(CapturedImage.self).map({ image in
            // Re-attempt upload if status is not completed
            if image.uploadStatus != .Uploaded {
                uploadImageToServer(image)
            }
            return image
        })
    }
    
    // Function to initialize an AVCaptureSession
    func startSession() {
        session = AVCaptureSession()
        guard let session = session else { return }
        
        // Set up camera device and input
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Failed to set up camera input")
        }
        
        // Set up photo output
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        }
    }
    
    // Function to start the camera session
    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.startRunning()
        }
    }
    
    // Function to stop the camera session
    func stopRunning() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.stopRunning()
        }
    }
    
    // Function to capture an image and handle completion
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        
        // Delegate to handle the image after capture
        let delegate = CameraCaptureDelegate { [weak self] image in
            guard let self = self, let capturedImage = image else { return }
            
            // Save the captured image and related data
            if let imageData = capturedImage.jpegData(compressionQuality: 1.0) {
                let uri = self.saveImageToFileSystem(imageData: imageData)
                let name = "Image_\(Date().timeIntervalSince1970).jpg"
                let captureDate = Date()
                let uploadStatus: UploadStatus = .Pending
                
                // Create and save an image detail object
                let imageDetail = CapturedImage(uri: uri, imageName: name, captureDate: captureDate, imageData: imageData, uploadStatus: uploadStatus)
                
                self.saveImageDetails(imageDetail)
                
                DispatchQueue.main.async {
                    self.capturedImages.append(imageDetail) // Update UI
                }
                uploadImageToServer(imageDetail) // Start uploading the image
            }
            
            completion(image)
        }
        
        self.cameraDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: cameraDelegate!)
    }
    
    // Function to initiate uploading an image to the server
    func uploadImageToServer(_ image: CapturedImage){
        NetworkManager.shared.uploadImage(capturedImage: image)
    }
    
    // Function to save image data to the device’s file system
    func saveImageToFileSystem(imageData: Data) -> String {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Image_\(UUID().uuidString).jpg"  // Unique filename
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
            return fileURL.path
        } catch {
            print("Error saving image to file system: \(error)")
            return ""
        }
    }
    
    // Function to save image details in Realm database
    func saveImageDetails(_ imageDetail: CapturedImage) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(imageDetail)
            }
            print("Image details saved to Realm")
        } catch {
            print("Error saving image details to Realm: \(error)")
        }
    }
        
}

// Delegate class to handle captured photos and pass image data back to the main class
class CameraCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private var completion: (UIImage?) -> Void
    
    // Initializes with a completion handler
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    // Delegate method called when photo capture finishes
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        // Convert photo data to UIImage and pass it to the completion handler
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.completion(image)
            }
        }
    }
}
