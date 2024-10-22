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
            
            // Setup the audio session and start recording
            setupAudioSessionAndRecord()
            
            // Setup speech recognition to handle real-time transcription
            setupSpeechRecognition()
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

    
    // Stop the recording and notify VoiceRecorderController
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioRecorder?.stop()
        
        if let fileURL = audioRecorder?.url {
            onRecordingCompleted?(fileURL)  // Notify VoiceRecorderController when recording is completed
        }
    }
    
}



    





    






