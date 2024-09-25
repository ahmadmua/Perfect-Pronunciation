//
//  OpenAiService.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-09-20.
//
import Foundation
import Combine
import FirebaseRemoteConfig

struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class OpenAIService {
    private var remoteConfig: RemoteConfig
    private var apiKey: String = ""

    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        //self.fetchAPIKey()
    }


    func fetchAPIKey() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For testing, change this in production.
        remoteConfig.configSettings = settings
        
        remoteConfig.fetchAndActivate { [weak self] status, error in
            if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
                return
            }
            
            self?.apiKey = self?.remoteConfig["open_api_key"].stringValue ?? "No API Key Found"
            print("Fetched API Key: \(self?.apiKey ?? "No API Key")")
        }
    }


    func fetchOpenAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) -> AnyCancellable? {
        guard !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "API Key is missing", code: -1, userInfo: nil)))
            return nil
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 50,
            "temperature": 0.5
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(.failure(NSError(domain: "Failed to create request body", code: -1, userInfo: nil)))
            return nil
        }

        request.httpBody = httpBody


        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: OpenAIChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { response in
                if let choice = response.choices.first {
                    completion(.success(choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
            })
    }
}
