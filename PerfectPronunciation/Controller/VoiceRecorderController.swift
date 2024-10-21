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
