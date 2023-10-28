import SwiftUI


struct Day {
    let name: String
    var items: [String]
}

struct Details: View {
    
    @State private var selectedDay: String = "Mo"
        
        let days: [Day] = [
            Day(name: "Mo", items: ["Word 1 - 54%", "Word 2 - 76%"
                                   ,"Word 3 - 54%", "Word 2 - 76%"
                                   ,"Word 1 - 54%", "Word 2 - 76%"]),
            Day(name: "Tu", items: ["Item 3", "Item 4"]),
            Day(name: "We", items: ["Item 5"]),
            Day(name: "Th", items: ["Item 6"]),
            Day(name: "Fr", items: ["Item 7", "Item 8"]),
            Day(name: "Sa", items: []),
            Day(name: "Su", items: []),
        ]
    
    
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
            
            CalendarView(selectedDay: $selectedDay)
            

            
            ItemsListView(selectedDay: $selectedDay, days: days)
            
            Text("Needs Improvement")
                .bold()
            Text("Current Difficulty: Intermediate \n Expected Difficulty: Beginner")
            
            Button(action: {
               
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
}

struct ItemsListView: View {
    
    @Binding var selectedDay: String
    
    let days: [Day]
    
    var body: some View {
        
        let selectedDayItems = days.first { $0.name == selectedDay }?.items ?? []
        
        List(selectedDayItems, id: \.self) { item in
            Text(item)
        }
    }
}

struct CalendarView: View {
    let daysOfWeek = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    @Binding var selectedDay: String

    var body: some View {
        
        Text("Past 7 days")
        
        HStack(spacing: 10) {
            ForEach(daysOfWeek, id: \.self) { day in
                Button(action: {
                    selectedDay = day
                }) {
                    ZStack {
                        Circle()
                            .stroke(selectedDay == day ? Color.black: Color.yellow, lineWidth: 2)
                            .frame(width: 44, height: 44)
                        Text(day)
                            .font(.title)
                            .foregroundColor(selectedDay == day ? .yellow : .black)
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
