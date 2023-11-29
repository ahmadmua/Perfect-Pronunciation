//
//  AudioAPIController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.
//


import Foundation
import UIKit
import SwiftUI
import Network
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case emptyData
}

class AudioAPIController: ObservableObject {
    
    @Published var audioAnalysisData = [AudioAnalysis]()
    
    func uploadAudio(audioData: Data, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        guard let url = URL(string: "http://3.95.58.220:8000/upload-audio") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate the boundary string using a unique per-app string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Set the content type to multipart/form-data with the generated boundary
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Append the audio data to the request body with the key "audio"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the body with the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.statusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let analysisResult = try decoder.decode(AudioAnalysis.self, from: data)
                DispatchQueue.main.async {
                    self.audioAnalysisData.append(analysisResult)
                }
                completion(.success(analysisResult))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Helper extension to make appending to Data easier
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
