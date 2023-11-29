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

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case emptyData
}


class AudioAPIController : ObservableObject {
    
    @Published var audioAnalysisData = [AudioAnalysis]()
    
    func uploadAudio(for audio: String, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        
        
        
        guard let url = URL(string: "http://3.95.58.220:8000/upload-audio") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //need to include the body with "audio" as the key and the value is the Recording
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                let audio = try decoder.decode(AudioAnalysis.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    self?.audioAnalysisData.append(audio) // add product to a new index in productData
                }
                completion(.success(audio))
            } catch {
                completion(.failure(audio as! Error))
            }
        }.resume()
    }
}
