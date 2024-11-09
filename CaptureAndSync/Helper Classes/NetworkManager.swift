//
//  NetworkManager.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import Foundation
import RealmSwift

// A singleton class to handle image upload functionality
class NetworkManager: NSObject {
    // Shared instance for singleton pattern
    static let shared = NetworkManager()
    
    // Private initializer to enforce the singleton pattern
    private override init() {}
    
    // Dictionary to store progress handlers by task identifier
    private var progressHandlers = [Int : (Double) -> Void]()
    
    // Method to upload a captured image to the server
    func uploadImage(capturedImage: CapturedImage){
        // Update the image status to "Uploading" in the database
        self.updateStatus(capturedImage, status: .Uploading)
        
        // Ensure the URL for the API endpoint is valid
        guard let url = URL(string: "https://www.clippr.ai/api/upload") else {
            print("Invalid url")
            return
        }
        
        // Generate a unique boundary for the multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Create a URL session for handling the network request
        let session = URLSession(configuration: .default,
                                 delegate: self,  // Set the current instance as the delegate for session events
                                 delegateQueue: .main)
        
        // Prepare the URL request for the image upload
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the content type for the request to multipart/form-data with the boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the request body and append the image data
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(capturedImage.imageName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(capturedImage.imageData)
        body.append("\r\n--\(boundary)--\r\n")
        
        // Set the body to the request
        request.httpBody = body
        
        // Create a data task to send the request and handle the response
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                // Handle any errors that occur during the upload
                print("Error: \(error.localizedDescription)")
                self.updateStatus(capturedImage, status: .Failed)
                return
            }
            
            // Check the response status code
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
                // If status code is 200, update the status to "Uploaded"
                if response.statusCode == 200 {
                    self.updateStatus(capturedImage, status: .Uploaded)
                }
            }
            
            // Print the response data (for debugging purposes)
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
        }
        
        // Store the progress handler for the task identifier
        progressHandlers[task.taskIdentifier] = { [weak self] progress in
            self?.updateStatus(capturedImage, progress: progress)
        }
        
        // Start the task
        task.resume()
    }
    
    // Method to update the status of the captured image in the database
    func updateStatus(_ capturedImage: CapturedImage, status: UploadStatus? = nil, progress: Double? = nil){
        // Show a toast message when the upload is completed
        if status == .Uploaded {
            ToastManager.shared.showToast(message: "Upload completed")
        }
        
        // Update the status and/or progress in the Realm database
        DispatchQueue.main.async {
            let realm = try! Realm()
            try? realm.write {
                if let status = status {
                    capturedImage.uploadStatus = status
                }
                if let progress = progress {
                    capturedImage.uploadProgress = progress
                }
            }
        }
    }
}

// Conformance to URLSessionTaskDelegate to handle progress updates
extension NetworkManager : URLSessionTaskDelegate {
    
    // Method to handle the progress of the uploaded data
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        // Calculate the upload progress as a percentage
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        
        // Retrieve the progress handler for this task and call it with the new progress
        let handler = progressHandlers[task.taskIdentifier]
        
        // Print the upload progress (for debugging purposes)
        print("Upload progress: \(progress * 100)%")
        
        // Execute the progress handler, if available
        handler?(progress)
    }
}
