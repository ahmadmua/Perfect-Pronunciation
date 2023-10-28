import Foundation


class AccuracyViewModel: ObservableObject {
    @Published var selectedIndex = 0
    
//    var pickerOptions = [
//        PickerOption(name: "Average Accuracy %", tag: 0),
//    ]
    
    private let voiceData = [
        Voice(
            name: "Accuracy",
            data: [
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -7, to: Date())!, weekday: "Sun", accuracy: 78.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, weekday: "Mon", accuracy: 53.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, weekday: "Tue", accuracy: 70.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, weekday: "Wed", accuracy: 60.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, weekday: "Thu", accuracy: 50.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, weekday: "Fri", accuracy: 85.00),
            .init(timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, weekday: "Sat", accuracy: 43.00)
            ]),
    ]
    
    
    var word: Voice {
        return voiceData[selectedIndex]
    }
    
    var accuracyRange = 0...100
    
    
}
