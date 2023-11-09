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

class AudioController: NSObject, ObservableObject {
    @Published var btnTitle: String = "Start Recording"
    @Published var STTresult: String = "Listening"
    @Published var recordBtnDisabled = true
    
    private var audioRecorder: AVAudioRecorder?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?

    
    override init() {
        super.init()
        setupAudioFileForRecording()
    }
    
    func requestAuthorization() {
           SFSpeechRecognizer.requestAuthorization { authStatus in
               DispatchQueue.main.async {
                   switch authStatus {
                   case .authorized:
                       self.recordBtnDisabled = false
                   case .denied, .restricted, .notDetermined:
                       self.recordBtnDisabled = true
                       self.btnTitle = "Microphone/Speech access is not authorized"
                   default:
                       self.recordBtnDisabled = true
                       self.btnTitle = "Microphone/Speech access is not authorized"
                   }
               }
           }
       }
    
    private func setupAudioFileForRecording() {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsDirectory.appendingPathComponent("recording.wav")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false
            ] as [String : Any]

            do {
                audioFile = try AVAudioFile(forWriting: audioFilename, settings: settings, commonFormat: .pcmFormatInt16, interleaved: true)
            } catch {
                print("Unable to create audio file: \(error)")
            }
        }
    
    func startRecording() throws {
        // Check if audioEngine is already running
        if audioEngine.isRunning {
            // Stop the audioEngine and end the recognition request
            audioEngine.stop()
            recognitionRequest?.endAudio()
            btnTitle = "Start Listening"
        } else {
            // Cancel the previous task if it's running
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Setup the audio session for recording
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // Get the input node and create a new recognition request
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a new SFSpeechAudioBufferRecognitionRequest.")
            }
            recognitionRequest.shouldReportPartialResults = true

            // Start a new recognition task
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
                guard let self = self else { return }
                var isFinal = false

                if let result = result {
                    // Accessing the SFVoiceAnalytics from the result
                    if #available(iOS 13, *) {
                        let voiceAnalytics = result.bestTranscription.segments.last?.voiceAnalytics
                        // Here you can access voiceAnalytics.jitter, voiceAnalytics.shimmer, etc.
                    }
                    
                    self.STTresult = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }

                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionTask = nil
                    self.recognitionRequest = nil
                    self.recordBtnDisabled = false
                    self.btnTitle = "Start Listening"
                }
            })

            // Define the recording format
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Install an audio tap on the input node
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                self?.recognitionRequest?.append(buffer)

                do {
                    try self?.audioFile?.write(from: buffer)
                } catch {
                    print("Error writing audio to file: \(error)")
                }
            }

            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()

            // Update the UI state
            STTresult = "Listening Started"
            btnTitle = "Stop Listening"
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioRecorder?.stop()
        btnTitle = "Start Recording"
        STTresult = "Stopped Listening"
    }
}
