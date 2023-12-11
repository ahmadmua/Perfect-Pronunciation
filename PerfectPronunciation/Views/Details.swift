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
    @State private var averageAccuracy: Float = 0
    @State private var totalWords: Int = 0
    @State private var userDifficulty: String = ""
    @State private var expectedDifficulty: String = ""
    @State private var selection: Int? = nil
    @State private var userData = UserData()
    @ObservedObject var currModel = CurrencyController()
    
    @State var showingAlert2 = false
    @Binding var showingAlert: Bool
    
    
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
            HStack{
                Button(action: {
                self.showHome.toggle()
                }){
        
                    Image(systemName: "arrowshape.backward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.yellow)
                }
                .navigationDestination(isPresented: $showHome){
                    Homepage()
                }
                .navigationBarBackButtonHidden(true)
                
                Text("Detailed Stats")
                    .fontWeight(.bold)
                    .font(Font.system(size: 50))
                    .foregroundColor(Color.black)
                    .underline()
            }
            
            HStack {
                StatCard(color: .yellow, title: "Words Pronounced", value: "\(totalWords)")
                StatCard(color: .yellow, title: "AVG Accuracy", value: "\(averageAccuracy)%")
            }
            
            HStack {
                
                StatCard(color: .yellow, title: "Predicted Accuracy", value: "\(prediction ?? 0.0)%")
            }
            
            .onReceive([arr[0], arr[1], arr[2], arr[3], arr[4]].publisher) { _ in
                prediction = makePrediction()
            }
            
            CalendarView()
            
            ItemsListView()
            
            Text("\(calculateAccuracyOutput())")
                .bold()
            
            Text("Current Difficulty: \(userDifficulty)")
                .onAppear {
                    fireDBHelper.findUserDifficulty { difficulty in
                        if let difficulty = difficulty {
                            userDifficulty = difficulty
                        }
                    }
                }
            
            Text("Expected Difficulty: \(expectedDifficulty)")
                .onAppear {
                    fireDBHelper.findUserDifficulty { difficulty in
                        if let difficulty = difficulty {
                            userDifficulty = difficulty
                            
                            if (userDifficulty == "Intermediate") {
                                expectedDifficulty = "Advanced"
                                msg = "User Difficulty Successfully Reset!"
                            }
                            else if(userDifficulty == "Advanced"){
                                msg = "User Difficulty Successfully Reset!"
                                expectedDifficulty = "Advanced"
                            }
                        }
                    }
                    
                }
            
            Button(action: {
                fireDBHelper.updateDifficulty(selectedDifficulty: expectedDifficulty, userData: &userData, selection: &selection)
                showingAlert2 = true
                //fireDBHelper.addItemToUserDataCollection(itemName: "TestWord", dayOfWeek: "Thu", accuracy: 98.42)
            }) {
                Text("Reset Difficulty")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                    .frame(height: 56, alignment: .leading)
                    .frame(width: 200)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            .alert(self.msg, isPresented: $showingAlert2) {
                Button("OK", role: .cancel) {
                }
            }
        }
//        .navigationBarItems(leading:
//            
//            Button(action: {
//            self.showHome.toggle()
//            //get the users current currency total
////            modelLesson.findUserDifficulty{
////                //get the users current currency
////                currModel.getUserCurrency()
////            }
//            }){
//    
//                Image(systemName: "arrowshape.backward.fill")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .foregroundColor(.yellow)
//            }
//        )
//        .navigationDestination(isPresented: $showHome){
//            Homepage()
//        }
        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            fireDBHelper.getAvgAccuracy { fetchedAccuracy in
                averageAccuracy = fetchedAccuracy
            }
            fireDBHelper.getPronunciationWordCount { fetchedCount in
                totalWords = fetchedCount
            }
            
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
        
            .alert("Congrats, You just earned currency!", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    currModel.updateUserCurrency()
                }
                    }//
    }
    
    func calculateAccuracyOutput() -> String {
        let input = PronunciationModelInput(Feature1: arr[0], Feature2: arr[1], Feature3: arr[2], Feature4: arr[3], Feature5: arr[4])
        
        do {
            let prediction = try model.prediction(input: input)
            let outputClass = prediction.OutputClass
            
            if outputClass == 1 {
                return "Your Pronunciation is Great"
            } else {
                return "Your Pronunciation Needs Improvement"
            }
        } catch {
            print("Error making prediction: \(error)")
        }
        
        return "No result found"
    }
    
    func makePrediction() -> Double {
        do {
            let input = PronunciationModelProjectionInput(Feature1: arr[0], Feature2: arr[1], Feature3: arr[2], Feature4: arr[3], Feature5: arr[4])
            
            print(arr[0])
            print(arr[1])
            print(arr[2])
            print(arr[3])
            print(arr[4])
            
            let prediction = try pronunciationModel.prediction(input: input)
            self.prediction = prediction.Target
            
            if let roundedPrediction = self.prediction {
                return Double(roundedPrediction * 100).rounded() / 100
            }
        } catch {
            print("Error making prediction: \(error)")
            self.prediction = nil
        }
        
        // Default value in case of an error or nil prediction
        return 0.0
    }
}


    




struct ItemsListView: View {
    
    @State private var items: [String] = []
    @EnvironmentObject private var sharedData: SharedData
    @EnvironmentObject var fireDBHelper: DataHelper
    
    var body: some View {
        
        if(sharedData.selectedDay == "Mo"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Mon") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        else if(sharedData.selectedDay == "Tu"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Tue") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        else if(sharedData.selectedDay == "We"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Wed") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        else if(sharedData.selectedDay == "Th"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Thu") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        else if(sharedData.selectedDay == "Fr"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Fri") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        else if(sharedData.selectedDay == "Sa"){
        
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Sat") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        else if(sharedData.selectedDay == "Su"){
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                // Fetch and populate items for "Tue" when the view appears
                fireDBHelper.getItemsForDayOfWeek(dayOfWeek: "Sun") { (documents, error) in
                    if let documents = documents {
                        let items = documents.compactMap { document in
                            if let name = document.get("Name") as? String,
                               let accuracy = document.get("Accuracy") as? Float {
                                return "\(name) - Accuracy: \(accuracy)%"
                            }
                            return nil
                        }
                        self.items = items
                    } else if let error = error {
                        // Handle the error
                        print("Error: \(error)")
                    }
                }
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


