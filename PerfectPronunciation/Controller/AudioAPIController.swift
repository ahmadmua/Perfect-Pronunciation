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
    static let shared = AudioAPIController()
    
    @Published var audioAnalysisTestData = AudioAnalysis()
    @Published var audioAnalysisUserData = AudioAnalysis()
    @Published var comparedAudioAnalysis: AudioAnalysis = AudioAnalysis()
    
    
    init(comparedAudioAnalysis: AudioAnalysis = AudioAnalysis()) {
        self.comparedAudioAnalysis = comparedAudioAnalysis
    }
    
    
    func uploadTestAudio(audioData: Data, recordingName: String, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        // URL for the audio upload endpoint (Change to your AWS EC2 instance URL).
        let uploadURL = URL(string: "http://3.95.58.220:8000/upload-audio")!
        // URLRequest configuration.
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        // Generate a unique boundary string using UUID for multipart/form-data.
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart/form-data body.
        request.httpBody = createBody(boundary: boundary, data: audioData, fileName: recordingName)
        
        // Perform the network task.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors that occur during the network request.
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for a valid HTTP response.
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Ensure that data is received from the server.
            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }
            
            // JSONDecoder to parse the JSON data.
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Attempt to decode the JSON data into an AudioAnalysis object.
                let audioAnalysis = try decoder.decode(AudioAnalysis.self, from: data)
                
                // If decoding is successful, update the published property and call the completion handler.
                DispatchQueue.main.async {
                    self.audioAnalysisTestData = audioAnalysis
                    completion(.success(audioAnalysis))
                }
            } catch {
                // If decoding fails, print the error and call the completion handler with failure.
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        // Start the network task.
        task.resume()
    }
    
    func uploadUserAudio(audioData: Data, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        // URL for the audio upload endpoint (Change to your AWS EC2 instance URL).
        let uploadURL = URL(string: "http://3.95.58.220:8000/upload-audio")!
        // URLRequest configuration.
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        // Generate a unique boundary string using UUID for multipart/form-data.
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart/form-data body.
        request.httpBody = createBody(boundary: boundary, data: audioData, fileName: "recording.m4a")
        
        // Perform the network task.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors that occur during the network request.
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for a valid HTTP response.
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Ensure that data is received from the server.
            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }
            
            // JSONDecoder to parse the JSON data.
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Attempt to decode the JSON data into an AudioAnalysis object.
                let audioAnalysis = try decoder.decode(AudioAnalysis.self, from: data)
                
                // If decoding is successful, update the published property and call the completion handler.
                DispatchQueue.main.async {
                    self.audioAnalysisUserData = audioAnalysis
                    completion(.success(audioAnalysis))
                }
            } catch {
                // If decoding fails, print the error and call the completion handler with failure.
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        // Start the network task.
        task.resume()
    }
    
    
    
    func compareAudioAnalysis() {
//        print("CompareAudioAnalysis FUNCTION CALLLLED \(audioAnalysisUserData.pronunciationScorePercentage)")
//        
//        
////        print("USER DATA SCORE : \(self.audioAnalysisUserData.pronunciationScorePercentage)")
//        print("TEST DATA SCORE : \(self.audioAnalysisTestData.pronunciationScorePercentage)")
        
        print("USER DEFAULTS USER AUDIO  FROM COMPARE FUNC: \(UserDefaults.standard.double(forKey: "UserAudioScore"))")
        UserDefaults.standard.synchronize()
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


