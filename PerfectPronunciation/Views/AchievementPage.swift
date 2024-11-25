//
//  AchievementPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct AchievementPage: View {
    //navigation vars
    @State private var selection: Int? = nil
    @State private var showLesson = false
    @State private var showIndiLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    //controller var
    @ObservedObject var achieveModel = AchievementController()
    
    
    var body: some View {
        
        
        List{
            Grid{
                VStack{
                    GridRow{
                        HStack{
                            Button(action: {
                                print("basic1 btn press")

                            }){
                                Image(systemName: "square.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn
                            .buttonStyle(.borderless)
                            .disabled(achieveModel.achievement1)
                            VStack{
                                Text("Completion")
                                    .padding(.horizontal, 20)
                                Text("Complete all the lessons")
                                    .padding(.horizontal, 20)
                            }//vstack to explain the achievement
                        }//hstack
                    }
                    .padding()
                    GridRow{
                        HStack{
                            Button(action: {
                                print("basic2 btn press")
                                
                                //test the achievement capabilities
//                                achieveModel.updateUserAchievement(userAchievement: "Achievement 1")
                                
                            }){
                                Image(systemName: "square.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn basic2
                            .buttonStyle(.borderless)
                            .disabled(achieveModel.achievement2)
                            VStack{
                                Text("Experience")
                                    .padding(.horizontal, 20)
                                Text("Reach Level 5")
                                    .padding(.horizontal, 20)
                            }
                        }//hstack
                    }//grid row 4
                    .padding()
                    GridRow{
                        HStack{
                            Button(action: {
                                print("basic2 btn press")
                            }){
                                Image(systemName: "square.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn basic2
                            .buttonStyle(.borderless)
                            .disabled(achieveModel.achievement3)
                            VStack{
                                Text("Weekly Challenger")
                                    .padding(.horizontal, 20)
                                Text("Partake in the Weekly Challenge")
                                    .padding(.horizontal, 20)
                            }
                        }//hstack
                    }//grid row 4
                    .padding()
                    GridRow{
                        HStack{
                            Button(action: {
                                print("basic2 btn press")
                            }){
                                Image(systemName: "square.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn basic2
                            .buttonStyle(.borderless)
                            .disabled(achieveModel.achievement4)
                            VStack{
                                Text("Ultimate Learner")
                                    .padding(.horizontal, 20)
                                Text("Reach Level 10")
                                    .padding(.horizontal, 20)
                            }
                        }//hstack
                    }//grid row 4
                    .padding()
                    GridRow{
                        HStack{
                            Button(action: {
                                print("basic2 btn press")
                            }){
                                Image(systemName: "square.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn basic2
                            .buttonStyle(.borderless)
                            .disabled(achieveModel.achievement5)
                            VStack{
                                Text("Rich")
                                    .padding(.horizontal, 20)
                                Text("Have 1000 currency at one time")
                                    .padding(.horizontal, 20)
                            }//vstack
                        }//hstack
                    }//grid row 4
                    .padding()
                }//vstack
            }//grid
            .background(Color("Background"))
            .padding(.vertical, -15)
            .padding(.horizontal, -20)
            
            .onAppear(){
                //check the current users achievements and update accordingly
                achieveModel.checkUserAchievement()
            }
            
            
        }//list
        .background(Color("Background"))
        .scrollContentBackground(.hidden)
        
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        
        //navigation bar
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
                    self.showWeekly.toggle()
                }) {
                    Image(systemName: "gamecontroller.fill")
                        .imageScale(.large) // Adjust icon size
                        .foregroundStyle(Color.gray)
                }
                .navigationDestination(isPresented: $showWeekly){
                    WeeklyGamePage()
                        .navigationBarBackButtonHidden(true)
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
                        
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color("CustYell"))
                    }
                    
                    Spacer()
                    
                }//gropu
            }//hstack
            .background(Color("Background"))
        }//zstack
        .background(Color("Background"))
    }//body view
}//view


//#Preview {
//    AchievementPage()
//}
