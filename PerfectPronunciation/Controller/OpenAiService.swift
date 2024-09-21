//
//  OpenAiService.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-09-20.
//
import Foundation
import Combine

// Struct to decode the OpenAI Chat API response
struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// OpenAIService class to handle API calls
class OpenAIService {
    private let apiKey = "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"

    func fetchOpenAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) -> AnyCancellable? {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",  // Or gpt-4 if you are using the GPT-4 model
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 50,
            "temperature": 1.5
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(.failure(NSError(domain: "Failed to create request body", code: -1, userInfo: nil)))
            return nil
        }

        request.httpBody = httpBody

        // Use Combine's URLSession.DataTaskPublisher to fetch the data
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

