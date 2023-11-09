import SwiftUI
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
    
    
    func returnDate() -> String{
        dateFormatter.dateFormat = "E"
        let currentDayOfWeek = dateFormatter.string(from: Date())
        return currentDayOfWeek
    }
    
    @State private var selectedDay: String = "Mo"
    @State private var str: String = ""
    
    @EnvironmentObject var fireDBHelper: FireDBHelper
    
    let dateFormatter = DateFormatter()
    
        
//    @State var days: [Day] = [
//            Day(name: "Mo", items: []),
//            Day(name: "Tu", items: []),
//            Day(name: "We", items: []),
//            Day(name: "Th", items: []),
//            Day(name: "Fr", items: []),
//            Day(name: "Sa", items: []),
//            Day(name: "Su", items: []),
//        ]
    
    
    var body: some View {
        
        
        VStack {
            
            Text("Detailed Stats")
                .fontWeight(.bold)
                .font(Font.system(size: 50))
                .foregroundColor(Color.black)
                .underline()
    
            HStack {
                StatCard(color: .yellow, title: "Words Pronounced", value: "5")
                StatCard(color: .yellow, title: "AVG Accuracy", value: "74%")
            }
            HStack {
                StatCard(color: .yellow, title: "Predicted Accuracy", value: "67%")
                StatCard(color: .yellow, title: "Longest Streak", value: "12")
            }
            
            CalendarView()
            
            ItemsListView()
            
            
            Text("\(calculateAccuracyOutput())")
                .bold()
            Text("Current Difficulty: Intermediate \n Expected Difficulty: Beginner")
            
            Button(action: {
                
                getAvgAccuracy(dayOfWeek: "Mon")
                
//                dateFormatter.dateFormat = "E"
//                let currentDayOfWeek = dateFormatter.string(from: Date())
//
               //fireDBHelper.addItemToUserDataCollection(itemName: "Word15", dayOfWeek: "Tue", accuracy: 75)
                
//                getItemsForDayOfWeek(dayOfWeek: "Tue") { (documents, error) in
//                    if let documents = documents {
//                        for document in documents {
//                            if let word = document.get("Name") as? String,
//                               let accuracy = document.get("Accuracy") as? String {
//                                print("\(word) - \(accuracy)%")
//                            }
//                        }
//                    } else if let error = error {
//                        // Handle the error
//                        print("Error: \(error)")
//                    }
//                }
                
//                print(returnDate())
//
            }){
                Text("Reset Difficulty")
                    .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                    .frame(height: 56, alignment: .leading)
                    .frame(width: 200)
                    .background(Color.yellow)
                    .cornerRadius(10)
                
            }
          
        }
        
        Spacer()
        
    }
    
    func getAvgAccuracy(dayOfWeek: String) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
            
            // Create a query to filter documents where "dayofweek" is "Mon"
            let mondayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: dayOfWeek)
            
            mondayQuery.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    var totalAccuracy: Float = 0
                    var documentCount: Float = 0
                    
                    for document in querySnapshot!.documents {
                        if let accuracy = document["Accuracy"] as? Float {
                            totalAccuracy += accuracy
                            documentCount += 1
                        } else {
                            print("Document \(document.documentID) exists for Monday, but 'accuracy' field is missing or not a float.")
                        }
                    }
                    
                    if documentCount > 0 {
                        let averageAccuracy = totalAccuracy / documentCount
                        let formattedAverage = String(format: "%.2f", averageAccuracy)
                        print("Average Accuracy for Monday: \(formattedAverage)")
                    } else {
                        print("No documents with 'accuracy' values found for Monday.")
                    }
                }
            }
        }
    }
    
    
    func getItemsForDayOfWeek(dayOfWeek: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
            
            // Perform a query to filter documents with "DayOfWeek" equal to "Tue"
            itemsCollectionRef.whereField("DayOfWeek", isEqualTo: dayOfWeek).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching items for \(dayOfWeek): \(error)")
                    completion(nil, error)
                } else {
                    if let documents = querySnapshot?.documents {
                        print("Items for \(dayOfWeek) retrieved successfully")
                        completion(documents, nil)
                    }
                }
            }
        } else {
            // Handle the case where the user is not authenticated
            let error = NSError(domain: "Authentication Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])
            completion(nil, error)
        }
    }
    
    //uses the pronunciation model to predict
    func calculateAccuracyOutput() -> String{
        
        let input = PronunciationModelInput(Feature1: 75, Feature2: 80, Feature3: 95, Feature4: 80, Feature5: 90)
        
        do {
            let prediction = try model.prediction(input: input)
            let outputClass = prediction.OutputClass
            
            if(outputClass == 1){
                return "Your Pronunciation is Great"
            }
            else {
               return "Your Pronunciation Needs Improvement"
            }
            
            //print("Predicted Output Class: \(str)")
        } catch {
            print("Error making prediction: \(error)")
        }
        
        return "No result found"
    }
    



    
}



struct ItemsListView: View {
    
    @State private var items: [String] = []
    @EnvironmentObject private var sharedData: SharedData
    @EnvironmentObject var fireDBHelper: FireDBHelper
    
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
        
        Text("Past 7 days")
        
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

struct Details_Previews: PreviewProvider {
    static var previews: some View {
        Details()
    }
}
