//
//  VoiceRecorderController.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2024-10-21.
//

import Foundation
import Combine
import AVFoundation
import Speech

enum RecordingMode {
    case ready
    case recording
    case analyzing
    case playing
    
    // Computed property to convert enum cases to String
        var description: String {
            switch self {
            case .ready:
                return "Ready to Record"
            case .recording:
                return "Recording..."
            case .analyzing:
                return "Analyzing..."
            case .playing:
                return "Playing Audio"
            }
        }
}

// This class handles high-level functions of VoiceRecorderView and interacts with AudioController
class VoiceRecorderController: NSObject, ObservableObject {
    
    /// MARK: - Published Properties (for UI binding)
    @Published var STTresult: String = ""        // Live Transcription result from AudioController
    @Published var mode: RecordingMode = .ready  // Recorder mode
    @Published var recordBtnDisabled = true      // Button state for record button
    @Published var audioFileURL: URL?            // Stores the recorded file URL
    @Published var isSubmitting: Bool = false    // Prevent double submissions
    @Published var errorMessage: String?         // Error message for UI

    // Combine for state changes
    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    // Dependencies: Audio and API controllers
    var audioController: AudioController
    var audioAPIController: AudioAPIController
    var dataHelper = DataHelper()            // Helper to manage data storage with firebase
    
    // Initialize with dependencies to allow for easier testing
    init(audioController: AudioController, audioAPIController: AudioAPIController) {
        self.audioController = audioController
        self.audioAPIController = audioAPIController
        super.init()
        setupAudioController()
    }
    
    // Setup the connection with AudioController to update UI based on audio events
    private func setupAudioController() {
        audioController.requestAuthorization()//when audiocontroller is "setup" request authorization to have access to hardware
        audioController.onRecordingCompleted = { [weak self] fileURL in //closure that is executed when the AudioController completes a recording.
            self?.audioFileURL = fileURL //sets the file URL to the one that was captured in the closure of when the stopRecording function happens
           
        }
    }

    // Start the recording process using AudioController
    func startRecording() {
        audioController.startRecording()
        mode = .recording // Update mode to recording
        recordBtnDisabled = true // Disable the record button while recording
        // Bind STT result to the UI
        audioController.onRecordingCompleted = { [weak self] url in
            self?.audioFileURL = url
        }
    }

        // Stop the recording process and update the UI state
    func stopRecording() {
        audioController.stopRecording()
        mode = .ready // Re-enable mode once recording stops
        recordBtnDisabled = false
    }
    
    //function that handles discarding and deleting the audio file user does not want
    func discardTestAudio(fileURL: URL) {
        let fileManager = FileManager.default
        
        // Log the file URL and the path
        print("Trying to delete file at: \(fileURL.path)")
        
        // Check if the file exists at the fileURL path
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                // Try to remove the file
                try fileManager.removeItem(at: fileURL)
                print("Successfully deleted file at: \(fileURL.path)")
            } catch {
                // Handle errors during file deletion
                print("Could not delete file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at: \(fileURL.path)")
        }
    }

    // Function to submit the last recorded audio for analysis
    //Notes
    //1) we need to also need to save the audioFile its self in firebase
    //2) once we save the recording we must delete it localy
    func submitTestAudio(testText: String, lessonType: String) {
        guard let audioURL = audioFileURL else {
            print("Error: No valid file URL for the recording.")
            return
        }
        
        audioAPIController.transcribeAndAssessAudio(audioURL: audioURL, referenceText: testText, lessonType: lessonType) { result in
            switch result {
            case .success(let resultJson):
                DispatchQueue.main.async {
                    print("Pronunciation Assessment Result: \(resultJson)")
                    self.dataHelper.uploadUserLessonData(data: resultJson)
                    self.dataHelper.fetchAndAddDayAndTimestampToAssessment { success in
                     if success {
                     print("DayOfWeek and Timestamp were successfully added/updated.")
                      } else {
                       print("Failed to update DayOfWeek and Timestamp.")
                                              }
                                          }
                    self.discardTestAudio(fileURL: audioURL) //discard the audio after we save it to firebase

                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error during assessment: \(error)")
                }
            }
        }
    }

    // Function to submit text to AI Voice gallery and get an audio file back to play
    func submitTextToSpeechAI(testText: String) {
        audioAPIController.sendTextToVoiceGallery(testText: testText ) { result in
            switch result {
            case .success(let audioData):
                print("Received AI Gallery data of size: \(audioData.count) bytes")
                // You can now save this data as an MP3 file or play it directly
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    
}
