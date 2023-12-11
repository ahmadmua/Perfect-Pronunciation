import SwiftUI
import Charts

struct AccuracyBarChart: View {
    
    @State private var selection: Int? = nil
    
    var data: [Accuracy]
    
    var range: ClosedRange<Int>
    
    @State var showDetails = false
    
    @EnvironmentObject var fireDBHelper: DataHelper
    @State private var accuracyAtIndexText = [0.0,0.0,0.0,0.0]
    @State private var nameAtIndexText = ["","","",""]
    @State private var showingAlert = false
    
    var body: some View {
        
        VStack{
            
            //NavigationLink(destination: Details(), tag: 1, selection: self.$selection){}
            
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
                Text("\(accuracyAtIndexText[0])%")
                Spacer()
                Text("\(accuracyAtIndexText[1])%")
            }
            
            Spacer()
            
            HStack {
                Text("\(accuracyAtIndexText[2])%")
                Spacer()
                Text("\(accuracyAtIndexText[3])%")
            }
            
            Spacer()
            
            Button(action: {
                self.showDetails.toggle()
            }){
                Text("Details")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                
                    .frame(maxWidth: .infinity)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .bold()
            }
            .navigationDestination(isPresented: $showDetails){
                Details(showingAlert: $showingAlert)
            }
            
        
        
        .chartYScale(domain: range)
    }
        .onAppear {
            
            for index in 0..<4 {
                fireDBHelper.getAccuracyAtIndex(index: index) { accuracy in
                    if let accuracy = accuracy {
                        accuracyAtIndexText[index] = Double(accuracy)
                    }
                }
            }
            
            for index in 0..<4 {
                fireDBHelper.getNameAtIndex(index: index) { word in
                    if let word = word {
                        nameAtIndexText[index] = String(word)
                    }
                }
            }
            
        }
        
        
    }
}

struct BarChart: View {

    @State private var selection: Int? = nil

    var data: [Accuracy]
    var range: ClosedRange<Int>

    var body: some View {

        VStack {

            //NavigationLink(destination: Details(), tag: 1, selection: self.$selection){}

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
            .font(.title3)
            .fontWeight(.semibold)
            
//            Text("56% - Moderate Words Difficulty")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .monospacedDigit()
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



