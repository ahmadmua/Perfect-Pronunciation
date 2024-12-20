//
//  WeeklyGamePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct WeeklyGamePage: View {
    //controller vars
    @ObservedObject var leaderboardModel = LeaderboardController()
    
    @EnvironmentObject var fireDBHelper: DataHelper
    //navigation vars
    @State private var showLesson = false
    @State private var showIndiLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    @State private var showHardWords = false
   // @ObservedObject var voiceRecorderController = VoiceRecorderController()
    
    @State private var showWeeklyLesson = false
    
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                //explain the game
                Text("In this time attack mode compete against everyone to achieve the most correctly pronounced words in 15 seconds! Dont forget to press record, and say all words in the same recording!")
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                
                Button("Start Challenge"){
                    //navigate to the game
                    self.showWeeklyLesson = true
                }
                .padding()
                .background(Color.green)
                .foregroundStyle(Color.white)
                .clipShape(Capsule())
                .navigationDestination(isPresented: $showWeeklyLesson){
                    //TEST
                    WeeklyLesson(
                        audioPlayer: AudioPlayBackController(),
//                        audioAnalysisData: AudioAPIController(),
                        voiceRecorderController: VoiceRecorderController.shared
                    )
                    .navigationBarBackButtonHidden(true)

                }
                
                
                Divider()
                
                Text("Click to explore your hard to pronounce words!")
                    .onTapGesture {
                        self.showHardWords = true
                    }
                    .sheet(isPresented: $showHardWords) {
                        HardWordsView()
                    }
                
                                
            }//vstack
            
        }//scroll view
        .navigationTitle("Weekly Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        
        VStack{
            Spacer()
            
            HStack{
                Spacer()
                
                Button(action: {
                    //ensure most recent challenge results are pulled
                    fireDBHelper.getWeeklyAccuracy { accuracy in
                        if let accuracy = accuracy {
                            print("THIS IS THE weeklygamepage refresh ACCURACY: \(accuracy)")
                            DataHelper().updateWeeklyCompletion(score: accuracy)
                        }
                        
                        //refresh for updatign the leaderboard
                        leaderboardModel.getLeaderboard()
                    }
                    
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.medium) // Adjust icon
                }
                .padding(.trailing, 25)
                .padding(.top, 25)
                
            }
            
            //list displaying the leaderboard
            List(leaderboardModel.leaderboardFull){content in
                Text("\(leaderboardModel.getFlagForCountry(fullCountryName: content.country)) \(content.userName) \n \(String(format: "%.0f", content.weeklyChallengeComplete))%")
                
                
            }//list
        }//vstack
        .padding(.top, -100)
        
        ZStack{
            Rectangle()
                .fill(Color("Background"))
                .shadow(color: .gray, radius: 3, x: -2, y: 2)
                .frame(maxWidth: .infinity, maxHeight: 50)
            
            HStack {
                
                
                Spacer()
                
                Button(action: {
                    self.showLesson.toggle()
                    
                }) {
                    Image(systemName: "book.fill")
                        .imageScale(.large) // Adjust icon size
                        .foregroundStyle(Color.gray)
                }
                .navigationDestination(isPresented: $showLesson){
                    LessonsPage()
                        .navigationBarBackButtonHidden(true)
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "gamecontroller.fill")
                        .imageScale(.large) // Adjust icon size
                    
                        .foregroundStyle(Color("CustYell"))
                }
                
                Spacer()
                
                Group {
                    
                    ZStack{
                        Circle()
                            .fill(Color("WhiteDiff"))
                            .frame(width: 50, height: 50)
                        Button(action: {
                            
                            self.showHome.toggle()
                        }) {
                            Image(systemName: "house.fill")
                                .imageScale(.large) // Adjust icon size
                                .foregroundStyle(Color("Background"))
                        }
                        .navigationDestination(isPresented: $showHome){
                            Homepage()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                        self.showStore.toggle()
                    }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color.gray)
                    }
                    .navigationDestination(isPresented: $showStore){
                        StorePage()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                        self.showAchievement.toggle()
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color.gray)
                    }
                    .navigationDestination(isPresented: $showAchievement){
                        AchievementPage()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    Spacer()
                    
                }
                
            }//vstack
            .background(Color("Background"))
        }//zstack
        .onAppear{
            fireDBHelper.getWeeklyAccuracy { accuracy in
                if let accuracy = accuracy {
                    print("THIS IS THE weeklygamepage on appear ACCURACY: \(accuracy)")
                    DataHelper().updateWeeklyCompletion(score: accuracy)
                }
                
                //refresh for updatign the leaderboard
                leaderboardModel.getLeaderboard()
            }
        }
        
        .background(Color("Background"))
    }//body view
    
    
    
    
    init(){
        //initial popoulation of the leaderboard
        leaderboardModel.getLeaderboard()
        
    }//init
}//view


//#Preview {
//    WeeklyGamePage()
//}
