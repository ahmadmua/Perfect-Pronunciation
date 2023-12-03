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
    //let error: JSONNull?
    let gender_analysis_result: GenderAnalysisResult
    let pronunciation_score_percentage: PronunciationScorePercentage
    let total_speech_analysis_results: TotalSpeechAnalysisResults

    struct GenderAnalysisResult: Codable {
        let result: String
    }


    struct PronunciationScorePercentage: Codable {
        let pronunciationScorePercentage: Double

    }

    struct TotalSpeechAnalysisResults: Codable {
        let dataset: Dataset
    }


    struct Dataset: Codable {
        let articulation_rate: String
        let balance: String
        let f0_max: String
        let f0_mean: String
        let f0_median: String
        let f0_quan75: String
        let f0_quantile25: String
        let f0_std: String
        let number_of_pauses: String
        let number_of_syllables: String
        let original_duration: String
        let rate_of_speech: String
        let speaking_duration: String

        
    }
    
    init(){
        gender_analysis_result = GenderAnalysisResult.init(result: "")
        pronunciation_score_percentage = PronunciationScorePercentage.init(pronunciationScorePercentage: 0.0)
        total_speech_analysis_results = TotalSpeechAnalysisResults(dataset: Dataset.init(articulation_rate: "", balance: "", f0_max: "", f0_mean: "", f0_median: "", f0_quan75: "", f0_quantile25: "", f0_std: "", number_of_pauses: "", number_of_syllables: "", original_duration: "", rate_of_speech: "", speaking_duration: ""))
    }
}



// MARK: - Encode/decode helpers

//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
