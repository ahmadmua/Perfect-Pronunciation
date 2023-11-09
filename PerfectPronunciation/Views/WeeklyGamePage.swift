//
//  WeeklyGamePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct WeeklyGamePage: View {

    
    @State private var selection: Int? = nil
    @State private var showLesson = false
    @State private var showIndiLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false

    
    var body: some View {
//        NavigationStack{
            
//            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}.navigationBarBackButtonHidden(true)
            
            ScrollView{
                
                VStack{
                    
                    //                ZStack{
                    //
                    //                    RoundedRectangle(cornerRadius: 25)
                    //                        .fill(Color("CustYell"))
                    //                        .frame(width: 400, height: 200)
                    //                    Text("Weekly Challenge")
                    //                        .foregroundStyle(Color.white)
                    //                        .font(.title)
                    //                }
                    
                    Text("Blurb about how to play! blehblahbleh blahblah blehblahbleh blahblahblehblahbleh blahblahblehblahbleh blahblahblehblahbleh blahblah")
                        .padding(.vertical, 30)
                    
                    Button("Start Challenge"){
                        self.selection = 1
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                    
                    
                    Divider()
                    
                    Grid{
                        GridRow{
                            HStack{
                                Text("Rank")
                                Text("Name")
                                Text("Score")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("1")
                                Text("Nick")
                                Text("10")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("2")
                                Text("Jordan")
                                Text("8")
                            }
                        }
                        GridRow{
                            HStack{
                                Text("3")
                                Text("Muaz")
                                Text("7")
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    
                    
                    
                }
                
            

                
                                
//                List{
//                    ForEach(1..<5){index in
//                        Text("Row \(index)")
//                    }
//                }
//                        Spacer()
                        
                        
                        
                    }
            .navigationTitle("Weekly Challenge")
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
//                                        self.selection = 2
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
//                self.selection = 3
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
        }
                }
                //        .safeAreaInset(edge: .top){
                //
//            }
            
//}
        
   
    


//#Preview {
//    WeeklyGamePage()
//}
