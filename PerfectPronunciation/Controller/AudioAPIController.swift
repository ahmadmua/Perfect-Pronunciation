//
//  AudioAPIController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.

import Foundation
import Combine

// Enum to handle different types of network errors.
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case emptyData
    case encodingError
    case fileReadError
}

// This class is responsible for handling the audio API operations.
class AudioAPIController: ObservableObject {
    // Published property that updates the view when a new analysis is loaded.
        var audioAnalysisTestData = AudioAnalysis()
        var audioAnalysisUserData = AudioAnalysis()
        @Published var comparedAudioAnalysis: AudioAnalysis // Assuming you will initialize it somewhere

        init(comparedAudioAnalysis: AudioAnalysis = AudioAnalysis()) {
            self.comparedAudioAnalysis = comparedAudioAnalysis
        }

    
    func uploadTestAudio(audioData: Data) {
        
        
        //NOTE TO Nick & Muaz, this function needs to grab the test audio we all pre recorded that is supposed to be the highly accurate data
        
        
            guard let uploadURL = URL(string: "http://3.95.58.220:8000/upload-audio") else {
                print("Invalid URL")
                return
            }
            
            // URLRequest configuration.
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"
            
            // Generate a unique boundary string using UUID for multipart/form-data.
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Create the multipart/form-data body.
            request.httpBody = createBody(boundary: boundary, data: audioData, fileName: "recording.m4a") //change to variable 
            
            // Perform the network task.
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                // Handle any errors that occur during the network request.
                if let error = error {
                    print("Network request error: \(error)")
                    return
                }
                
                // Check for a valid HTTP response.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response from server")
                    return
                }
                
                // Ensure that data is received from the server.
                guard let data = data else {
                    print("No data received from server")
                    return
                }
                
                // JSONDecoder to parse the JSON data.
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    // Attempt to decode the JSON data into an AudioAnalysis object.
                    let audioAnalysis = try decoder.decode(AudioAnalysis.self, from: data)
                    
                    // If decoding is successful, update the published property.
                    DispatchQueue.main.async {
                        self?.audioAnalysisUserData = audioAnalysis
                        print("Audio analysis updated successfully")
                    }
                } catch {
                    // If decoding fails, print the error.
                    print("Decoding error: \(error)")
                }
            }
            
            // Start the network task.
            task.resume()
        }
    
    func uploadUserAudio(audioData: Data) {
            guard let uploadURL = URL(string: "http://3.95.58.220:8000/upload-audio") else {
                print("Invalid URL")
                return
            }
            
            // URLRequest configuration.
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"
            
            // Generate a unique boundary string using UUID for multipart/form-data.
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Create the multipart/form-data body.
            request.httpBody = createBody(boundary: boundary, data: audioData, fileName: "recording.m4a")
            
            // Perform the network task.
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                // Handle any errors that occur during the network request.
                if let error = error {
                    print("Network request error: \(error)")
                    return
                }
                
                // Check for a valid HTTP response.
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response from server")
                    return
                }
                
                // Ensure that data is received from the server.
                guard let data = data else {
                    print("No data received from server")
                    return
                }
                
                // JSONDecoder to parse the JSON data.
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    // Attempt to decode the JSON data into an AudioAnalysis object.
                    let audioAnalysis = try decoder.decode(AudioAnalysis.self, from: data)
                    
                    // If decoding is successful, update the published property.
                    DispatchQueue.main.async {
                        self?.audioAnalysisUserData = audioAnalysis
                        print("Audio analysis updated successfully")
                    }
                } catch {
                    // If decoding fails, print the error.
                    print("Decoding error: \(error)")
                }
            }
            
            // Start the network task.
            task.resume()
            
            compareAudioAnalysis()
        }
    
    func compareAudioAnalysis() {
           //Use Mathematical Analysis here to compare the Test Audio Results with the User Audio Results
            print("test")
       }
       

    // Helper function to create the body of the multipart/form-data request.
    private func createBody(boundary: String, data: Data, fileName: String) -> Data {
        var body = Data()

        // Append the multipart/form-data boundaries and file data to the request body.
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: audio/m4a\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        return body
    }
}

// Extension to simplify appending strings to Data objects.
extension Data {
    // Helper method to append string data to a Data object.
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


