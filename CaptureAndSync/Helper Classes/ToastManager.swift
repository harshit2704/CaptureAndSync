//
//  ToastManager.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 09/11/24.
//

import Foundation

// A singleton class responsible for managing toast notifications
class ToastManager: ObservableObject {
    
    // Published properties that will notify the view when they change
    @Published var message: String = "" // The message to be displayed in the toast
    @Published var showToast: Bool = false // Boolean flag to control the visibility of the toast
    
    // Shared instance of the ToastManager (singleton pattern)
    static let shared = ToastManager()
    
    // Private initializer to enforce the singleton pattern
    private init() {}
    
    // Function to show a toast with a specific message
    func showToast(message: String) {
        self.message = message // Set the message
        self.showToast = true  // Show the toast
        
        // Hide the toast after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
        }
    }
}

