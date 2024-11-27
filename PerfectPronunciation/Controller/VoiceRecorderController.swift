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
    case paused

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
            return "Audio Playing"
        case .paused:
            return "Audio Paused"
        }
    }
}

// This class handles high-level functions of VoiceRecorderView and interacts with AudioController
class VoiceRecorderController: NSObject, ObservableObject {
    
    /// MARK: - Singleton Instance
    static let shared = VoiceRecorderController(audioController: AudioController(),
                                                audioAPIController: AudioAPIController(),
                                                audioPlaybackController: AudioPlayBackController())
    
    /// MARK: - Published Properties (for UI binding)
    @Published var STTresult: String = ""        // Live Transcription result from AudioController
    @Published var mode: RecordingMode = .ready  // Recorder mode
    @Published var recordBtnDisabled = true      // Button state for record button
    @Published var userAudioFileURL: URL?        // Stores the recorded file URL
    @Published var aiaudioFileURL: URL?          // Stores the AI-generated audio file URL
    @Published var isSubmitting: Bool = false    // Prevent double submissions
    @Published var errorMessage: String?         // Error message for UI

    // Combine for state changes
    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    // Dependencies: Audio and API controllers
    var audioController: AudioController
    var audioAPIController: AudioAPIController
    var audioPlaybackController: AudioPlayBackController
    var dataHelper = DataHelper()            // Helper to manage data storage with Firebase
    
    // Private initializer to enforce the singleton pattern
    private init(audioController: AudioController, audioAPIController: AudioAPIController, audioPlaybackController: AudioPlayBackController) {
        self.audioController = audioController
        self.audioAPIController = audioAPIController
        self.audioPlaybackController = audioPlaybackController
        super.init()
        setupAudioController()
    }
    
    // Setup the connection with AudioController to update UI based on audio events
    private func setupAudioController() {
        audioController.requestAuthorization() // Request authorization for hardware access
        audioController.onRecordingCompleted = { [weak self] fileURL in
            self?.userAudioFileURL = fileURL // Update the recorded file URL when recording completes
        }
    }

    // Start the recording process using AudioController
    func startRecording() {
        audioController.startRecording()
        mode = .recording
        recordBtnDisabled = true
        audioController.$STTresult
            .receive(on: DispatchQueue.main)
            .assign(to: &$STTresult)
    }

    // Stop the recording process and update the UI state
    func stopRecording() {
        audioController.stopRecording()
        mode = .ready
        recordBtnDisabled = false
    }

    // Function to discard and delete an audio file
    func discardTestAudio(fileURL: URL) {
        let fileManager = FileManager.default
        print("Trying to delete file at: \(fileURL.path)")
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("Successfully deleted file at: \(fileURL.path)")
                self.userAudioFileURL = nil
            } catch {
                print("Could not delete file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at: \(fileURL.path)")
        }
    }

    // Function to submit text to AI Voice gallery and get an audio file back to play
    func submitTextToSpeechAI(testText: String) async {
        do {
            let audioData = try await audioAPIController.sendTextToVoiceGallery(testText: testText)
            print("Received AI Gallery data of size: \(audioData.count) bytes")
            if let fileURL = saveWavAudioToFile(audioData: audioData) {
                aiaudioFileURL = fileURL
                print("Saved AI audio file at: \(fileURL.path)")
            } else {
                print("Failed to save AI audio file.")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    // Function to submit the last recorded audio for analysis
    func submitTestAudio(testText: String, lessonType: String) async {
        guard !testText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Error: Reference text is empty. Please provide valid input.")
            return
        }

        guard let audioURL = userAudioFileURL, FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Error: Audio file does not exist.")
            return
        }

        do {
            let resultJson = try await audioAPIController.transcribeAndAssessAudio(
                audioURL: audioURL,
                referenceText: testText,
                lessonType: lessonType
            )

            DispatchQueue.main.async { [self] in
                print("Pronunciation Assessment Result: \(resultJson)")
                //MARK: For Some Reason this wont submit the First Audio Test After Starting Application, Issue with the If Statement, seems the AI audio does not get called properly on first Induvidual Test View so there wont be an AudioFIle
                if let userAudio = userAudioFileURL, let voiceGalleryAudio = aiaudioFileURL {
                    dataHelper.uploadUserLessonData(assessmentData: resultJson, userAudio: userAudio, voiceGalleryAudio: voiceGalleryAudio)
                }
                print("Discarding Audio After Submission")
                do {
                    try discardTestAudio(fileURL: audioURL)
                } catch {
                    print("Error discarding audio file: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error during assessment: \(error.localizedDescription)")
        }
    }

    // Function to save WAV audio data to a file
    func saveWavAudioToFile(audioData: Data) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let audioFilename = documentsURL.appendingPathComponent("AIAudio \(timestamp).wav")
        do {
            try audioData.write(to: audioFilename)
            print("WAV file saved at: \(audioFilename.path)")
            return audioFilename
        } catch {
            print("Failed to save WAV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    func clearAudioFiles() {
        userAudioFileURL = nil
        aiaudioFileURL = nil
    }

    // Explicitly play AI audio
    func playAudio(fileURL: URL?) {
        guard let fileURL = fileURL else {
            print("Error: No audio file URL is provided.")
            return
        }
        audioPlaybackController.fileURL = fileURL
        audioPlaybackController.startPlayback()
    }


    // Pause AI audio playback
    func pauseAudio() {
        audioPlaybackController.pausePlayback()
    }

    // Stop AI audio playback
    func stopAudio() {
        audioPlaybackController.stopPlayback()
    }
    
}


