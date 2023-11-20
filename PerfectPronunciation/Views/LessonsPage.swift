//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct LessonsPage: View {
    @ObservedObject var model = LessonController()
//    @State private var msg = ""
    @State private var showLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    @State private var selection: Int? = nil
    
    @State private var phonetics = false
    @State private var food1 = false
    @State private var food2 = false
    @State private var conversation = false
    @State private var numbers = false
    @State private var direction = false
    
    @State var showingPopup = false
    
    @State private var lessonName = ""
    
    
    var body: some View {
        //        NavigationStack{
        

        List{
            Grid{
                VStack{
                    GridRow{
                        Text("Coversation")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        //phonetics
//                        Button(action: {
//                            print("phonetic btn press")
////                            self.selection = 1
//                            lessonName = "Phonetics"
//                            self.phonetics.toggle()
//                        }){
//                            Image(systemName: "mouth.fill")
//                                .font(.system(size: 50, weight: .light))
//                        }//btn
//                        .navigationDestination(isPresented: $phonetics){
//                            IndividualLesson(lessonName: $lessonName)
//                        }
//                        .buttonStyle(.borderless)
                        
                        
                        Button(action: {
                            print("conversation btn press")
    //                        self.selection = 1
                            self.lessonName = "Conversation"
                            self.food1.toggle()
                        }){
                            Image(systemName: "rectangle.3.group.bubble.left.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $conversation){
                            IndividualLesson(lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row 2
                    .padding()
                }//Vstack
                
                VStack{//Numbers
                    GridRow{
                        Text("Numbers")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        
                        
                        Button(action: {
                            print("numbers btn press")
    
                            self.lessonName = "Numbers"
                            self.numbers.toggle()
                        }){
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $numbers){
                            IndividualLesson(lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row 2
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
                        print("food1 btn press")
//                        self.selection = 1
                        self.lessonName = "Food1"
                        self.food1.toggle()
                    }){
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food1){
                        IndividualLesson(lessonName: $lessonName)
                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        print("food2 btn press")
//                        self.selection = 1
                        self.lessonName = "Food2"
                        self.food2.toggle()
                    }){
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food2){
                        IndividualLesson(lessonName: $lessonName)
                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                }//grid row
                .padding()
                
                
                VStack{//Directions
                    GridRow{
                        Text("Directions")
                    }//grid row 1
                    
                    Divider()
                    
                    GridRow{
                        
                        
                        Button(action: {
                            print("directions btn press")
    
                            self.lessonName = "Directions"
                            self.direction.toggle()
                        }){
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $direction){
                            IndividualLesson(lessonName: $lessonName)
                                .navigationBarBackButtonHidden(true)
                        }
                        .buttonStyle(.borderless)
                        
                        
                    }//grid row 2
                    .padding()
                }//Directions vstack
                
                
                
                
            }//grid
            .background(Color("Background"))
            .padding(.vertical, -15)
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
            
            Group {
                
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
            }
           
        }
        .background(Color("Background"))
    }
        .background(Color("Background"))
//        .onAppear(){
//            model.findUserDifficulty()
//        }


            
//        }//nav view
    }
        
}

//#Preview {
//    LessonsPage()
//}
