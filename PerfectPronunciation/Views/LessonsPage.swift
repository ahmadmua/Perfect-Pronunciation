//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct LessonsPage: View {
    //controllers
    @ObservedObject var model = LessonController()
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var achieveModel = AchievementController()
    //navigation to other pages
    @State private var showLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    @State private var selection: Int? = nil
    //lesson nav
    @State private var phonetics = false
    @State private var food1 = false
    @State private var food2 = false
    @State private var conversation = false
    @State private var numbers = false
    @State private var direction = false
    //lesson name
    @State private var lessonName = ""
    //currency alert
    @Binding var showingAlert : Bool
    
    
    var body: some View {
        ScrollView{
            Grid{
                VStack{
                    GridRow{
                        Text("Conversation")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        
                        Button(action: {
                            //go to lesson
                            print("conversation btn press")
                            self.lessonName = "Conversation"
                            self.food1.toggle()
                        }){
                            Image(systemName: "rectangle.3.group.bubble.left.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $conversation){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                    }//grid row 2 conversation
                    .padding()
                }//Vstack
                
                VStack{//Numbers
                    GridRow{
                        Text("Numbers")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        
                        
                        Button(action: {
                            //go to lesson
                            print("numbers btn press")
    
                            self.lessonName = "Numbers"
                            self.numbers.toggle()
                        }){
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $numbers){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row 2 numbers
                    .padding()
                }//num vstack
                
                VStack{//food
                    GridRow{
                        Text("Food")
                    }//grid row 3
                }//vstack
                
                Divider()
                
                GridRow{
                    Button(action: {
                        //go to lesson
                        print("food1 btn press")

                        self.lessonName = "Food1"
                        self.food1.toggle()
                    }){
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food1){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        //go to lesson
                        print("food2 btn press")

                        self.lessonName = "Food2"
                        self.food2.toggle()
                    }){
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food2){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                }//grid row food
                .padding()
                
                
                VStack{//Directions
                    GridRow{
                        Text("Directions")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        
                        Button(action: {
                            //go to lesson
                            print("directions btn press")
    
                            self.lessonName = "Directions"
                            self.direction.toggle()
                        }){
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $direction){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row directions
                    .padding()
                }//Directions vstack
                
            }//grid
            .background(Color("Background"))
            .padding(.vertical, 30)
            .padding(.horizontal, -20)
                
        }//list

        .background(Color("Background"))
        .scrollContentBackground(.hidden)
        
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        

//        nav bar
        ZStack{
            Rectangle()
                .fill(Color("Background"))
                .shadow(color: .gray, radius: 3, x: -2, y: 2)
                .frame(maxWidth: .infinity, maxHeight: 50)
            
        HStack {
            
            Spacer()
            
            Button(action: {
                print("buttpress")
            }) {
                Image(systemName: "book.fill")
                    .imageScale(.large) // Adjust icon size
                    .foregroundStyle(Color("CustYell"))
            }//btn
            
            Spacer()
            
            Button(action: {
                //nav to page
                self.showWeekly.toggle()
            }) {
                Image(systemName: "gamecontroller.fill")
                    .imageScale(.large) // Adjust icon size
                    .foregroundStyle(Color.gray)
            }//btn
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
                        //nav to page
                        self.showHome.toggle()
                    }) {
                        Image(systemName: "house.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color("Background"))
                    }//btn
                    .navigationDestination(isPresented: $showHome){
                        Homepage()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                
                
                Spacer()
                
                Button(action: {
                    //nav to page
                    self.showStore.toggle()
                }) {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large) // Adjust icon size
                        .foregroundStyle(Color.gray)
                }//btn
                .navigationDestination(isPresented: $showStore){
                    StorePage()
                        .navigationBarBackButtonHidden(true)
                }
                
                Spacer()
                
                Button(action: {
                    //nav to page
                    self.showAchievement.toggle()
                }) {
                    Image(systemName: "trophy.fill")
                        .imageScale(.large) // Adjust icon size
                        .foregroundStyle(Color.gray)
                }//btn
                .navigationDestination(isPresented: $showAchievement){
                    AchievementPage()
                        .navigationBarBackButtonHidden(true)
                }
                
                Spacer()
            }//group
           
        }//hstack
        .background(Color("Background"))
    }//zstack
        .background(Color("Background"))
        .onAppear(){
            if(achieveModel.achievementOneCompletion()){
                achieveModel.updateUserAchievement(userAchievement: "Achievement 1")
            }
        }

//        .alert("Congrats, You just earned currency!", isPresented: $showingAlert) {
//            Button("OK", role: .cancel) {
//                currModel.updateUserCurrency()
//            }
//                }//alert
            

    }//body view
        
        
}//view

//#Preview {
//    LessonsPage()
//}
