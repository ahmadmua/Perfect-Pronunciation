//
//  AudioAnalysis.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.
//

import Foundation


import Foundation

// MARK: - Welcome
struct AudioAnalysis: Codable {
    let error: JSONNull?
    let genderAnalysisResult: GenderAnalysisResult
    let pronunciationScorePercentage: PronunciationScorePercentage
    let totalSpeechAnalysisResults: TotalSpeechAnalysisResults

    enum CodingKeys: String, CodingKey {
        case error
        case genderAnalysisResult = "gender_analysis_result"
        case pronunciationScorePercentage = "pronunciation_score_percentage"
        case totalSpeechAnalysisResults = "total_speech_analysis_results"
    }
}

// MARK: - GenderAnalysisResult
struct GenderAnalysisResult: Codable {
    let result: String
}

// MARK: - PronunciationScorePercentage
struct PronunciationScorePercentage: Codable {
    let pronunciationScorePercentage: Double

    enum CodingKeys: String, CodingKey {
        case pronunciationScorePercentage = "pronunciation_score_percentage"
    }
}

// MARK: - TotalSpeechAnalysisResults
struct TotalSpeechAnalysisResults: Codable {
    let dataset: [String: Dataset]
}

// MARK: - Dataset
struct Dataset: Codable {
    let the0: String

    enum CodingKeys: String, CodingKey {
        case the0 = "0"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
