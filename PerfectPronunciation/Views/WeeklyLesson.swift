//
//  weeklyLesson.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-12-04.
//

import SwiftUI

struct WeeklyLesson: View {
    @State private var showWeekly = false
    
    @State var timeRemaining = 15
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        Text("\(timeRemaining)")
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                        else if (timeRemaining == 0){
                            self.showWeekly = true
                        }
                    }
                    .navigationDestination(isPresented: $showWeekly){
                        WeeklyGamePage()
                            .navigationBarBackButtonHidden(true)
                    }
    }
}

#Preview {
    weeklyLesson()
}
