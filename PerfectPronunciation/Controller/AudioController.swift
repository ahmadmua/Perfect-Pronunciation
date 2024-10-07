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
      @Published var btnTitle: String = "Start Recording"
      @Published var STTresult: String = ""
      @Published var recordBtnDisabled = true
      @Published var analysisAccuracyScore: Float = 0.0
      
      // MARK: - Audio and Speech Processing
      var audioAPIController = AudioAPIController.shared
    
      var globalAnalysisResult: Float?
      
      // MARK: - Recording Management
      private var audioRecorder: AVAudioRecorder!
      private var audioFile: AVAudioFile?
      // A boolean flag to track the recording state
      var isRecording = false {
          didSet {
              // Notify subscribers that the object has changed
              objectWillChange.send(self)
          }
      }
      var recording = Recording(fileURL: URL(string: "about:blank")!, createdAt: Date())
      
      // MARK: - Speech Recognition Properties
      private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
      private var recognitionTask: SFSpeechRecognitionTask?
      private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
      private let audioEngine = AVAudioEngine()
      
      // MARK: - Combine (for subscribers)
      let objectWillChange = PassthroughSubject<AudioController, Never>()
    
    
    // Request authorization to use the microphone and speech recognition
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Enable recording if authorized
                    self.recordBtnDisabled = false
                case .denied, .restricted, .notDetermined:
                    // Disable recording if not authorized
                    self.recordBtnDisabled = true
                    self.btnTitle = "Microphone/Speech access is not authorized"
                default:
                    // Handle other cases
                    self.recordBtnDisabled = true
                    self.btnTitle = "Microphone/Speech access is not authorized"
                }
            }
        }
    }
    
    // Fetch the most recent recording from the documents directory
    func fetchRecording() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            // Get the contents of the documents directory
            let directoryContents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            // Filter for audio files and sort them by date
            let audioFiles = directoryContents
                .filter { $0.pathExtension == "wav" }  // Now filtering for .wav files
                .sorted {
                    let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1! > date2!
                }
            
            // Take the most recent file and update the recording property
            if let mostRecentFile = audioFiles.first {
                let fileDate = try mostRecentFile.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                recording = Recording(fileURL: mostRecentFile, createdAt: fileDate)
            }
        } catch {
            print("Error while fetching recordings: \(error)")
        }
        
        // Notify subscribers that the object has changed
        objectWillChange.send(self)
    }
    
    // Start the recording process
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        // Stop any previous recording or recognition task
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
        } else {
            // Set up the audio session for recording
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Failed to set up recording session")
            }
            
            // Create a file URL for the new recording
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).wav")
            
            // Define the audio recorder settings
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),  // Use PCM for WAV format
                AVSampleRateKey: 16000,  // Set the correct sample rate
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Start the audio recorder
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.record()
                isRecording = true
            } catch {
                print("Could not start recording")
            }
            
            // Reset any previous recognition tasks
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Prepare the audio engine for recording and recognition
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest.")
            }
            recognitionRequest.shouldReportPartialResults = true
            
            // Start the recognition task with the audio data
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
                guard let self = self else { return }
                var isFinal = false
                
                // Update the transcription result as it comes in
                if let result = result {
                    self.STTresult = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
                
                // Stop the task if there's an error or if it's final
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionTask = nil
                    self.recognitionRequest = nil
                    self.recordBtnDisabled = false
                    self.btnTitle = "Start Listening"
                    self.isRecording = false
                }
            })
            
            // Configure the audio input node
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                self?.recognitionRequest?.append(buffer)
            }
            
            // Start the audio engine
            do {
                audioEngine.prepare()
                try audioEngine.start()
            } catch {
                print("Could not start Audio Engine")
            }
            
            btnTitle = "Stop Listening"
        }
    }
    
    // Stop the recording and recognition process
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
    func submitTestAudio(testText: String) {
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
        
        do {
            _ = try Data(contentsOf: audioURL)
            // Process successful analysis result NEED TO CHANGE TO STORE DIFFERENTLY
            audioAPIController.transcribeAndAssessAudio(audioURL: audioURL, referenceText: testText) { result in
                switch result {
                case .success(let resultJson):
                    DispatchQueue.main.async {
                        print("Pronunciation Assessment Result: \(resultJson)")
                        //save the data to firebase
                        self.audioAPIController.uploadTestData()

                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        // Handle any errors during analysis
                        print("Error during assessment: \(error)")
                    }
                }
            }
        } catch {
            print("Error: Unable to load audio file data - \(error)")
        }
   }

    
    // Function that submits text to AI Voice gallery, to get an Audio File back to Play
    func submitTextToSpeechAI(testText: String) {
           // Call the sendTextToVoiceGallery function to obtain the audio clip
        audioAPIController.sendTextToVoiceGallery(testText: testText) { result in
               switch result {
               case .success(let audioData):
                   // Store the obtained audio clip in the audioClip variable
                   DispatchQueue.main.async {
                       //self.audioClip = audioData
                       print("Audio clip successfully obtained and stored.")
                       // You can now trigger audio playback here if needed
                   }
               case .failure(let error):
                   print("Failed to get audio clip: \(error)")
               }
           }
       }

    func returnDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let currentDayOfWeek = dateFormatter.string(from: Date())
        return currentDayOfWeek
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




    







