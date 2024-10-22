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
}

// This class handles high-level functions of VoiceRecorderView and interacts with AudioController
class VoiceRecorderController: NSObject, ObservableObject {
    
    // MARK: - Published Properties (for UI binding)
    @Published var STTresult: String = ""  // Transcription result from AudioController
    @Published var mode: String = "Start Recording"
    @Published var recordBtnDisabled = true
    @Published var audioFileURL: URL?  // Stores the recorded file URL

    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    var audioController = AudioController()  // Use audioController for recording and speech recognition
    var audioAPIController = AudioAPIController.shared // Shared instance for audio API calls
    var dataHelper = DataHelper()            // Helper to manage data storage with firebase
    
    override init() {
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
        mode = "Listening ..."
        recordBtnDisabled = true  // Disable the record button while recording is in progress
        audioController.$STTresult
                    .receive(on: DispatchQueue.main)
                    .assign(to: &$STTresult)
    }

    // Stop the recording process and update the UI state
    func stopRecording() {
        audioController.stopRecording()
        mode = "Start Recording"
        recordBtnDisabled = false  // Re-enable the record button once recording stops
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
