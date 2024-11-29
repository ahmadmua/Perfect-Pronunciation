//
//  Homepage.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Homepage: View {
    @State private var userEmail: String = ""
    @StateObject private var viewModel = AccuracyViewModel()
    
    @State private var showLesson = false
    @State private var showStats = false
    @State private var showSettings = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    @State private var showLeague = false
    
    @State private var showToast = false // State for showing the toast
    @State private var toastMessage = "" // Message to display in the toast
    
    // timer to wait for firebase
    @State var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var xpModel = ExperienceController()
    @ObservedObject var model = LessonController()
    @ObservedObject var achieveModel = AchievementController()
    @ObservedObject var toastModel = ToastController()
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    VStack(spacing: 20) {
                        Text("Hello, \(userEmail)")
                            .font(.headline)
                            .bold()
                        ZStack {
                            VStack(alignment: .leading) {
                                Grid {
                                    GridRow {
                                        HStack {
                                            Button(action: {
                                                self.showLesson.toggle()
                                            }) {
                                                Text("Lessons")
                                                    .font(.headline)
                                                    .padding()
                                                    .frame(width: 185, height: 75)
                                                    .background(Color("CustYell"))
                                                    .foregroundStyle(Color.black)
                                                    .cornerRadius(10)
                                                    .shadow(radius: 5)
                                            }
                                            .navigationDestination(isPresented: $showLesson) {
                                                LessonsPage()
                                                    .navigationBarBackButtonHidden(true)
                                            }
                                            
                                            Button(action: {
                                                self.showWeekly.toggle()
                                            }) {
                                                Text("Weekly")
                                                    .font(.headline)
                                                    .padding()
                                                    .frame(width: 185, height: 75)
                                                    .background(Color("CustYell"))
                                                    .cornerRadius(10)
                                                    .foregroundStyle(Color.black)
                                                    .shadow(radius: 5)
                                            }
                                            .navigationDestination(isPresented: $showWeekly) {
                                                WeeklyGamePage()
                                                    .navigationBarBackButtonHidden(true)
                                            }
                                        }
                                    }
                                    
                                    GridRow {
                                        HStack {
                                            Button(action: {
                                                self.showAchievement.toggle()
                                            }) {
                                                Text("Achievements")
                                                    .font(.headline)
                                                    .padding()
                                                    .frame(width: 185, height: 75)
                                                    .background(Color("CustYell"))
                                                    .cornerRadius(10)
                                                    .foregroundStyle(Color.black)
                                                    .shadow(radius: 5)
                                            }
                                            .navigationDestination(isPresented: $showAchievement) {
                                                AchievementPage()
                                                    .navigationBarBackButtonHidden(true)
                                            }
                                            
                                            Button(action: {
                                                self.showStore.toggle()
                                            }) {
                                                Text("Store")
                                                    .font(.headline)
                                                    .padding()
                                                    .frame(width: 185, height: 75)
                                                    .background(Color("CustYell"))
                                                    .cornerRadius(10)
                                                    .foregroundStyle(Color.black)
                                                    .shadow(radius: 5)
                                            }
                                            .navigationDestination(isPresented: $showStore) {
                                                StorePage()
                                                    .navigationBarBackButtonHidden(true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Goals / Stats")
                                .font(.largeTitle)
                                .bold()
                            
                            ZStack {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            self.showStats.toggle()
                                        }) {
                                            BarChart(
                                                data: viewModel.word.data,
                                                range: viewModel.accuracyRange
                                            )
                                        }
                                        .navigationDestination(isPresented: $showStats) {
                                            StatData()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .navigationBarItems(leading:
                                            Image("Alpaca")
                        .resizable()
                        .padding(4)
                        .frame(width: 45, height: 40)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.yellow))
                        .overlay(Circle().stroke(Color.black, lineWidth: 2)),
                                        trailing:
                                            HStack(spacing: 20) {
                        HStack {
                            Image(systemName: "trophy.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.black)
                            Text("\(xpModel.userLevel)")
                                .foregroundColor(.black)
                                .onReceive(timer) { _ in
                                    if timeRemaining > 0 {
                                        timeRemaining -= 1
                                    }
                                    if timeRemaining == 1 {
                                        currModel.getUserCurrency()
                                        xpModel.getUserExperience()
                                        xpModel.getUserLevel()
                                    }
                                }//onReceive
                            
                            Image(systemName: "music.mic.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.black)
                            Text("\(currModel.userCurr)")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.yellow))
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2))
                        
                        Button(action: {
                            self.showLeague.toggle()
                        }) {
                            Image(systemName: "hexagon.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.yellow)
                        }
                        .navigationDestination(isPresented: $showLeague) {
                            LeagueLeaderboard()
                        }
                        
                        Button(action: {
                            self.showSettings.toggle()
                        }) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .background(Circle().fill(Color.yellow))
                        }
                        .navigationDestination(isPresented: $showSettings) {
                            Settings()
                        }
                    })
                }
            }
            .background(Color("Background"))
            .navigationBarBackButtonHidden(true)
            .onAppear {
                
                viewModel.objectWillChange.send()
                
                if let user = Auth.auth().currentUser {
                    if let email = user.email {
                        userEmail = email.components(separatedBy: "@").first ?? ""
                    }
                }
                
                xpModel.getUserExperience()
                xpModel.getUserLevel()
                
                model.findUserDifficulty {
                    currModel.getUserCurrency()
                }
                
                // Check Achievement 1
                achieveModel.checkAchievementCompletion(userAchievement: "Achievement 1") { achievementChecked in
                    if !achievementChecked {
                        achieveModel.achievementOneCompletion { allCompleted in
                            if allCompleted {
                                toastModel.showToast(message: "All Lessons Completed Achievement Unlocked!")
                                achieveModel.updateUserAchievement(userAchievement: "Achievement 1")
                                achieveModel.UpdateAchievementCompletionCheck(userAchievement: "Achievement 1")
                            }
                        }
                    }
                }

                // Check Achievement 2
                achieveModel.checkAchievementCompletion(userAchievement: "Achievement 2") { achievementChecked in
                    if !achievementChecked {
                        achieveModel.achievementLevelCompletion { allCompleted in
                            if allCompleted {
                                toastModel.showToast(message: "Level 5 Achievement Unlocked!")
                                achieveModel.updateUserAchievement(userAchievement: "Achievement 2")
                                achieveModel.UpdateAchievementCompletionCheck(userAchievement: "Achievement 2")
                            }
                        }
                    }
                }
                
                // Check Achievement 3
                achieveModel.checkAchievementCompletion(userAchievement: "Achievement 3") { achievementChecked in
                    if !achievementChecked {
                        achieveModel.achievementWeeklyCompletion { allCompleted in
                            if allCompleted {
                                toastModel.showToast(message: "Weekly Challenge Achievement Unlocked!")
                                achieveModel.updateUserAchievement(userAchievement: "Achievement 3")
                                achieveModel.UpdateAchievementCompletionCheck(userAchievement: "Achievement 3")
                            }
                        }
                    }
                }
                
                // Check Achievement 4
                achieveModel.checkAchievementCompletion(userAchievement: "Achievement 4") { achievementChecked in
                    if !achievementChecked {
                        achieveModel.achievementLevelTenCompletion { allCompleted in
                            if allCompleted {
                                toastModel.showToast(message: "Ultimate Learner Achievement Unlocked!")
                                achieveModel.updateUserAchievement(userAchievement: "Achievement 4")
                                achieveModel.UpdateAchievementCompletionCheck(userAchievement: "Achievement 4")
                            }
                        }
                    }
                }
                
                // Check Achievement 5
                achieveModel.checkAchievementCompletion(userAchievement: "Achievement 5") { achievementChecked in
                    if !achievementChecked {
                        achieveModel.achievementCurrencyCompletion { allCompleted in
                            if allCompleted {
                                toastModel.showToast(message: "Rich Achievement Unlocked!")
                                achieveModel.updateUserAchievement(userAchievement: "Achievement 5")
                                achieveModel.UpdateAchievementCompletionCheck(userAchievement: "Achievement 5")
                            }
                        }
                    }
                }
            }

            
            ToastView(showToast: $toastModel.showToast, message: toastModel.toastMessage)
        }
    }
    

    
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
