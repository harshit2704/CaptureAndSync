//
//  CapturedImagesView.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import SwiftUI
import UserNotifications

// The main view for displaying and interacting with captured images
struct ImageListView: View {
    // ViewModel to manage image capture, upload, and status updates
    @StateObject private var viewModel = CapturedImageViewModel()
    
    // Controls camera sheet presentation
    @State private var showCameraSheet = false
    
    // Holds a reference to a new captured image
    @State private var newImage: UIImage? = nil
    
    // Observed toast manager to show toast notifications for upload status
    @ObservedObject var toastManager = ToastManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                // List of captured images, with each row showing a thumbnail and upload progress/status
                List {
                    ForEach(viewModel.capturedImages, id: \.self) { imageRow in
                        ImageRowView(capturedImages: imageRow)
                            .onTapGesture {
                                // Retry upload for images that failed
                                if imageRow.uploadStatus == .Failed {
                                    viewModel.uploadImageToServer(imageRow)
                                }
                            }
                    }
                }
                
                // Button to open the camera and capture a new image
                Button(action: {
                    showCameraSheet = true
                }) {
                    Text("Open Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showCameraSheet) {
                    CameraCaptureView(viewModel: viewModel, newImage: $newImage, showCameraSheet: $showCameraSheet)
                }
            }
            .navigationBarTitle("Captured Images")
        }
        // Overlay for displaying toast messages for real-time upload notifications
        .overlay(
            ToastView(toastManager: toastManager)
        )
    }    
}
