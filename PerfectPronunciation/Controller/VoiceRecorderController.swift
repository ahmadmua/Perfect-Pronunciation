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

// This class handles high-level functions of VoiceRecorderView and interacts with AudioController
class VoiceRecorderController: NSObject, ObservableObject {
    
    // MARK: - Published Properties (for UI binding)
    @Published var STTresult: String = ""  // Transcription result from AudioController
    @Published var mode: String = "Start Recording"
    @Published var recordBtnDisabled = true
    @Published var audioFileURL: URL?  // Stores the recorded file URL

    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    var audioController = AudioController()  // Use audioController for recording and speech recognition
    var dataHelper = DataHelper()            // Helper to manage data storage with firebase
    var audioAPIController = AudioAPIController.shared // Shared instance for audio API calls
    
    override init() {
        super.init()
        setupAudioController()
    }
    
    // Setup the connection with AudioController to update UI based on audio events
    private func setupAudioController() {
        audioController.requestAuthorization()//when audiocontroller is "setup" request authorization to have access to hardware

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

    // Function to submit the last recorded audio for analysis
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
        audioAPIController.sendTextToVoiceGallery(testText: testText) { result in
            switch result {
            case .success(let audioData):
                DispatchQueue.main.async {
                    print("Audio clip successfully obtained and stored.")
                    // You can now trigger audio playback here if needed
                }
            case .failure(let error):
                print("Failed to get audio clip: \(error)")
            }
        }
    }
}
