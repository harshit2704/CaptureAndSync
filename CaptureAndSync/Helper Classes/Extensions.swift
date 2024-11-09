//
//  Extensions.swift
//  CaptureAndSync
//
//  Created by Harshit Rastogi on 09/11/24.
//

import Foundation

// Extending the Data class to add a custom append method for strings
extension Data {
    // Mutating function that appends a string to the existing Data object
    mutating func append(_ string: String) {
        // Convert the string to Data using UTF-8 encoding
        if let data = string.data(using: .utf8) {
            // Append the converted data to the existing Data object
            self.append(data)
        }
    }
}
