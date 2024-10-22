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
    case requestFailed

}

// This class is responsible for handling the audio API operations.
class AudioAPIController: ObservableObject {
//    private var remoteConfig: RemoteConfig
//    private var apiKey: String = ""
    static let shared = AudioAPIController()
    
    init() {
        //self.remoteConfig = RemoteConfig.remoteConfig()
        // self.fetchAPIKey()
    }
    
//    func fetchAPIKey() {
//        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0 // For testing, change this in production.
//        remoteConfig.configSettings = settings
//        
//        remoteConfig.fetchAndActivate { [weak self] status, error in
//            if let error = error {
//                print("Error fetching remote config: \(error.localizedDescription)")
//                return
//            }
//            
//            self?.apiKey = self?.remoteConfig["open_api_key"].stringValue ?? "No API Key Found"
//            print("Fetched API Key: \(self?.apiKey ?? "No API Key")")
//        }
//    }
    
    // Function to transcribe audio file to text using Microsoft Transcription API
    // allows us to transcribe the words that were said in the audio file
    func transcribeAudioFile(audioURL: URL, completion: @escaping (Result<[String: Any], NetworkError>) -> Void) {
        let region = "eastus" // Replace this with your region
        let subscriptionKey = "a39f6ff72e4c4ffb99deaa05019002fa" // Replace this with your key
        
        let urlString = "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            let task = URLSession.shared.uploadTask(with: request, from: audioData) { data, response, error in
                if let error = error {
                    print("Transcribing Error: \(error)")
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard response.statusCode == 200 else {
                    completion(.failure(.statusCode(response.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.emptyData))
                    return
                }
                
                // return the full JSON object
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Return the entire JSON object
                        completion(.success(jsonResult))
                    } else {
                        completion(.failure(.encodingError))
                    }
                } catch {
                    completion(.failure(.encodingError))
                }
            }
            task.resume()
        } catch {
            completion(.failure(.fileReadError))
        }
    }

    // Function to send audio for pronunciation assessment
    func sendToSpeechAnalysisAPI(audioURL: URL, referenceText: String, completion: @escaping (Result<[String: Any], NetworkError>) -> Void) {
        let region = "eastus" // Replace with your region
        let subscriptionKey = "a39f6ff72e4c4ffb99deaa05019002fa" // Replace this with your key
        
        let urlString = "https://\(region).stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-us"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("audio/wav; codecs=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Create pronunciation assessment params
        let pronAssessmentParams: [String: Any] = [
            "ReferenceText": referenceText,
            "GradingSystem": "HundredMark",
            "Dimension": "Comprehensive"
        ]
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: pronAssessmentParams, options: [])
            let base64Params = jsonParams.base64EncodedString()
            request.setValue(base64Params, forHTTPHeaderField: "Pronunciation-Assessment")
            
            let audioData = try Data(contentsOf: audioURL)
            let task = URLSession.shared.uploadTask(with: request, from: audioData) { data, response, error in
                if let error = error {
                    print("Analysis Error: \(error)")
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard response.statusCode == 200 else {
                    completion(.failure(.statusCode(response.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.emptyData))
                    return
                }
                
                do {
                    // Debugging variable to hold the JSON data
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Complete with success
                        completion(.success(jsonResult))
                    } else {
                        completion(.failure(.encodingError))
                    }
                } catch {
                    completion(.failure(.encodingError))
                }
            }
            task.resume()
        } catch {
            completion(.failure(.fileReadError))
        }
    }
    
    // Function to send a text to the Voice Gallery API and get audio in response
    func sendTextToVoiceGallery(testText: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let subscriptionKey = "a39f6ff72e4c4ffb99deaa05019002fa"
        let region = "eastus"
        let urlString = "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1"
        
        // Check if the URL is valid
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Set up the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Headers required by the API
        request.setValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
        request.setValue("audio-16khz-32kbitrate-mono-mp3", forHTTPHeaderField: "X-Microsoft-OutputFormat")
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key") // Correct header for API key
        request.setValue("YOUR-USER-AGENT", forHTTPHeaderField: "User-Agent")
        
        // Set the body with the SSML format for input text
        let ssml = """
        <speak version='1.0' xml:lang='en-US'>
            <voice xml:lang='en-US' xml:gender='Female' name='en-US-JennyNeural'>
                \(testText)
            </voice>
        </speak>
        """
        
        request.httpBody = ssml.data(using: .utf8)
        
        // Create a URLSession task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorDescription = error?.localizedDescription ?? "Unknown error"
                print("Voice Gallery Error: \(errorDescription)")
                completion(.failure(.requestFailed)) // Return a more appropriate NetworkError here
                return
            }
            
            if let data = data {
                print("Success with AI Gallery")
                print(data)
                completion(.success(data)) // Return the audio data on success
            } else {
                completion(.failure(.emptyData)) // Return failure if there's no data
            }
        }
        
        task.resume() // Start the request
    }

    
    
    // Function to call transcribeAudioFile func & sendToSpeechAnalysis func
    func transcribeAndAssessAudio(audioURL: URL, referenceText: String, lessonType: String ,completion: @escaping (Result<PronunciationAssessmentResult, NetworkError>) -> Void) {
          
          // First call transcribeAudioFile
          self.transcribeAudioFile(audioURL: audioURL) { transcriptionResult in
              switch transcriptionResult {
              case .success(let transcription):
                  // Then call sendToSpeechAPI for Pronunciation Assessment
                  self.sendToSpeechAnalysisAPI(audioURL: audioURL, referenceText: referenceText) { assessmentResult in
                      switch assessmentResult {
                      case .success(let assessmentData):
                          // Merge both assessment and transcription into one dictionary with assessment first
                          var mergedResult: [String: Any] = [:]
                          mergedResult["lessonType"] = lessonType
                          mergedResult["assessment"] = assessmentData // Add assessment result first
                          mergedResult["transcription"] = transcription // Add transcription result next
                          
                          // Now decode the merged result into the PronunciationAssessmentResult model
                          do {
                              let jsonData = try JSONSerialization.data(withJSONObject: mergedResult, options: [])
                              let decodedResult = try JSONDecoder().decode(PronunciationAssessmentResult.self, from: jsonData)
                              //print(decodedResult)
                              completion(.success(decodedResult))
                          } catch {
                              print("Decoding Error: \(error)")
                              completion(.failure(.encodingError))
                          }
                          
                      case .failure(let error):
                          // Handle error from sendToSpeechAPI
                          completion(.failure(error))
                      }
                  }
                  
              case .failure(let error):
                  // Handle error from transcribeAudioFile
                  completion(.failure(error))
              }
          }
      }

    
}
    
// Define your NetworkError enum

   
// Extension to simplify appending strings to Data objects.
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}



