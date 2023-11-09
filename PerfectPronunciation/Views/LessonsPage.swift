//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct LessonsPage: View {
//    @State private var msg = ""
    @State private var showLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    @State private var selection: Int? = nil
    
    @State private var phonetics = false
    @State private var food1 = false
    
    @State var showingPopup = false
    
    @State private var lessonName = ""
    
    
    var body: some View {
        //        NavigationStack{
        
//        NavigationLink(destination: IndividualLesson(lessonName: $lessonName), tag: 1, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}.navigationBarBackButtonHidden(true)
        List{
            Grid{
                VStack{
                    GridRow{
                        Text("Phonetics")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        Button(action: {
                            print("phonetic btn press")
//                            self.selection = 1
                            lessonName = "Phonetics"
                            self.phonetics.toggle()
                        }){
                            Image(systemName: "mouth.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $phonetics){
                            IndividualLesson(lessonName: $lessonName)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row 2
                    .padding()
                }//Vstack
                
                VStack{
                    GridRow{
                        Text("Basics")
                    }//grid row 3
                }//vstack
                
                Divider()
                
                GridRow{
                    Button(action: {
                        print("basic1 btn press")
                        self.selection = 1
                    }){
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        print("basic2 btn press")
                        self.selection = 1
                    }){
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn basic2
                    .buttonStyle(.borderless)
                }//grid row 4
                .padding()
                
                VStack{
                    GridRow{
                        Text("Food")
                    }//grid row 3
                }//vstack
                
                Divider()
                
                GridRow{
                    Button(action: {
                        print("food1 btn press")
//                        self.selection = 1
                        lessonName = "Food1"
                        self.food1.toggle()
                    }){
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food1){
                        IndividualLesson(lessonName: $lessonName)
//                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        print("food2 btn press")
                        self.selection = 1
                    }){
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn food 2
                    .buttonStyle(.borderless)
                }//grid row
                .padding()
                
                GridRow{
                    Button(action: {
                        print("food3 btn press")
                        self.selection = 1
                    }){
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn3
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        print("food4 btn press")
                        self.selection = 1
                    }){
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn food 4
                    .buttonStyle(.borderless)
                }//grid row
                .padding()
                
            }//grid
            .background(Color("Background"))
            .padding(.vertical, -15)
            .padding(.horizontal, -20)
            
            
            
            
            //                    HStack{
            ////                                    Spacer()
            //                                    VStack{
            //                                        Image(systemName: "play.rectangle")
            //                                        Text("Lesson")
            //                                            .padding(.top, 1)
            //                                    }
            //                                    .foregroundColor(selection == 1 ? Color("fontLink") : Color("fontBody"))
            //                                    .onTapGesture {
            //                                        self.selection = 2
            //                                    }
            //
            ////                                    Spacer()
            //                                    VStack{
            //                                        Image(systemName: "book")
            //                                        Text("Weekly Game")
            //                                            .padding(.top, 1)
            //                                    }
            //                                    .foregroundColor(selection == 2 ? Color("fontLink") : Color("fontBody"))
            //                                    .onTapGesture {
            //                                        self.selection = 3
            //                                    }
            ////                                    Spacer()
            //                                }
            
            
        }//list
        
        
        
        .background(Color("Background"))
        .scrollContentBackground(.hidden)
        
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        
        ZStack{
            Rectangle()
                .fill(Color("Background"))
                .shadow(color: .gray, radius: 3, x: -2, y: 2)
                .frame(maxWidth: .infinity, maxHeight: 50)
            
        HStack {
            
                    
            
            Spacer()
            
            Button(action: {
                //                        self.selection = 6
                
                print("buttpress")
            }) {
                Image(systemName: "book.fill")
                    .imageScale(.large) // Adjust icon size
                    .foregroundStyle(Color("CustYell"))
            }
            
            Spacer()
            
            Button(action: {
//                self.selection = 3
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
            
            ZStack{
                Circle()
                    .fill(Color("WhiteDiff"))
                    .frame(width: 50, height: 50)
                Button(action: {
//                    self.selection = 6
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
//                self.selection = 4
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
//                self.selection = 5
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
            
//            Group {
//                
//                ZStack{
//                    Circle()
//                        .fill(Color("WhiteDiff"))
//                        .frame(width: 50, height: 50)
//                    Button(action: {
//                        self.selection = 6
//                    }) {
//                        Image(systemName: "house.fill")
//                            .imageScale(.large) // Adjust icon size
//                            .foregroundStyle(Color("Background"))
//                    }
//                }
//                
//                
//                Spacer()
//                
//                Button(action: {
//                    self.selection = 4
//                }) {
//                    Image(systemName: "dollarsign.circle.fill")
//                        .imageScale(.large) // Adjust icon size
//                        .foregroundStyle(Color.gray)
//                }
//                
//                Spacer()
//                
//                Button(action: {
//                    self.selection = 5
//                }) {
//                    Image(systemName: "trophy.fill")
//                        .imageScale(.large) // Adjust icon size
//                        .foregroundStyle(Color.gray)
//                }
//                
//                Spacer()
//                
//            }
            
        }
        .background(Color("Background"))
    }
        .background(Color("Background"))


            
//        }//nav view
    }
}

//#Preview {
//    LessonsPage()
//}
