import Foundation
import Firebase
import FirebaseAuth


class AccuracyViewModel: ObservableObject {
    
    @Published var selectedIndex = 0
    //var totalAcc: Float = 0

    init() {
        
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Sun") { [weak self] averageAccuracy in
            self?.voiceData[0].data[0].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Mon") { [weak self] averageAccuracy in
            self?.voiceData[0].data[1].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Tue") { [weak self] averageAccuracy in
            self?.voiceData[0].data[2].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Wed") { [weak self] averageAccuracy in
            self?.voiceData[0].data[3].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Thu") { [weak self] averageAccuracy in
            self?.voiceData[0].data[4].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Fri") { [weak self] averageAccuracy in
            self?.voiceData[0].data[5].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Sat") { [weak self] averageAccuracy in
            self?.voiceData[0].data[6].accuracy = averageAccuracy
            self?.objectWillChange.send()
        }

        
    }

    var voiceData = [
        Voice(
            name: "Accuracy",
            data: [
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -7, to: Date())!, weekday: "Sun", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, weekday: "Mon", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, weekday: "Tue", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, weekday: "Wed", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, weekday: "Thu", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, weekday: "Fri", accuracy: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, weekday: "Sat", accuracy: 0)
            ]),
    ]


    var word: Voice {
        return voiceData[selectedIndex]
    }

    var accuracyRange = 0...100
}
