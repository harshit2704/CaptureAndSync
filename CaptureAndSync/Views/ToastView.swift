//
//  ToastView.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 09/11/24.
//

import SwiftUI

// A SwiftUI view that displays a toast message to the user
struct ToastView: View {
    // Observed object that manages the state of the toast message
    @ObservedObject var toastManager = ToastManager.shared
    
    var body: some View {
        // Display the toast only if the showToast flag is true
        if toastManager.showToast {
            Text(toastManager.message)  // Display the message stored in the toast manager
                .padding()  // Add padding around the text for better appearance
                .background(Color.black.opacity(0.7))  // Set a semi-transparent black background for the toast
                .foregroundColor(.white)  // Set the text color to white
                .cornerRadius(10)  // Apply rounded corners to the background
                .padding()  // Add padding around the entire toast
                // Apply a transition where the toast moves from the bottom edge when it appears
                .transition(.move(edge: .bottom))
                // Animate the appearance/disappearance of the toast with an ease-in-out effect
                .animation(.easeInOut, value: toastManager.showToast)
        }
    }
}
