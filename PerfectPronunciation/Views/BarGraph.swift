import SwiftUI
import Charts

struct AccuracyBarChart: View {
    
    @State private var selection: Int? = nil
    
    var data: [Accuracy]
    
    var range: ClosedRange<Int>
    
    var body: some View {
        
        VStack{
            
            NavigationLink(destination: Details(), tag: 1, selection: self.$selection){}
            
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
                    .foregroundStyle(.yellow.gradient)
                }
            }
            .frame(height: 400)
            
            Text("Recent Results")
                .underline()
            
            Spacer()
            
            HStack {
                Text("Word 1 - 40%")
                Spacer()
                Text("Word 2 - 74%")
            }
            
            Spacer()
            
            HStack {
                Text("Word 3 - 92%")
                Spacer()
                Text("Word 4 - 37%")
            }
            
            Spacer()
            
            Button(action: {
                self.selection = 1
            }){
                Text("Details")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                
                    .frame(maxWidth: .infinity)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .bold()
            }
            
        
        
        .chartYScale(domain: range)
    }
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



