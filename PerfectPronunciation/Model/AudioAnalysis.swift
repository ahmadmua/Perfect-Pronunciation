//
//  AudioAnalysis.swift
//  PerfectPronunciation
//
//  Created by Jordan Bhar on 2023-11-28.
//
struct AudioAnalysis: Codable {
    let error: String?
    let genderAnalysisResult: GenderAnalysisResult
    var pronunciationScorePercentage: PronunciationScorePercentage
    let totalSpeechAnalysisResults: TotalSpeechAnalysisResults

    struct GenderAnalysisResult: Codable {
        let result: String
    }

    struct PronunciationScorePercentage: Codable {
        var pronunciationScorePercentage: Double
    }

    struct TotalSpeechAnalysisResults: Codable {
        let dataset: Dataset
    }

    struct Dataset: Codable {
        let articulationRate: Value
        let balance: Value
        let f0Max: Value
        let f0Mean: Value
        let f0Median: Value
        let f0Min: Value
        let f0Quan75: Value
        let f0Quantile25: Value
        let f0Std: Value
        let numberOfPauses: Value
        let numberOfSyllables: Value
        let originalDuration: Value
        let rateOfSpeech: Value
        let speakingDuration: Value
    }
    
    struct Value: Codable {
        let value: String
        
        enum CodingKeys: String, CodingKey {
            case value = "0"
        }
    }
    
    struct ErrorValue: Codable {
        let code: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.code = try? container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(code)
        }
    }
    
    // Default initializer
    init() {
        self.error = String("Undefined")
        self.genderAnalysisResult = GenderAnalysisResult(result: "Undefined")
        self.pronunciationScorePercentage = PronunciationScorePercentage(pronunciationScorePercentage: 0.0)
        self.totalSpeechAnalysisResults = TotalSpeechAnalysisResults(
            dataset: Dataset(
                articulationRate: Value(value: "Undefined"),
                balance: Value(value: "Undefined"),
                f0Max: Value(value: "Undefined"),
                f0Mean: Value(value: "Undefined"),
                f0Median: Value(value: "Undefined"),
                f0Min: Value(value: "Undefined"),
                f0Quan75: Value(value: "Undefined"),
                f0Quantile25: Value(value: "Undefined"),
                f0Std: Value(value: "Undefined"),
                numberOfPauses: Value(value: "Undefined"),
                numberOfSyllables: Value(value: "Undefined"),
                originalDuration: Value(value: "Undefined"),
                rateOfSpeech: Value(value: "Undefined"),
                speakingDuration: Value(value: "Undefined")
            )
        )
    }
}

