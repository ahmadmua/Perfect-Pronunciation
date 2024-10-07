//
//  AsessmentDetails.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2024-10-06.
//

import SwiftUI

struct AssessmentView: View {
    @State var accuracyScore: Float // New property to receive the score

    @State private var progress: Double = 16.0
    @State private var mispronunciationsCount = 0
    @State private var omissionsCount = 0
    @State private var insertionsCount = 0
    @State private var unexpectedBreaksCount = 0
    @State private var missingBreaksCount = 0
    @State private var monotoneCount = 0
    @State private var predictionResult: String? = nil

    let fields = ["Mispronunciations", "Omissions", "Insertions", "Unexpected_break", "Missing_break", "Monotone"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sentence Section - Full Width
            VStack(alignment: .leading) {
                Text(buildAttributedText())
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
                    CircularScoreView(score: Int(accuracyScore)) // Use passed score here
                        .padding(.top, 8)
                }
                .padding(.leading)

                Spacer()

                // Error Labels on the Right
                VStack(alignment: .leading, spacing: 15) {
                    ErrorLabelView(errorType: "Mispronunciations", color: .yellow, count: mispronunciationsCount)
                    ErrorLabelView(errorType: "Omissions", color: .gray, count: omissionsCount)
                    ErrorLabelView(errorType: "Insertions", color: .red, count: insertionsCount)
                    ErrorLabelView(errorType: "Unexpected break", color: .pink, count: unexpectedBreaksCount)
                    ErrorLabelView(errorType: "Missing break", color: .blue, count: missingBreaksCount)
                    ErrorLabelView(errorType: "Monotone", color: .purple, count: monotoneCount)
                }
                .padding(.leading, 12)
            }

            // Score Breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Score breakdown")
                    .font(.headline)
                ScoreBar(label: "Accuracy score", score: Int(accuracyScore))
                ScoreBar(label: "Completeness score", score: 93)
                ScoreBar(label: "Fluency score", score: 84)
                ScoreBar(label: "Prosody score", score: 87)
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
            updateErrorCounts()
            predictionResult = predictPronunciationImprovement(mispronunciations: 1, omissions: 2, insertions: 2, unexpectedBreak: 2, missingBreak: 2.0, monotone: 2)
        }
    }

    // Remaining methods stay the same

    

    // Function to build the highlighted text
    func buildAttributedText() -> AttributedString {
        var attributedText = AttributedString("today was a beautiful day. we had a great time taking a long walk outside in the morning. the countryside was in full bloom, yet the air was crisp and cold. towards the end of the day, clouds came in, forecasting much needed rain.")

        // Apply colors and formatting for errors
        if let range = attributedText.range(of: "long") {
            attributedText[range].backgroundColor = .red
            insertionsCount += 1
        }

        if let range = attributedText.range(of: "outside") {
            attributedText[range].backgroundColor = .gray
            omissionsCount += 1
        }

        if let range = attributedText.range(of: "countryside") {
            attributedText[range].backgroundColor = .yellow
            mispronunciationsCount += 1
        }

        if let range = attributedText.range(of: "the") {
            attributedText[range].backgroundColor = .gray
            omissionsCount += 1
        }

        return attributedText
    }

    // Function to update the error counts
    private func updateErrorCounts() {
        // Reset counts
        mispronunciationsCount = 0
        omissionsCount = 0
        insertionsCount = 0
        unexpectedBreaksCount = 0
        missingBreaksCount = 0
        monotoneCount = 0

        // Call buildAttributedText to count errors
        _ = buildAttributedText() // This will trigger the counting
    }

    // Function to predict pronunciation improvement
    func predictPronunciationImprovement(mispronunciations: Double, omissions: Double, insertions: Double, unexpectedBreak: Double, missingBreak: Double, monotone: Double) -> String? {
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
    var score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .opacity(0.3)
                .foregroundColor(Color.green)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(score) / 100.0, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: score)

            Text("\(score)")
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

