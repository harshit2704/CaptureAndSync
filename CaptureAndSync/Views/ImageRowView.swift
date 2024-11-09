//
//  ImageRowView.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import SwiftUI

// View to represent a row for each captured image, showing a thumbnail and upload status
struct ImageRowView: View {
    // Observed object to monitor changes to the captured image's properties, including upload progress
    @ObservedObject var capturedImages: CapturedImage
    
    var body: some View {
        HStack {
            // Display the image thumbnail, either from file system or in-memory data
            if let thumbnail = loadImageFromFileSystem(uri: capturedImages.uri) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if let image = UIImage(data: capturedImages.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Placeholder rectangle if image data is missing
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                // Display the upload status as text with color indicating success, failure, or pending status
                Text(capturedImages.uploadStatus.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(
                        capturedImages.uploadStatus == .Uploaded ? .green :
                            capturedImages.uploadStatus == .Failed ? .red : .orange
                    )
                
                // Display upload progress if upload is still ongoing
                if capturedImages.uploadStatus != .Uploaded {
                    HStack {
                        ProgressView(value: capturedImages.uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 10)
                        // Show progress as a percentage
                        Text("\(String(format: "%.2f", capturedImages.uploadProgress * 100)) %")
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
    
    // Helper function to load image from file system using the provided URI
    func loadImageFromFileSystem(uri: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: uri)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }    
}
