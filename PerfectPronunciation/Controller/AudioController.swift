//
//  AudioController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-08.
//

import Foundation
import Combine
import AVFoundation
import Speech

// This class handles audio recording and speech recognition
class AudioController: NSObject, ObservableObject {
    
    // MARK: - Published Properties (for UI binding)
       @Published var STTresult: String = ""  // Holds the real-time transcription result
       
       // Combine (for subscribers)
       let objectWillChange = PassthroughSubject<AudioController, Never>()
       
       // Recording management
       private var audioRecorder: AVAudioRecorder?
       private let audioEngine = AVAudioEngine()
       private var audioFile: AVAudioFile?
       var recordBtnDisabled = true  // Indicates if the recording button should be disabled
       
       // Callback when recording is completed
       var onRecordingCompleted: ((URL) -> Void)?
       var recording = Recording(fileURL: URL(string: "about:blank")!, createdAt: Date())
       
       // A boolean flag to track the recording state
       var isRecording = false {
           didSet {
               objectWillChange.send(self)
           }
       }
    
    // Speech recognition management
       private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
       private var recognitionTask: SFSpeechRecognitionTask?
       private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
       
    
    
    
    // MARK: - Request authorization for microphone and speech recognition access
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Microphone access granted")
                case .denied, .restricted, .notDetermined:
                    print("Microphone access denied")
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Start the recording process
        func startRecording() {
            guard !isRecording else {
                // If recording is already in progress, prevent starting a new one
                print("Recording is already in progress")
                return
            }
            
            isRecording = true  // Set the recording flag
            
            self.STTresult = "" //set this to blank so that previous recording STT is removed 
            
            // Setup the audio session and start recording
            setupAudioSessionAndRecord()
            
            // Setup speech recognition to handle real-time transcription
            setupSpeechRecognition()
        }
    
    
    // MARK: - Stop the recording process and clean up resources
      func stopRecording() {
          guard isRecording else {
              // If no recording is in progress, return early
              print("Recording is not in progress")
              return
          }
          
          isRecording = false  // Reset the recording flag
          
          // Stop the audio engine and speech recognition process
          audioEngine.stop()
          recognitionRequest?.endAudio()
          
          // Stop the audio recorder
          audioRecorder?.stop()
          
          // Notify the controller with the recorded file URL
          if let fileURL = audioRecorder?.url {
              onRecordingCompleted?(fileURL)
          }
          
          // Reset the audio session for other apps
          deactivateAudioSession()
      }
    
    // MARK: - Setup the audio session and start recording audio
      private func setupAudioSessionAndRecord() {
          let recordingSession = AVAudioSession.sharedInstance()  // Shared instance for managing audio behavior
          
          do {
              // Configure the session for both recording and playback
              try recordingSession.setCategory(.playAndRecord, mode: .default)
              try recordingSession.setActive(true)
              
              // Define the file path for saving the recording in the app's documents directory
              let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
              let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).wav")
              
              // Audio recording settings (e.g., sample rate, channels)
              let settings = [
                  AVFormatIDKey: Int(kAudioFormatLinearPCM),  // PCM format for uncompressed audio
                  AVSampleRateKey: 16000,  // Sample rate (standard for speech recognition)
                  AVNumberOfChannelsKey: 1,  // Mono audio
                  AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  // High-quality audio encoding
              ]
              
              // Initialize and start recording audio with the specified settings
              audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
              audioRecorder?.record()
              
          } catch {
              // If any error occurs during setup, print the error and stop recording
              print("Failed to start recording: \(error)")
              stopRecording()
          }
      }
    
    // MARK: - Deactivate the audio session after recording stops
        private func deactivateAudioSession() {
            do {
                // Deactivate the audio session and allow other audio apps to resume
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                // Handle any errors when deactivating the audio session
                print("Failed to deactivate audio session: \(error)")
            }
        }
    
    
    
    // MARK: - Setup and start speech recognition
      private func setupSpeechRecognition() {
          // Cancel any ongoing recognition task
          recognitionTask?.cancel()
          recognitionTask = nil
          
          let inputNode = audioEngine.inputNode  // Get the input node for audio capture
          
          // Create a new recognition request for live audio input
          recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
          recognitionRequest?.shouldReportPartialResults = true  // Get real-time transcription results
          
          // Start the speech recognition task
          recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { [weak self] result, error in
              guard let self = self else { return }
              if let result = result {
                  // Update the transcription result (STT result) in real time
                  DispatchQueue.main.async {
                      self.STTresult = result.bestTranscription.formattedString
                  }
              }
              
              // If an error occurs or the recognition task finishes, stop the audio engine
              if error != nil || result?.isFinal == true {
                  self.stopSpeechRecognition(inputNode: inputNode)
              }
          })
          
          // Attach the audio input to the speech recognition request
          let recordingFormat = inputNode.outputFormat(forBus: 0)  // Get the format of the input node
          inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
              // Pass audio data to the recognition request
              self?.recognitionRequest?.append(buffer)
          }
          
          // Start the audio engine to capture microphone input
          do {
              audioEngine.prepare()  // Prepare the audio engine for operation
              try audioEngine.start()  // Start the audio engine
          } catch {
              // Handle errors that occur when starting the audio engine
              print("Failed to start audio engine: \(error)")
              stopRecording()
          }
      }
    
    // MARK: - Stop speech recognition and clean up
        private func stopSpeechRecognition(inputNode: AVAudioInputNode) {
            audioEngine.stop()  // Stop the audio engine
            inputNode.removeTap(onBus: 0)  // Remove the audio tap
            recognitionTask?.cancel()  // Cancel any ongoing recognition task
            recognitionRequest = nil  // Clear the request
            recognitionTask = nil  // Clear the task
        }

    
    
    
}



    





    






