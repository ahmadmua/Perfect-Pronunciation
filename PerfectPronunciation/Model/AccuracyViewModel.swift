import Foundation
import Firebase
import FirebaseAuth


class AccuracyViewModel: ObservableObject {
    
    @Published var selectedIndex = 0
    //var totalAcc: Float = 0

    init() {
        
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Sun") { [weak self] averageAccuracy in
            self?.voiceData[0].data[0].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Mon") { [weak self] averageAccuracy in
            self?.voiceData[0].data[1].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Tue") { [weak self] averageAccuracy in
            self?.voiceData[0].data[2].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Wed") { [weak self] averageAccuracy in
            self?.voiceData[0].data[3].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Thu") { [weak self] averageAccuracy in
            self?.voiceData[0].data[4].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Fri") { [weak self] averageAccuracy in
            self?.voiceData[0].data[5].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }
        
        DataHelper().getAvgAccuracyForDayOfWeek(weekDay: "Sat") { [weak self] averageAccuracy in
            self?.voiceData[0].data[6].AccuracyScore = averageAccuracy
            self?.objectWillChange.send()
        }

        
    }

    var voiceData = [
        Voice(
            name: "AccuracyScore",
            data: [
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -7, to: Date())!, weekday: "Sun", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, weekday: "Mon", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, weekday: "Tue", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, weekday: "Wed", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, weekday: "Thu", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, weekday: "Fri", AccuracyScore: 0),
                .init(timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, weekday: "Sat", AccuracyScore: 0)
            ]),
    ]


    var word: Voice {
        return voiceData[selectedIndex]
    }

    var accuracyRange = 0...100
}
