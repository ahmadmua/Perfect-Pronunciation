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
    
    
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var xpModel = ExperienceController()
    @ObservedObject var model = LessonController()
    @ObservedObject var achieveModel = AchievementController()
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack{
                
                VStack(spacing: 20) {
                    Text("Hello, \(userEmail)")
                        .font(.headline)
                        .bold()
                    ZStack{
                        
                        
                        VStack(alignment: .leading) {
                            
                            
                            Grid{
                                GridRow{
                                    HStack{
                                        Button(action: {
                                            self.showLesson.toggle()
                                        }){
                                            Text("Lessons")
                                                .font(.headline)
                                                .padding()
                                                .frame(width: 185, height: 75)
                                                .background(Color("CustYell"))
                                                .foregroundStyle(Color.black)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                            
                                        }
                                        .navigationDestination(isPresented: $showLesson){
                                            LessonsPage()
                                                .navigationBarBackButtonHidden(true)
                                        }
                                        
                                        Button(action: {
                                            
                                            self.showWeekly.toggle()
                                        }){
                                            Text("Weekly")
                                                .font(.headline)
                                                .padding()
                                                .frame(width: 185, height: 75)
                                                .background(Color("CustYell"))
                                                .cornerRadius(10)
                                                .foregroundStyle(Color.black)
                                                .shadow(radius: 5)
                                            
                                        }
                                        .navigationDestination(isPresented: $showWeekly){
                                            WeeklyGamePage()
                                                .navigationBarBackButtonHidden(true)
                                        }
                                    }//hstack
                                }//grid row
                                
                                GridRow{
                                    HStack{
                                        Button(action: {
                                            
                                            self.showAchievement.toggle()
                                        }){
                                            Text("Achievments")
                                                .font(.headline)
                                                .padding()
                                                .frame(width: 185, height: 75)
                                                .background(Color("CustYell"))
                                                .cornerRadius(10)
                                                .foregroundStyle(Color.black)
                                                .shadow(radius: 5)
                                            
                                        }
                                        .navigationDestination(isPresented: $showAchievement){
                                            AchievementPage()
                                                .navigationBarBackButtonHidden(true)
                                        }
                                        
                                        Button(action: {
                                            
                                            self.showStore.toggle()
                                        }){
                                            Text("Store")
                                                .font(.headline)
                                                .padding()
                                                .frame(width: 185, height: 75)
                                                .background(Color("CustYell"))
                                                .cornerRadius(10)
                                                .foregroundStyle(Color.black)
                                                .shadow(radius: 5)
                                        }
                                        .navigationDestination(isPresented: $showStore){
                                            StorePage()
                                                .navigationBarBackButtonHidden(true)
                                        }
                                    }
                                }
                            }//grid
                            
                        }
                    }
                    
                    
                    
                    VStack(alignment: .leading){
                        
                        Text("Goals / Stats")
                            .font(.largeTitle)
                            .bold()
                        
                        ZStack{
                            
                            VStack(alignment: .leading) {
                                
                                
                                HStack(spacing: 20) {
                                    
                                    
                                    
                                    Button(action: {
                                        self.showStats.toggle()
                                    }){
                                        
                                        
                                        BarChart(
                                            data: viewModel.word.data,
                                            range: viewModel.accuracyRange
                                        )
                                        
                                    }
                                    .navigationDestination(isPresented: $showStats){
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
                                        HStack(spacing: 20){
                    HStack{
                        
                        Image(systemName: "trophy.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                        //get the current user currency
                        Text("\(xpModel.userLevel)")
                            .foregroundColor(.black)
                        
                        
                        Image(systemName: "music.mic.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                        //get the current user currency
                        Text("\(currModel.userCurr)")
                            .foregroundColor(.black)
                        
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.yellow))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2))
                    
                    
                    Button(action: {
                        
                        self.showLeague.toggle()
                    }){
                        
                        Image(systemName: "hexagon.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                    }
                    .navigationDestination(isPresented: $showLeague){
                        LeagueLeaderboard()
                    }//league
                    
                    Button(action: {
                        
                        self.showSettings.toggle()
                    }){
                        
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .background(Circle().fill(Color.yellow))
                    }
                    .navigationDestination(isPresented: $showSettings){
                        Settings()
                    }
                    
                    
                }//hstack
                                    
                )// nav bar items
                
                Spacer()
            }
        }
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.objectWillChange.send()
            
            if let user = Auth.auth().currentUser {
                if let email = user.email {
                    userEmail = email.components(separatedBy: "@").first ?? ""
                } else {
                }
            }
            
            xpModel.getUserExperience()
            xpModel.getUserLevel()
            
            //TODO: on first launch / login the user currency does not update only when going back to the homepage does it update
            //get the users current currency total
            model.findUserDifficulty{
                //get the users current currency
                currModel.getUserCurrency()
            }
            
            achieveModel.achievementOneCompletion { allCompleted in
                if allCompleted {
                    print("ALL ACHIEVEMENTS COMPLETED")
                    achieveModel.updateUserAchievement(userAchievement: "Achievement 1")
                }
            }
            
        }
        
        Spacer()
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
