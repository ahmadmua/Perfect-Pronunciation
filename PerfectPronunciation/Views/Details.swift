import SwiftUI
import CoreML
import Firebase
import FirebaseAuth


struct Day {
    let name: String
    var items: [String]
}

class SharedData: ObservableObject {
    @Published var selectedDay: String = "Mo"
}


struct Details: View {
    
    let model = PronunciationModel()
    @ObservedObject var modelLesson = LessonController()
    
    @State private var prediction: Double?
    @State private var averageAccuracy: Double = 0
    @State private var totalWords: Int = 0
    @State private var userDifficulty: String = ""
    @State private var expectedDifficulty: String = ""
    @State private var selection: Int? = nil
    @State private var userData = UserData()
    @ObservedObject var currModel = CurrencyController()
    @State private var feedbackMsg : [String] = ["Your Pronunciation is Great", "Your Pronunciation Needs Improvement"]
    @State private var difficulty : [String] = ["Beginner", "Intermediate", "Advanced"]
    
    
    @State var showingAlert2 = false
    
    
    
    
    @State private var msg = ""
    
    @State private var arr = [0.0, 0.0, 0.0, 0.0, 0.0]
    
    @State private var showHome = false
    
    
    private var pronunciationModel: PronunciationModelProjection {
        do {
            return try PronunciationModelProjection(configuration: MLModelConfiguration())
        } catch {
            fatalError("Failed to load CoreML model: \(error)")
        }
    }
    
    
    @State private var selectedDay: String = "Mo"
    @State private var str: String = ""
    
    @EnvironmentObject var fireDBHelper: DataHelper
    
    var body: some View {
            VStack {
                // Navigation and Title
                HStack {
                    Button(action: {
                        self.showHome.toggle()
                    }) {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow)
                    }
                    .navigationDestination(isPresented: $showHome) {
                        Homepage()
                    }
                    .navigationBarBackButtonHidden(true)
                    
                    Text("Detailed Stats")
                        .fontWeight(.bold)
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                        .underline()
                }
                
                // Statistics Cards
                HStack {
                    StatCard(color: .yellow, title: "Words Pronounced", value: "\(totalWords)")
                    StatCard(color: .yellow, title: "AVG Accuracy", value: "\(String(format: "%.1f", averageAccuracy))%")
                }
                
                HStack {
                    StatCard(color: .yellow, title: "Predicted Accuracy", value: "\(prediction ?? 0.0)%")
                }
                .onReceive([arr[0], arr[1], arr[2], arr[3], arr[4]].publisher) { _ in
                    prediction = makePrediction()
                }
                
                // Calendar and Items List
                CalendarView()
                ItemsListView()
                
                HStack {
                    Text("Dynamically Adjusted Difficulty:")
                        .bold()
                    
//                    Image(systemName: "arrow.clockwise")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                        .foregroundColor(.blue)
//                        .onTapGesture {
//                            updatedAdjustedDifficulty()
//                        }
//                        .padding(.leading)
                    
                }

                Text("Current Difficulty: \(userDifficulty)")
                    .onAppear {
                        fireDBHelper.findUserDifficulty { difficulty in
                            if let difficulty = difficulty {
                                userDifficulty = difficulty
                            }
                        }
                    }

              
                
                    Text("Adjusted Difficulty: \(expectedDifficulty)")
                        .onAppear {
                            updatedAdjustedDifficulty()
                        }


            

            
//            Button(action: {
//                fireDBHelper.updateDifficulty(selectedDifficulty: expectedDifficulty, userData: &userData, selection: &selection)
//                showingAlert2 = true
//                //fireDBHelper.addItemToUserDataCollection(itemName: "TestWord", dayOfWeek: "Thu", accuracy: 98.42)
//            }) {
//                Text("Reset Difficulty")
//                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
//                    .frame(height: 56, alignment: .leading)
//                    .frame(width: 200)
//                    .background(Color.yellow)
//                    .cornerRadius(10)
//            }
//            .alert(self.msg, isPresented: $showingAlert2) {
//                Button("OK", role: .cancel) {
//                }
//            }
        }

        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            fireDBHelper.getAvgAccuracy { fetchedAccuracy in
                averageAccuracy = fetchedAccuracy
            }
            fireDBHelper.getPronunciationWordCount { fetchedCount in
                totalWords = fetchedCount
            }
            
            //for prediction model
            for index in 0..<5 {
                fireDBHelper.getAccuracy(atIndex: index) { accuracy in
                    if let accuracy = accuracy {
                        arr[index] = Double(accuracy)
                    }
                }
            }
            
            prediction = makePrediction()
            
            
        }
        
        Spacer()
        
    }
    
    func updatedAdjustedDifficulty(){
        
        fireDBHelper.findUserDifficulty { difficulty in
            guard let difficulty = difficulty else { return }
            userDifficulty = difficulty

            // Determine expected difficulty based on user difficulty and accuracy output
            switch (userDifficulty, calculateAccuracyOutput()) {
            case (self.difficulty[0], feedbackMsg[0]): // Beginner | Great
                expectedDifficulty = self.difficulty[1] // Move to Intermediate

            case (self.difficulty[0], feedbackMsg[1]): // Beginner | Needs Improvement
                expectedDifficulty = self.difficulty[0] // Remain Beginner

            case (self.difficulty[1], feedbackMsg[0]): // Intermediate | Great
                expectedDifficulty = self.difficulty[2] // Move to Advanced

            case (self.difficulty[1], feedbackMsg[1]): // Intermediate | Needs Improvement
                expectedDifficulty = self.difficulty[0] // Move to Beginner

            case (self.difficulty[2], feedbackMsg[0]): // Advanced | Great
                expectedDifficulty = self.difficulty[2] // Remain Advanced

            case (self.difficulty[2], feedbackMsg[1]): // Advanced | Needs Improvement
                expectedDifficulty = self.difficulty[1] // Move to Intermediate

            default:
                break
            }
            
            // Update difficulty in FireDB
            fireDBHelper.updateDifficulty(
                selectedDifficulty: expectedDifficulty,
                userData: &userData,
                selection: &selection
            )
        }
    }
    
    func calculateAccuracyOutput() -> String {
        let input = PronunciationModelInput(Feature1: 2, Feature2: 2, Feature3: 2, Feature4: 2, Feature5: 3)
        
        do {
            let prediction = try model.prediction(input: input)
            let outputClass = prediction.OutputClass
            
            if outputClass == 1 {
                return feedbackMsg[0]
            } else {
                return feedbackMsg[1]
            }
        } catch {
            print("Error making prediction: \(error)")
        }
        
        return "No result found"
    }
    
    func makePrediction() -> Double {
        
        if(averageAccuracy == 0.0){
            prediction = 0.0
        }
        
        else if(averageAccuracy == 100.0){
            prediction = 100.0
        }
        
        else {
            
            do {
                let input = PronunciationModelProjectionInput(Feature1: arr[0], Feature2: arr[1], Feature3: arr[2], Feature4: arr[3], Feature5: arr[4])
                
                let prediction = try pronunciationModel.prediction(input: input)
                self.prediction = prediction.Target
                
                if let roundedPrediction = self.prediction {
                    return Double(roundedPrediction * 100).rounded() / 100
                }
            } catch {
                print("Error making prediction: \(error)")
                self.prediction = nil
            }
        }
        // Default value in case of an error or nil prediction
        return 0.0
    }
}







struct ItemsListView: View {
    @State private var items: [String] = []
    @EnvironmentObject private var sharedData: SharedData
    @EnvironmentObject var fireDBHelper: DataHelper
    @State private var accuracyScores: [Double] = []
    @State private var completenessScores: [Double] = []
    @State private var fluencyScores: [Double] = []
    @State private var confidence: [Double] = []
    @State private var pronScores: [Double] = []
    @State private var display: [String] = []
    @State private var errorTypeCountsList: [[String: Int]] = [] // List of errorTypeCount dictionaries
    @State private var wordErrorDataList: [[(word: String, errorType: String)]] = [] // List of error data for each assessment

    var body: some View {
        NavigationView {
            List(items.indices, id: \.self) { index in
                NavigationLink(
                    destination:
                        AssessmentView(
                            accuracyScore: accuracyScores.indices.contains(index) ? accuracyScores[index] : 0.0,
                            completenessScore: completenessScores.indices.contains(index) ? completenessScores[index] : 0.0,
                            fluencyScore: fluencyScores.indices.contains(index) ? fluencyScores[index] : 0.0,
                            confidence: confidence.indices.contains(index) ? confidence[index] : 0.0,
                            pronScores: pronScores.indices.contains(index) ? pronScores[index] : 0.0,
                            display: display.indices.contains(index) ? display[index] : "",
                            errorTypeCounts: errorTypeCountsList.indices.contains(index) ? errorTypeCountsList[index] : [:],
                            wordErrorData: wordErrorDataList.indices.contains(index) ? wordErrorDataList[index] : [] // Pass the specific error data for this assessment
                        )
                ) {
                    Text(items[index])
                }
            }
            .onAppear {
                fetchItemsForSelectedDay()
            }
            .onChange(of: sharedData.selectedDay) { _ in
                fetchItemsForSelectedDay()
            }
        }
    }

    private func fetchItemsForSelectedDay() {
        let day = mapDayOfWeek(from: sharedData.selectedDay)
        fetchItemsForDayOfWeek(day: day)
    }

    private func mapDayOfWeek(from abbreviation: String) -> String {
        switch abbreviation {
        case "Mo": return "Mon"
        case "Tu": return "Tue"
        case "We": return "Wed"
        case "Th": return "Thu"
        case "Fr": return "Fri"
        case "Sa": return "Sat"
        case "Su": return "Sun"
        default: return ""
        }
    }

    // For fetching the data
    private func fetchItemsForDayOfWeek(day: String) {
        fireDBHelper.getItemsForDayOfWeek(dayOfWeek: day) { (documents, error) in
            if let documents = documents {
                // Clear existing data arrays
                self.items.removeAll()
                self.accuracyScores.removeAll()
                self.completenessScores.removeAll()
                self.fluencyScores.removeAll()
                self.confidence.removeAll()
                self.pronScores.removeAll()
                self.display.removeAll()
                self.errorTypeCountsList.removeAll()
                self.wordErrorDataList.removeAll() // Clear data
                
                // Loop through documents
                for document in documents {
                    var errorTypeCount: [String: Int] = [:] // Dictionary to store counts of error types
                    var wordErrorData: [(word: String, errorType: String)] = [] // Temporary array for word errors
                    
                    // Check for the assessment dictionary
                    if let assessment = document.get("assessment") as? [String: Any],
                       let nBestArray = assessment["NBest"] as? [[String: Any]] {
                        
                        // Loop through each entry in the NBest array
                        for nBest in nBestArray {
                            // Process the words for this entry
                            if let words = nBest["Words"] as? [[String: Any]] {
                                for word in words {
                                    // Extract Word and ErrorType from the current word
                                    if let wordText = word["Word"] as? String,
                                       let errorType = word["ErrorType"] as? String, !errorType.isEmpty {
                                        // Increment count for the specific error type
                                        errorTypeCount[errorType, default: 0] += 1
                                        // Store the word and its associated error type
                                        wordErrorData.append((word: wordText, errorType: errorType))
                                    }
                                }
                            }
                            
                            // Extract scores from nBest entry
                            if let accuracyScore = nBest["AccuracyScore"] as? Double {
                                self.accuracyScores.append(accuracyScore)
                            }
                            if let completenessScore = nBest["CompletenessScore"] as? Double {
                                self.completenessScores.append(completenessScore)
                            }
                            if let fluencyScore = nBest["FluencyScore"] as? Double {
                                self.fluencyScores.append(fluencyScore)
                            }
                            if let confidence = nBest["Confidence"] as? Double {
                                self.confidence.append(confidence)
                            }
                            if let pronScore = nBest["PronScore"] as? Double {
                                self.items.append("Score: \(pronScore)%")
                                self.pronScores.append(pronScore)
                            }
                            if let display = nBest["Display"] as? String {
                                self.display.append(display)
                            }
                        }
                    }
                    
                    // Append the errorTypeCount and wordErrorData for this document
                    self.errorTypeCountsList.append(errorTypeCount)
                    self.wordErrorDataList.append(wordErrorData) // Store the error data for this assessment
                }
                
                // Print the contents of the wordErrorData
                print("Word Error Data: \(self.wordErrorDataList)")
                
                // Print or use the errorTypeCount dictionary as needed
                print("Error Type Counts: \(self.errorTypeCountsList)")
            } else if let error = error {
                print("Error: \(error)")
            }
        }
    }
}






struct CalendarView: View {
    
    public let daysOfWeek = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    
    @EnvironmentObject private var sharedData: SharedData
    
    var body: some View {
        
        Text("Weekly Calendar")
        
        HStack(spacing: 10) {
            ForEach(daysOfWeek, id: \.self) { day in
                Button(action: {
                    sharedData.selectedDay = day
                    print(sharedData.selectedDay)
                }) {
                    ZStack {
                        Circle()
                            .stroke(sharedData.selectedDay == day ? Color.black: Color.yellow, lineWidth: 2)
                            .frame(width: 44, height: 44)
                        Text(day)
                            .font(.title)
                            .foregroundColor(sharedData.selectedDay == day ? .yellow : .black)
                    }
                }
            }
        }
    }
}


struct StatCard: View {
    
    var color: Color
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
        .background(color)
        .cornerRadius(10)
    }
}

