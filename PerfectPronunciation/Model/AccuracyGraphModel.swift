import Foundation
import Firebase
import FirebaseAuth

class AccuracyViewModel: ObservableObject {
    @Published var selectedIndex = 0
    var totalAcc: Float = 0
    
    init(){
        self.voiceData[0].data[1].accuracy = getAvgAccuracyForMonday()
    }
    
    private var voiceData = [
        Voice(
            name: "Accuracy",
            data: [
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -7, to: Date())!, weekday: "Sun", accuracy: 75),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, weekday: "Mon", accuracy: 67),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, weekday: "Tue", accuracy: 15),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, weekday: "Wed", accuracy: 64),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, weekday: "Thu", accuracy: 83),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, weekday: "Fri", accuracy: 53),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, weekday: "Sat", accuracy: 44)
            ]),
    ]
    
    func getAvgAccuracyForMonday() -> Float{
        
         var averageAccuracy: Float = 76
        
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let userDocRef = Firestore.firestore().collection("UserData").document(userID)
            let itemsCollectionRef = userDocRef.collection("Items") // Subcollection for items
            
            // Create a query to filter documents where "dayofweek" is "Mon"
            let mondayQuery = itemsCollectionRef.whereField("DayOfWeek", isEqualTo: "Mon")
            
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
                    
                         averageAccuracy = totalAccuracy / documentCount
                        print("\(averageAccuracy)")
                }
                
            }
        }
        
        
        return averageAccuracy
    }

    
    
    var word: Voice {
        return voiceData[selectedIndex]
    }
    
    var accuracyRange = 0...100
    
    
}
