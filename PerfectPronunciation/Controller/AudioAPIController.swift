//
//  AudioAPIController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.
import Foundation
import Combine
import FirebaseRemoteConfig

// Enum to handle different types of network errors.
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case emptyData
    case encodingError
    case fileReadError
    case requestFailed
}

// This class is responsible for handling the audio API operations.
class AudioAPIController: ObservableObject {
    
    static let shared = AudioAPIController()
    private var remoteConfig: RemoteConfig
    private var apiKey: String = ""

    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.fetchAPIKey()
    }

    // Helper function to make a POST request and return the response data
    private func makePostRequest(url: URL, headers: [String: String]?, body: Data?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.statusCode((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }

        return data
    }

    // Fetch the API key from Firebase Remote Config
    func fetchAPIKey() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For testing, change this in production.
        remoteConfig.configSettings = settings
        
        remoteConfig.fetchAndActivate { [weak self] status, error in
            if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
                return
            }
            
            self?.apiKey = self?.remoteConfig["azure_key"].stringValue ?? "No API Key Found"
            print("Fetched API Key: \(self?.apiKey ?? "No API Key")")
        }
    }

    // This function sends an audio file to Microsoft's Speech-to-Text API and transcribes the audio into text.
    private func transcribeAudioFile(audioURL: URL) async throws -> [String: Any] {
        let region = "eastus"
        
        // Use the API key fetched from Firebase Remote Config
        let subscriptionKey = apiKey

        let urlString = "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let audioData = try Data(contentsOf: audioURL)

        let headers = [
            "Ocp-Apim-Subscription-Key": subscriptionKey,
            "Content-Type": "audio/wav"
        ]

        let responseData = try await makePostRequest(url: url, headers: headers, body: audioData)

        guard let jsonResult = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            throw NetworkError.encodingError
        }

        return jsonResult
    }

    // Function to send audio for pronunciation assessment using Microsoft's Speech Analysis API
    private func sendToSpeechAnalysisAPI(audioURL: URL, referenceText: String) async throws -> [String: Any] {
        let region = "eastus"
        
        // Use the API key fetched from Firebase Remote Config
        let subscriptionKey = apiKey
        
        let urlString = "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-us"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let pronAssessmentParams: [String: Any] = [
            "ReferenceText": referenceText,
            "GradingSystem": "HundredMark",
            "Dimension": "Comprehensive"
        ]

        let jsonParams = try JSONSerialization.data(withJSONObject: pronAssessmentParams, options: [])
        let base64Params = jsonParams.base64EncodedString()

        let headers = [
            "Ocp-Apim-Subscription-Key": subscriptionKey,
            "Accept": "application/json",
            "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
            "Pronunciation-Assessment": base64Params
        ]

        let audioData = try Data(contentsOf: audioURL)

        let responseData = try await makePostRequest(url: url, headers: headers, body: audioData)

        guard let jsonResult = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            throw NetworkError.encodingError
        }

        return jsonResult
    }

    // Function to send a text to Microsoft's Text-to-Speech (TTS) API and get back an audio clip
    func sendTextToVoiceGallery(testText: String) async throws -> Data {
        let subscriptionKey = apiKey
        let region = "eastus"

        let urlString = "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let headers = [
            "Content-Type": "application/ssml+xml",
            "X-Microsoft-OutputFormat": "riff-16khz-16bit-mono-pcm",
            "Ocp-Apim-Subscription-Key": subscriptionKey,
            "User-Agent": "YOUR-USER-AGENT"
        ]

        let ssml = """
        <speak version='1.0' xml:lang='en-US'>
            <voice xml:lang='en-US' xml:gender='Female' name='en-US-JennyNeural'>
                \(testText)
            </voice>
        </speak>
        """

        print("Generated SSML: \(ssml)")

        let bodyData = ssml.data(using: .utf8)

        return try await makePostRequest(url: url, headers: headers, body: bodyData)
    }

    // Function that combines both transcription and pronunciation assessment
    func transcribeAndAssessAudio(audioURL: URL, referenceText: String, lessonType: String) async throws -> PronunciationAssessmentResult {
        let transcription = try await transcribeAudioFile(audioURL: audioURL)

        let assessment = try await sendToSpeechAnalysisAPI(audioURL: audioURL, referenceText: referenceText)

        var mergedResult: [String: Any] = [:]
        mergedResult["lessonType"] = lessonType
        mergedResult["assessment"] = assessment
        mergedResult["transcription"] = transcription

        let jsonData = try JSONSerialization.data(withJSONObject: mergedResult, options: [])
        
        let decodedResult = try JSONDecoder().decode(PronunciationAssessmentResult.self, from: jsonData)

        return decodedResult
    }
}

// Extension to simplify appending strings to Data objects.
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
