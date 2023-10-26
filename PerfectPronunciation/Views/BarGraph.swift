import SwiftUI
import Charts

struct AccuracyBarChart: View {
    var data: [Accuracy]
    
    var range: ClosedRange<Int>
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Accuracy", item.weekday),
                    y: .value("Words", item.accuracy)
                )
                .annotation(position: AnnotationPosition.top) {
                    Text("\(item.accuracy, format: .number.precision(.fractionLength(2)))")
                        // Add minimum width to avoid truncation artifacts
                        // when value changes
                        .frame(minWidth: 100)
                        .font(.caption2)
                }
                .foregroundStyle(.blue.gradient)
            }
        }
        .chartYScale(domain: range)
    }
}


struct Words: View {
    
    var weekly: String
    
    var sum: Double
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text("Weekly Average Accuracy")
            .font(.title2)
            
            Text("56% - Moderate Words Difficulty")
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }
}


struct StatPicker: View {
    var options: [PickerOption]
    var selection: Binding<Int>
    
    var body: some View {
        Picker("Accuracy", selection: selection) {
            ForEach(options, id: \.name) { option in
                Text(option.name).tag(option.tag)
            }
        }
        .pickerStyle(.segmented)
    }
}



