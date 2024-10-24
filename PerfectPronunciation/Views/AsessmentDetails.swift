//
//  AsessmentDetails.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2024-10-06.
//

import SwiftUI

struct AssessmentView: View {
    @State var accuracyScore: Double
    @State var completenessScore: Double
    @State var fluencyScore: Double
    @State var confidence: Double
    @State var pronScores: Double
    @State var display: String

    @State private var progress: Double = 16.0
    @State private var predictionResult: String? = nil
    @State var errorTypeCounts: [String: Int]
    var wordErrorData: [(word: String, errorType: String)]

    let fields = ["Mispronunciations", "Omissions", "Insertions", "Unexpected_break", "Missing_break", "Monotone"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sentence Section - Full Width
            VStack(alignment: .leading) {
                Text(buildAttributedText(display: display, wordErrorData: wordErrorData))
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)

            // Pronunciation Score and Errors Section
            HStack(alignment: .top) {
                // Pronunciation Score
                VStack(alignment: .leading) {
                    Text("Pronunciation score")
                        .font(.headline)
                    CircularScoreView(score: pronScores)
                        .padding(.top, 8)
                }
                .padding(.leading)

                Spacer()

                // Error Labels on the Right
                VStack(alignment: .leading, spacing: 15) {
                    ErrorLabelView(errorType: "Mispronunciations", color: .yellow,  count: errorTypeCounts["Mispronunciation"] ?? 0)
                    ErrorLabelView(errorType: "Omissions", color: .gray, count: errorTypeCounts["Omission"] ?? 0)
                    ErrorLabelView(errorType: "Insertions", color: .red, count: errorTypeCounts["Insertion"] ?? 0)
                    ErrorLabelView(errorType: "Unexpected break", color: .pink, count: errorTypeCounts["UnexpectedBreak"] ?? 0)
                    ErrorLabelView(errorType: "Missing break", color: .blue, count: errorTypeCounts["MissingBreak"] ?? 0)
                    ErrorLabelView(errorType: "Monotone", color: .purple, count: errorTypeCounts["Monotone"] ?? 0)
                }
                .padding(.leading, 12)
            }

            // Score Breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Score breakdown")
                    .font(.headline)
                ScoreBar(label: "Accuracy score", score: Int(accuracyScore))
                ScoreBar(label: "Completeness score", score: Int(completenessScore))
                ScoreBar(label: "Fluency score", score: Int(fluencyScore))
                ScoreBar(label: "Confidence", score: Int(confidence * 100))
            }
            .padding(.horizontal)

            // Display the prediction result below the score breakdown
            if let result = predictionResult {
                Text(result)
                    .font(.title2) // Increased font size
                    .fontWeight(.semibold) // Make the text semi-bold for emphasis
                    .multilineTextAlignment(.center) // Center align text
                    .padding() // Add some padding around the text
                    .frame(maxWidth: .infinity) // Ensure it takes full width
                    .foregroundColor(.primary) // Use primary color for better visibility
                    .padding(.horizontal) // Add horizontal padding for spacing
            }

            Spacer()
        }
        .navigationTitle("Assessment Result")
        .onAppear {
            predictionResult = predictPronunciationImprovement(mispronunciations: Double(errorTypeCounts["Mispronunciation"] ?? 0), omissions: Double(errorTypeCounts["Omission"] ?? 0), insertions: Double(errorTypeCounts["Insertion"] ?? 0), unexpectedBreak: Double(errorTypeCounts["UnexpectedBreak"] ?? 0), missingBreak: Double(errorTypeCounts["MissingBreak"] ?? 0), monotone: Double(errorTypeCounts["Monotone"] ?? 0))
        }
        .onDisappear(){
            
        }
    }

    // Remaining methods stay the same

    

    // Function to build the highlighted text
    func buildAttributedText(display: String, wordErrorData: [(word: String, errorType: String)]) -> AttributedString {
        var attributedText = AttributedString(display)

        for wordError in wordErrorData {
            if let range = attributedText.range(of: wordError.word) {
                print("Processing word: '\(wordError.word)' with error type: '\(wordError.errorType)'")

                // Check for a valid errorType
                if !wordError.errorType.isEmpty { // Only process if errorType is not empty
                    switch wordError.errorType {
                    case "Mispronunciation":
                        attributedText[range].foregroundColor = .yellow
                    case "Omission":
                        attributedText[range].foregroundColor = .gray
                    case "Insertion":
                        attributedText[range].foregroundColor = .red
                    case "Unexpected_break":
                        attributedText[range].foregroundColor = .pink
                    case "Missing_break":
                        attributedText[range].foregroundColor = .blue
                    case "Monotone":
                        attributedText[range].foregroundColor = .purple
                    default:
                        print("Unknown error type for word '\(wordError.word)': \(wordError.errorType)")
                    }
                } else {
                    print("No error type found for word: '\(wordError.word)'")
                }
            } else {
                print("Word not found in attributed text: '\(wordError.word)'")
            }
        }

        return attributedText
    }



    // Function to predict pronunciation improvement
    func predictPronunciationImprovement(mispronunciations: Double, omissions: Double, insertions: Double, unexpectedBreak: Double, missingBreak: Double, monotone: Double) -> String? {
        // Check if all input values are 0
        if mispronunciations == 0 && omissions == 0 && insertions == 0 && unexpectedBreak == 0 && missingBreak == 0 && monotone == 0 {
            return "No errors detected in the speech Assessment"
        }

        do {
            let model = try PronunciationImprovementModel(configuration: .init())
            let input = PronunciationImprovementModelInput(Mispronunciations: mispronunciations,
                                                           Omissions: omissions,
                                                           Insertions: insertions,
                                                           Unexpected_break: unexpectedBreak,
                                                           Missing_break: missingBreak,
                                                           Monotone: monotone)

            let output = try model.prediction(input: input)
            let predictedIndex = Int(output.classLabel)

            if predictedIndex >= 0 && predictedIndex < fields.count {
                return "Field needing improvement: \(fields[predictedIndex])"
            } else {
                return "Invalid prediction index"
            }

        } catch {
            print("Error predicting pronunciation improvement: \(error)")
            return nil
        }
    }

}

// Additional Views

struct CircularScoreView: View {
    var score: Double

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 12)
                .opacity(0.3)
                .foregroundColor(Color.green)

            // Circular progress based on score
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: score)

            // Display the score rounded to 2 decimal places in the center
            Text(String(format: "%.1f", score))
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.green)
        }
        .frame(width: 120, height: 120)
        .padding()
    }
}

    





struct ScoreBar: View {
    var label: String
    var score: Int

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Text("\(score)/100")
            }
            ProgressView(value: Double(score), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding(.vertical, 5)
    }
}

struct ErrorLabelView: View {
    var errorType: String
    var color: Color
    var count: Int

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)

            Text("\(errorType) (\(count))")
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

//struct AssessmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AssessmentView()
//    }
//}
