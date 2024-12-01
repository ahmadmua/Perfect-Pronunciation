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



// Enum representing the different states of the recorder and playback
enum Mode {
    case ready          // Ready to start recording or playback
    case recording      // Currently recording audio
    case analyzing      // Analyzing the recorded audio
    case playing        // Audio is being played back
    case paused         // Playback is paused

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

// Main controller class managing recording, playback, and submissions
class VoiceRecorderController: NSObject, ObservableObject, PlaybackDelegate {
    // Singleton instance for global access
    static let shared = VoiceRecorderController(
        audioController: AudioController(),
        audioAPIController: AudioAPIController(),
        audioPlaybackController: AudioPlayBackController()
    )

    /// MARK: - Published Properties
    @Published var STTresult: String = ""          // Holds the Speech-to-Text result
    @Published var mode: Mode = .ready            // Tracks the current mode/state
    @Published var recordBtnDisabled = true       // Indicates if the record button should be disabled
    @Published var userAudioFileURL: URL?         // URL for the recorded audio file
    @Published var aiaudioFileURL: URL?           // URL for the AI-generated audio file
    @Published var isSubmitting: Bool = false     // Indicates if submission is in progress
    @Published var errorMessage: String?          // Holds error messages (if any)

    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>() // Notifies the UI of state changes

    // Dependencies
    var audioController: AudioController          // Handles audio recording functionality
    var audioAPIController: AudioAPIController    // Manages interactions with APIs for speech analysis
    var audioPlaybackController: AudioPlayBackController // Manages audio playback
    var dataHelper = DataHelper()                 // Helper for saving and uploading data

    // Private initializer to enforce singleton pattern
    private init(audioController: AudioController, audioAPIController: AudioAPIController, audioPlaybackController: AudioPlayBackController) {
        self.audioController = audioController
        self.audioAPIController = audioAPIController
        self.audioPlaybackController = audioPlaybackController
        super.init()

        // Assign this class as the playback delegate
        self.audioPlaybackController.playbackDelegate = self

        setupAudioController() // Configure the audio controller
    }

    // MARK: - Setup Audio Controller
    private func setupAudioController() {
        // Request microphone access from the user
        audioController.requestAuthorization()

        // Callback to store the URL of the completed recording
        audioController.onRecordingCompleted = { [weak self] fileURL in
            self?.userAudioFileURL = fileURL
        }
    }

    // MARK: - Recording Functions
    func startRecording() {
        // Start recording audio
        audioController.startRecording()
        mode = .recording                      // Update mode to recording
        recordBtnDisabled = true               // Disable the record button during recording
        // Assign Speech-to-Text result binding
        audioController.$STTresult
            .receive(on: DispatchQueue.main)
            .assign(to: &$STTresult)
    }

    func stopRecording() {
        // Stop recording audio
        audioController.stopRecording()
        mode = .ready                          // Update mode to ready
        recordBtnDisabled = false              // Enable the record button
    }

    func discardTestAudio(fileURL: URL) {
        // Delete the recorded audio file
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                self.userAudioFileURL = nil    // Clear the stored file URL
                print("User Audio File Deleted")
            } catch {
                print("Could not delete file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at: \(fileURL.path)")
        }
    }

    // MARK: - Submission Functions
    func submitTestAudio(testText: String, lessonType: String) async {
        guard !testText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Error: Reference text is empty. Please provide valid input.")
            return
        }

        // Validate recorded audio file existence
        guard let userAudio = userAudioFileURL, FileManager.default.fileExists(atPath: userAudio.path) else {
            print("Error: User audio file does not exist.")
            return
        }

        // Validate AI-generated audio file existence
        guard let aiAudio = aiaudioFileURL, FileManager.default.fileExists(atPath: aiAudio.path) else {
            print("Error: AI-generated audio file does not exist.")
            return
        }

        do {
            // Perform pronunciation assessment using the API
            let resultJson = try await audioAPIController.transcribeAndAssessAudio(
                audioURL: userAudio,
                referenceText: testText,
                lessonType: lessonType
            )
            print("Pronunciation Assessment Result: \(resultJson)")

            // Upload user and AI audio files to Firebase
            dataHelper.uploadUserLessonData(assessmentData: resultJson, userAudio: userAudio, voiceGalleryAudio: aiAudio)
        } catch {
            print("Error during assessment: \(error.localizedDescription)")
        }
    }

    func submitTextToSpeechAI(testText: String) async {
        do {
            // Request AI-generated audio from the API
            let audioData = try await audioAPIController.sendTextToVoiceGallery(testText: testText)
            if let fileURL = saveWavAudioToFile(audioData: audioData) {
                aiaudioFileURL = fileURL // Save the AI-generated audio file URL
                print("Saved AI audio file at: \(fileURL.path)")
            } else {
                print("Failed to save AI audio file.")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Functions
    func saveWavAudioToFile(audioData: Data) -> URL? {
        // Save audio data to a file and return its URL
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let audioFilename = documentsURL.appendingPathComponent("AIAudio \(timestamp).wav")
        do {
            try audioData.write(to: audioFilename)
            return audioFilename
        } catch {
            print("Failed to save WAV file: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Playback Functions
    func playAudio(fileURL: URL?) {
        guard let fileURL = fileURL else {
            print("Error: No audio file URL is provided.")
            return
        }
        audioPlaybackController.fileURL = fileURL
        audioPlaybackController.startPlayback() // Start audio playback
        mode = .playing                        // Update mode to playing
    }

    func pauseAudio() {
        // Pause audio playback
        audioPlaybackController.pausePlayback()
        mode = .paused                         // Update mode to paused
    }

    func resumeAudio() {
        // Resume audio playback if paused
        guard mode == .paused else {
            print("Error: Cannot resume audio, as it is not paused.")
            return
        }
        audioPlaybackController.resumePlayback()
        mode = .playing                        // Update mode to playing
    }

    func stopAudio() {
        // Stop audio playback
        audioPlaybackController.stopPlayback()
        mode = .ready                          // Update mode to ready
    }

    // MARK: - PlaybackDelegate Method
    func playbackDidFinishSuccessfully() {
        // Called when playback finishes successfully
        DispatchQueue.main.async {
            self.mode = .ready                 // Reset mode to ready
            print("Playback finished, state reset to ready.")
        }
    }
}

