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

class VoiceRecorderController: NSObject, ObservableObject {

    /// MARK: - Singleton Instance
    static let shared = VoiceRecorderController(audioController: AudioController(),
                                                audioAPIController: AudioAPIController(),
                                                audioPlaybackController: AudioPlayBackController())

    /// MARK: - Published Properties
    @Published var STTresult: String = ""
    @Published var mode: RecordingMode = .ready
    @Published var recordBtnDisabled = true
    @Published var userAudioFileURL: URL? // Stores the recorded file URL
    @Published var aiaudioFileURL: URL?   // Stores the AI-generated audio file URL
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?

    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    // Dependencies
    var audioController: AudioController
    var audioAPIController: AudioAPIController
    var audioPlaybackController: AudioPlayBackController
    var dataHelper = DataHelper()

    // Private initializer for singleton
    private init(audioController: AudioController, audioAPIController: AudioAPIController, audioPlaybackController: AudioPlayBackController) {
        self.audioController = audioController
        self.audioAPIController = audioAPIController
        self.audioPlaybackController = audioPlaybackController
        super.init()
        setupAudioController()
    }

    private func setupAudioController() {
        audioController.requestAuthorization()
        audioController.onRecordingCompleted = { [weak self] fileURL in
            self?.userAudioFileURL = fileURL
        }
    }

    // MARK: - Recording Functions
    func startRecording() {
        audioController.startRecording()
        mode = .recording
        recordBtnDisabled = true
        audioController.$STTresult
            .receive(on: DispatchQueue.main)
            .assign(to: &$STTresult)
    }

    func stopRecording() {
        audioController.stopRecording()
        mode = .ready
        recordBtnDisabled = false
    }

    func discardTestAudio(fileURL: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                self.userAudioFileURL = nil
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

        guard let userAudio = userAudioFileURL, FileManager.default.fileExists(atPath: userAudio.path) else {
            print("Error: User audio file does not exist.")
            return
        }

        guard let aiAudio = aiaudioFileURL, FileManager.default.fileExists(atPath: aiAudio.path) else {
            print("Error: AI-generated audio file does not exist.")
            return
        }

        do {
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
            let audioData = try await audioAPIController.sendTextToVoiceGallery(testText: testText)
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

    // MARK: - Helper Functions
    func saveWavAudioToFile(audioData: Data) -> URL? {
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



    func playAudio(fileURL: URL?) {
        guard let fileURL = fileURL else {
            print("Error: No audio file URL is provided.")
            return
        }
        audioPlaybackController.fileURL = fileURL
        audioPlaybackController.startPlayback()
    }

    func pauseAudio() {
        audioPlaybackController.pausePlayback()
    }

    func stopAudio() {
        audioPlaybackController.stopPlayback()
    }
}
