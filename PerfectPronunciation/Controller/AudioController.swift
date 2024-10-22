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
    @Published var STTresult: String = ""
    
    // MARK: - Combine (for subscribers)
    let objectWillChange = PassthroughSubject<AudioController, Never>()
      
      
    // MARK: - Recording Management
    private var audioRecorder: AVAudioRecorder!
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    var recordBtnDisabled = true
    var onRecordingCompleted: ((URL) -> Void)?  // Closure to notify when recording is completed
    var recording = Recording(fileURL: URL(string: "about:blank")!, createdAt: Date())
    // A boolean flag to track the recording state
    var isRecording = false {
        didSet {
            // Notify subscribers that the object has changed
            objectWillChange.send(self)
        }
    }
  
      
      // MARK: - Speech Recognition Properties
      private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
      private var recognitionTask: SFSpeechRecognitionTask?
      private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    
    
    // Request authorization to use the microphone and speech recognition
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
    
    // Start the recording process
    func startRecording() {
        // Get the shared instance of AVAudioSession to manage the app's audio behavior
        let recordingSession = AVAudioSession.sharedInstance()

        // Check if the audio engine is already running (i.e., recording or recognizing)
        if audioEngine.isRunning {
            // If it's running, stop the audio engine and end the recognition request
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            // If it's not running, configure and start a new recording session
            
            // Set up the audio session to allow recording and playback
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)  // Set the category for recording and playback
                try recordingSession.setActive(true)  // Activate the session
            } catch {
                // Handle errors that occur when setting up the audio session
                print("Failed to set up recording session")
            }

            // Define the path to save the recorded audio file in the app's documents directory
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).wav")
            
            // Define the settings for the audio recorder (e.g., format, sample rate, channels, etc.)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),  // Linear PCM format for uncompressed audio
                AVSampleRateKey: 16000,  // 16 kHz sample rate (standard for speech recognition)
                AVNumberOfChannelsKey: 1,  // Mono audio (1 channel)
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  // High audio quality
            ]

            // Start recording audio
            do {
                // Initialize the AVAudioRecorder with the specified file URL and settings
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.record()  // Start the recording
            } catch {
                // Handle any errors that occur during the recording setup
                print("Could not start recording")
            }

            // Cancel any ongoing speech recognition task if there was one before
            recognitionTask?.cancel()
            recognitionTask = nil

            // Configure speech recognition by accessing the input node of the audio engine
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  // Create a new recognition request for live audio input
            recognitionRequest?.shouldReportPartialResults = true  // Enable partial results to get real-time transcription

            // Start the speech recognition task
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { [weak self] result, error in
                if let result = result {
                    // If a result is returned, update the STTresult in real-time
                    DispatchQueue.main.async {
                        self?.STTresult = result.bestTranscription.formattedString  // Get the best transcription
                    }
                }
                
                // Handle the end of the recognition task if an error occurs or the result is final
                if error != nil || result?.isFinal == true {
                    self?.audioEngine.stop()  // Stop the audio engine
                    inputNode.removeTap(onBus: 0)  // Remove the audio tap from the input node
                    self?.recognitionTask = nil  // Clear the recognition task
                    self?.recognitionRequest = nil  // Clear the recognition request
                }
            })

            // Configure the audio input node for real-time speech recognition
            let recordingFormat = inputNode.outputFormat(forBus: 0)  // Get the format of the input node
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                // Append the audio buffer to the recognition request
                self?.recognitionRequest?.append(buffer)
            }

            // Prepare and start the audio engine for capturing the microphone input
            do {
                audioEngine.prepare()  // Prepare the audio engine
                try audioEngine.start()  // Start the audio engine
            } catch {
                // Handle any errors during the starting of the audio engine
                print("Could not start audio engine")
            }
        }
    }

    
    // Stop the recording and notify VoiceRecorderController
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioRecorder?.stop()
        btnTitle = "Start Recording"
        // Once audio stops, fetch the most recent recording
        fetchRecording()
    }
    

    // Function to submit the last recorded audio for analysis
    func submitTestAudio(testText: String, lessonType: String) {
        // Unwrap the optional recording URL
        guard let audioURL = recording.fileURL else {
            print("Error: No valid file URL for the recording.")
            return
        }
        
        // Ensure the audio file URL is valid
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Error: File does not exist at \(audioURL.path)")
            return
        }
        
        if let fileURL = audioRecorder?.url {
            onRecordingCompleted?(fileURL)  // Notify VoiceRecorderController when recording is completed
        }
    }
}



    
    
//    func submitAudioWeekly() {
//        // Ensure that we have a valid file URL
//        guard let audioURL = recording.fileURL else {
//            print("Error: Invalid file URL")
//            return
//        }
//
//        do {
//            // Read audio data from the file
//            let audioData = try Data(contentsOf: audioURL)
//            let audioAPIController = AudioAPIController()
//            // Submit the audio data to the API for analysis
//            audioAPIController.uploadUserAudio(audioData: audioData) { result in
//                switch result {
//                case .success(let analysis):
//                    DispatchQueue.main.async {
//                        // Process successful analysis result
//                        print("Audio Analysis: \(analysis)")
//                        self.analysisAccuracyScore = Float(analysis.pronunciationScorePercentage.pronunciationScorePercentage)
//                        //update user completion
//                        DataHelper().updateWeeklyCompletion(score: self.analysisAccuracyScore)
//                        //----------------------------------------
//
////                        self.globalAnalysisResult = Float(analysis.pronunciationScorePercentage.pronunciationScorePercentage)
////                        DataHelper().addItemToUserDataCollection(itemName: "", dayOfWeek: self.returnDate(), accuracy: self.globalAnalysisResult!)
////
//                        //----------------------------------------
//
//                    }
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        // Handle any errors during analysis
//                        print("Error: \(error)")
//                    }
//                }
//            }
//        } catch {
//            // Handle errors during audio data reading
//            print("Error: Unable to load audio file data - \(error)")
//        }
//    }




    







