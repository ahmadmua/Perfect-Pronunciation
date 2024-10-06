//
//  PronunciationAssessmentModel.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2024-10-05.
//

import Foundation

// Root object containing transcription and assessment
struct PronunciationAssessmentResult: Codable {
    let transcription: Transcription
    let assessment: Assessment
}

// MARK: - Transcription
struct Transcription: Codable {
    let duration: Int
    let displayText: String
    let recognitionStatus: String
    let nBest: [TranscriptionNBest]
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case duration = "Duration"
        case displayText = "DisplayText"
        case recognitionStatus = "RecognitionStatus"
        case nBest = "NBest"
        case offset = "Offset"
    }
}

// MARK: - TranscriptionNBest
struct TranscriptionNBest: Codable {
    let confidence: Double // Changed to Double
    let display: String
    let itn: String
    let lexical: String
    let maskedITN: String
    
    enum CodingKeys: String, CodingKey {
        case confidence = "Confidence"
        case display = "Display"
        case itn = "ITN"
        case lexical = "Lexical"
        case maskedITN = "MaskedITN"
    }
}

// MARK: - Assessment
struct Assessment: Codable {
    let recognitionStatus: String
    let nBest: [AssessmentNBest]
    
    enum CodingKeys: String, CodingKey {
        case recognitionStatus = "RecognitionStatus"
        case nBest = "NBest"
    }
}

// MARK: - AssessmentNBest
struct AssessmentNBest: Codable {
    let accuracyScore: Int
    let completenessScore: Int
    let confidence: Double // Changed to Double
    let display: String
    let fluencyScore: Int
    let itn: String
    let lexical: String
    let maskedITN: String
    let pronScore: StringOrDouble // Custom decoding for pronScore
    let words: [Word]
    
    enum CodingKeys: String, CodingKey {
        case accuracyScore = "AccuracyScore"
        case completenessScore = "CompletenessScore"
        case confidence = "Confidence"
        case display = "Display"
        case fluencyScore = "FluencyScore"
        case itn = "ITN"
        case lexical = "Lexical"
        case maskedITN = "MaskedITN"
        case pronScore = "PronScore"
        case words = "Words"
    }
}

// Custom enum to handle String or Double values for PronScore
enum StringOrDouble: Codable {
    case string(String)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(StringOrDouble.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected a string or double"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .double(let doubleValue):
            try container.encode(doubleValue)
        }
    }
}

// MARK: - Word
struct Word: Codable {
    let accuracyScore: Int
    let confidence: Double // Changed to Double
    let duration: Int
    let errorType: String
    let offset: Int
    let phonemes: [Phoneme]
    let syllables: [Syllable]?
    let word: String
    
    enum CodingKeys: String, CodingKey {
        case accuracyScore = "AccuracyScore"
        case confidence = "Confidence"
        case duration = "Duration"
        case errorType = "ErrorType"
        case offset = "Offset"
        case phonemes = "Phonemes"
        case syllables = "Syllables"
        case word = "Word"
    }
}

// MARK: - Phoneme
struct Phoneme: Codable {
    let accuracyScore: Int
    let duration: Int
    let offset: Int
    let phoneme: String
    
    enum CodingKeys: String, CodingKey {
        case accuracyScore = "AccuracyScore"
        case duration = "Duration"
        case offset = "Offset"
        case phoneme = "Phoneme"
    }
}

// MARK: - Syllable
struct Syllable: Codable {
    let accuracyScore: Int
    let duration: Int
    let grapheme: String?
    let offset: Int
    let syllable: String
    
    enum CodingKeys: String, CodingKey {
        case accuracyScore = "AccuracyScore"
        case duration = "Duration"
        case grapheme = "Grapheme"
        case offset = "Offset"
        case syllable = "Syllable"
    }
}
