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
    private var cancellable: AnyCancellable? // Store the cancellable here to prevent deallocation

    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        // self.fetchAPIKey()
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

    private func makeOpenAIRequest(prompt: String) -> AnyPublisher<String, Error> {
        guard !apiKey.isEmpty else {
            return Fail(error: NSError(domain: "API Key is missing", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
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
            return Fail(error: NSError(domain: "Failed to create request body", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
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
            .map { response in
                response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // call the API 5 times
    func fetchMultipleOpenAIResponses(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let publishers = (1...5).map { _ in makeOpenAIRequest(prompt: prompt) }

        cancellable = Publishers.MergeMany(publishers)
            .collect(5) // Collect exactly 5 results
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { responses in
                completion(.success(responses))
            })
    }
}
