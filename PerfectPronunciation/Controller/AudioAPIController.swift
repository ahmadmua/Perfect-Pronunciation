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
    
    func uploadAudio(for audioAnalysisData: String, completion: @escaping (Result<AudioAnalysis, Error>) -> Void) {
        
        let headers = [            "X-RapidAPI-Key": "f78ec949c9msh56530a588aa61f8p1a1246jsn843e6d48ab6f",            "X-RapidAPI-Host": "real-time-product-search.p.rapidapi.com"        ]
        
        guard let url = URL(string: "https://real-time-product-search.p.rapidapi.com/search?q=\(product)&country=us&language=en") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
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
                let product = try decoder.decode(Product.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    self?.productData.append(product) // add product to a new index in productData
                }
                completion(.success(product))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
