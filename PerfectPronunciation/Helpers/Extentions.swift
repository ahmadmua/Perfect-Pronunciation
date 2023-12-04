//
//  Extentions.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-12-02.
//

import Foundation

// Extension of the Date class to add additional functionality
extension Date {
    // Function to convert a Date object into a String representation.
    // The format parameter allows the caller to specify the date format they want.
    func toString(dateFormat format: String ) -> String {
        // Create a DateFormatter, which is used to format dates and times.
        let dateFormatter = DateFormatter()
        // Set the format of the date formatter to the format string provided.
        dateFormatter.dateFormat = format
        // Convert the Date object into a String using the date formatter.
        return dateFormatter.string(from: self)
    }
}

// Function to get the creation date of a file given its URL.
func getFileDate(for file: URL) -> Date {
    // Attempt to get the file attributes for the file at the provided URL path.
    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
        // If the attributes dictionary contains a creationDate, retrieve it.
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
        // Return the creation date of the file.
        return creationDate
    } else {
        // If getting the attributes or the creation date fails, return the current date.
        return Date()
    }
}
