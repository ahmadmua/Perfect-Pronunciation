//
//  AudioAPIController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case emptyData
    case encodingError
    case fileReadError
}

class AudioAPIController: ObservableObject {
    @Published var audioAnalysisData = AudioAnalysis()

    func uploadAudio(audioData: Data, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        let uploadURL = URL(string: "http://3.95.58.220:8000/upload-audio")! //need to change this to AWS EC2 Instance
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createBody(boundary: boundary, data: audioData, fileName: "recording.m4a")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }
            
            
            let decoder = JSONDecoder()
                       decoder.keyDecodingStrategy = .convertFromSnakeCase

                       do {
                           // Decode the JSON data into an AudioAnalysis object
                           let audioAnalysis = try decoder.decode(AudioAnalysis.self, from: data)
                           
                           // Handling result
                           DispatchQueue.main.async {
                               self.audioAnalysisData = audioAnalysis
                           }
                           // Call the completion handler with the success result
                           completion(.success(audioAnalysis))
                       } catch {
                           // If decoding fails, print the error and call the completion handler with failure
                           print("Decoding error: \(error)")
                           completion(.failure(error))
                       }
                   }
                   task.resume()
    }

    private func createBody(boundary: String, data: Data, fileName: String) -> Data {
        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: audio/m4a\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

