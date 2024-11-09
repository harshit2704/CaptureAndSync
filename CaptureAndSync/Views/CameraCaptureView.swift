//
//  CameraCaptureView.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import SwiftUI

// View to handle camera capture functionality
struct CameraCaptureView: View {
    // ViewModel to handle captured image data and session management
    @ObservedObject var viewModel: CapturedImageViewModel
    // Binding property to pass the captured image back to the parent view
    @Binding var newImage: UIImage?
    // Binding property to control the visibility of the camera sheet
    @Binding var showCameraSheet: Bool
    
    var body: some View {
        ZStack {
            // Full-screen camera preview using the provided session from the ViewModel
            CameraPreviewView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all) // Ensures the camera preview takes up the full screen
            
            VStack {
                Spacer() // Pushes the capture button to the bottom of the screen
                
                // Button for capturing the photo
                Button(action: {
                    // Capture image and pass it back to the parent view, then close the camera sheet
                    viewModel.captureImage { image in
                        newImage = image
                        showCameraSheet = false
                    }
                }) {
                    // Circle button with a smaller inner circle for styling
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70, alignment: .center)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.8), lineWidth: 2)
                                .frame(width: 59, height: 59, alignment: .center)
                        )
                }
                .padding()
            }
        }
        .onAppear {
            // Start the camera session when the view appears
            viewModel.startRunning()
        }
        .onDisappear {
            // Stop the camera session when the view disappears
            viewModel.stopRunning()
        }
    }
}
