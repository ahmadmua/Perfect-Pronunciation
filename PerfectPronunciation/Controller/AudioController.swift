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
    @Published var STTresult: String = ""
    @Published var recordBtnDisabled = true
    
    private var audioRecorder: AVAudioRecorder!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    
    let objectWillChange = PassthroughSubject<AudioController, Never>()

    var recording = Recording(fileURL: URL(string: "about:blank")!, createdAt: Date())
    
    var isRecording = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    override init() {
        super.init()
        fetchRecording()
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
    
    func fetchRecording() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            let audioFiles = directoryContents
                .filter { $0.pathExtension == "m4a" }
                .sorted {
                    let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1! > date2!
                }

            if let mostRecentFile = audioFiles.first {
                let fileDate = try mostRecentFile.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                recording = Recording(fileURL: mostRecentFile, createdAt: fileDate)
            }
        } catch {
            print("Error while fetching recordings: \(error)")
        }

        objectWillChange.send(self)
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
        } else {
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Failed to set up recording session")
            }
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.record()
                isRecording = true
            } catch {
                print("Could not start recording")
            }

            recognitionTask?.cancel()
            recognitionTask = nil

            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest.")
            }
            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
                guard let self = self else { return }
                var isFinal = false

                if let result = result {
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
                    self.isRecording = false
                }
            })

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                self?.recognitionRequest?.append(buffer)
            }

            do {
                audioEngine.prepare()
                try audioEngine.start()
            } catch {
                print("Could not start Audio Engine")
            }

            btnTitle = "Stop Listening"
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioRecorder?.stop()
        btnTitle = "Start Recording"
        //once audio stops fetch recording
        fetchRecording()
    }
    
    func submitAudio() {
        // Ensure that we have a valid file URL
        guard let audioURL = recording.fileURL else {
            print("Error: Invalid file URL")
            return
        }

        do {
            let audioData = try Data(contentsOf: audioURL)
            // No need to convert to base64String since we are sending Data directly
            // let base64String = audioData.base64EncodedString()

            let audioAPIController = AudioAPIController()
            audioAPIController.uploadAudio(audioData: audioData) { result in
                switch result {
                case .success(let analysis):
                    DispatchQueue.main.async {
                        print("Audio Analysis: \(analysis)")
                        // Update your UI accordingly
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Error: \(error)")
                        // Handle the error in your UI
                    }
                }
            }
        } catch {
            print("Error: Unable to load audio file data - \(error)")
        }
    }

    
}






