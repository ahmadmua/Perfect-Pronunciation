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
    
    /// MARK: - Published Properties (for UI binding)
    @Published var STTresult: String = ""        // Live Transcription result from AudioController
    @Published var mode: RecordingMode = .ready  // Recorder mode
    @Published var recordBtnDisabled = true      // Button state for record button
    @Published var userAudioFileURL: URL?            // Stores the recorded file URL
    @Published var aiaudioFileURL: URL?            // Stores the recorded file URL
    @Published var isSubmitting: Bool = false    // Prevent double submissions
    @Published var errorMessage: String?         // Error message for UI

    // Combine for state changes
    var objectWillChange = PassthroughSubject<VoiceRecorderController, Never>()
    
    // Dependencies: Audio and API controllers
    var audioController: AudioController
    var audioAPIController: AudioAPIController
    var audioPlaybackController: AudioPlayBackController
    var dataHelper = DataHelper()            // Helper to manage data storage with firebase
    
    // Initialize with dependencies to allow for easier testing
    init(audioController: AudioController, audioAPIController: AudioAPIController, audioPlaybackController: AudioPlayBackController) {
        self.audioController = audioController
        self.audioAPIController = audioAPIController
        self.audioPlaybackController = audioPlaybackController
        super.init()
        setupAudioController()
    }
    
    // Setup the connection with AudioController to update UI based on audio events
    private func setupAudioController() {
        audioController.requestAuthorization()//when audiocontroller is "setup" request authorization to have access to hardware
        audioController.onRecordingCompleted = { [weak self] fileURL in //closure that is executed when the AudioController completes a recording.
            self?.userAudioFileURL = fileURL //sets the file URL to the one that was captured in the closure of when the stopRecording function happens
           
        }
    }

    // Start the recording process using AudioController
    // 1) may need to discard recording if an error happens during recording before user manualy stops
    func startRecording() {
        audioController.startRecording()
        mode = .recording // Update mode to recording
        recordBtnDisabled = true // Disable the record button while recording
        // Bind STT result to the UI
        audioController.$STTresult
            .receive(on: DispatchQueue.main)
            .assign(to: &$STTresult)
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
                self.userAudioFileURL = URL(string: "")
            } catch {
                // Handle errors during file deletion
                print("Could not delete file: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at: \(fileURL.path)")
        }
    }

    // Function to submit the last recorded audio for analysis - (NOT Fully Implemented)
    //1) we need to also need to save the audioFile its self in firebase
    //2) need to save the AI AudioClip as well to firebase
    func submitTestAudio(testText: String, lessonType: String) async {
        // Ensure `testText` is valid and not empty
        guard !testText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Error: Reference text is empty. Please provide valid input.")
            return
        }

        // Ensure `userAudioFileURL` is not nil
        guard let audioURL = userAudioFileURL else {
            print("Warning: userAudioFileURL is nil. Attempting to recover...")
            return
        }

        // Ensure the file exists at `userAudioFileURL`
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Error: Audio file does not exist at path: \(audioURL.path)")
            return
        }

        do {
            // Call the async function to transcribe and assess the audio
            let resultJson = try await audioAPIController.transcribeAndAssessAudio(
                audioURL: audioURL,
                referenceText: testText,
                lessonType: lessonType
            )

            // Validate the `resultJson` by checking essential fields
            guard !resultJson.assessment.isValid, // Assuming `assessment` has an `isEmpty` property
                  !resultJson.lessonType.isEmpty, // Assuming `lessonType` is a String
                  !resultJson.transcription.isEmpty else { // Assuming `transcription` is a String
                print("Error: Received invalid or incomplete result from audio assessment API.")
                return
            }




            // Perform UI updates and Firebase upload on the main thread
            DispatchQueue.main.async { [self] in
                print("Pronunciation Assessment Result: \(resultJson)")

                // Ensure both `userAudio` and `voiceGalleryAudio` are valid URLs
                if let userAudio = userAudioFileURL, FileManager.default.fileExists(atPath: userAudio.path),
                   let voiceGalleryAudio = aiaudioFileURL, FileManager.default.fileExists(atPath: voiceGalleryAudio.path) {
                    // Upload the assessment data and audio files to Firebase
                    self.dataHelper.uploadUserLessonData(
                        assessmentData: resultJson,
                        userAudio: userAudio,
                        voiceGalleryAudio: voiceGalleryAudio
                    )
                } else {
                    print("Error: One or both audio files are missing or invalid.")
                }

                // Add Day and Timestamp after upload
                self.dataHelper.fetchAndAddDayAndTimestampToAssessment { success in
                    if success {
                        print("DayOfWeek and Timestamp were successfully added/updated.")
                    } else {
                        print("Failed to update DayOfWeek and Timestamp.")
                    }
                }

                // Attempt to discard the local audio file after uploading
                print("Discarding Audio After Submission")
                do {
                    try self.discardTestAudio(fileURL: audioURL)
                    print("Successfully discarded audio file: \(audioURL.lastPathComponent)")
                } catch {
                    print("Error discarding audio file: \(error.localizedDescription)")
                }
            }
        } catch let error as URLError {
            // Handle network-related errors specifically
            print("Network error: \(error.localizedDescription)")
        } catch let error as DecodingError {
            // Handle decoding-related errors specifically
            print("Decoding error: \(error.localizedDescription)")
        } catch {
            // Handle any unexpected errors
            print("Unexpected error during assessment: \(error.localizedDescription)")
        }
    }





    // Function to submit text to AI Voice gallery and get an audio file back to play - (NOT Fully Implemented)
    //1) need to be able to dynamicaly give a voice based on users country
    func submitTextToSpeechAI(testText: String) async {
        do {
            // Use `await` to call the async function and get the result
            let audioData = try await audioAPIController.sendTextToVoiceGallery(testText: testText)

            // Process the received audio data
            print("Received AI Gallery data of size: \(audioData.count) bytes")

            // Save the audio data to a WAV file in the Documents directory
            if let fileURL = saveWavAudioToFile(audioData: audioData) {
                self.aiaudioFileURL = fileURL
                print("Saved AI audio file at: \(fileURL.path)")
                audioPlaybackController.fileURL = fileURL
                audioPlaybackController.startPlayback()
                audioPlaybackController.fileURL = URL(string: "")

            } else {
                print("Failed to save AI audio file.")
            }
        } catch {
            // Handle any errors that occurred during API calls
            print("Error: \(error.localizedDescription)")
        }
    }

    // Function to save WAV audio data to a file
    func saveWavAudioToFile(audioData: Data) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY 'at' HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
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

    

    
    
    func playAudio(){}
    
    func pauseAudio(){}

    
    
}
