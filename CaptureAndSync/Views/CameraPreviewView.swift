//
//  CameraPreviewView.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 08/11/24.
//

import SwiftUI
import AVFoundation

// A SwiftUI view that displays the camera preview using AVCaptureSession
struct CameraPreviewView: UIViewRepresentable {
    // AVCaptureSession object that controls the flow of data from the camera
    var session: AVCaptureSession?
    
    // Creates and returns the UIView that will display the camera preview
    func makeUIView(context: Context) -> UIView {
        // Create a custom UIView that will hold the preview layer
        let view = PreviewUIView()
        
        // If a session is provided, configure the preview layer
        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill // Ensures the video scales to fill the screen while maintaining the aspect ratio
            view.previewLayer = previewLayer
            // Add the preview layer as a sublayer to the view
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    // Updates the UIView when the SwiftUI state changes
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensures the preview layer size is adjusted to match the view's bounds
        guard let previewLayer = (uiView as? PreviewUIView)?.previewLayer else { return }
        previewLayer.frame = uiView.bounds
    }
}

// Custom UIView subclass to hold the preview layer
class PreviewUIView: UIView {
    // Reference to the preview layer for displaying the camera feed
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Override the layoutSubviews method to adjust the preview layer frame whenever the view's layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        // Make sure the preview layer takes the full bounds of the view
        previewLayer?.frame = self.bounds
    }
}
