//
//  StorePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct StorePage: View {
    
    @State private var selection: Int? = nil
    @State private var showLesson = false
    @State private var showIndiLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
//    @State private var selection: Int? = nil
    
    var body: some View {
        
        
//        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}.navigationBarBackButtonHidden(true)
//        NavigationStack{
            
//            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}
  
                List{
                    Grid{
                        VStack{
                            GridRow{
                                Text("Themes")
                            }//grid row 1
                            
                            Divider()
                            
                            GridRow{
                                HStack{
                                    Button(action: {
                                        print("theme1 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 1")
                                    
                                    HStack(alignment: .center){
                                        Text("20")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                
//                                GridRow{
                                    HStack{
                                        Button(action: {
                                            print("Theme2 btn press")
                                            //                                    self.selection = 1
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Theme 2")
                                        
                                        HStack(alignment: .center){
                                            Text("20")
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 25, weight: .light))
                                            
                                        }
                                        .padding(.leading, 60)
                                    }
                                
                                HStack{
                                    Button(action: {
                                        print("theme 3 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 3")
                                    
                                    HStack(alignment: .center){
                                        Text("20")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                              
                                
                            }//grid row 2
                            .padding()

                                                    
                            
                        }//Vstack
                        
                        VStack{
                            GridRow{
                                Text("Items")
                            }//grid row 1
                            
                            Divider()
                            
                            GridRow{
                                HStack{
                                    Button(action: {
                                        print("item1 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Item 1")
                                    
                                    HStack(alignment: .center){
                                        Text("30")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                
//                                GridRow{
                                    HStack{
                                        Button(action: {
                                            print("item2 btn press")
                                            //                                    self.selection = 1
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Item 2")
                                        
                                        HStack(alignment: .center){
                                            Text("30")
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 25, weight: .light))
                                            
                                        }
                                        .padding(.leading, 60)
                                    }
                                
                                HStack{
                                    Button(action: {
                                        print("item 3 btn press")
                                        //                                    self.selection = 1
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Item 3")
                                    
                                    HStack(alignment: .center){
                                        Text("30")
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 25, weight: .light))
                                        
                                    }
                                    .padding(.leading, 60)
                                }
                              
                                
                            }//grid row 2
                            .padding()

                            
                           
                            
                        }//Vstack
                        
                       
                        
   
                     
                        
                    }//grid
                    
                    .background(Color("Background"))
                    .padding(.vertical, -15)
                    .padding(.horizontal, -20)
                    
                }//list
                .background(Color("Background"))
                .scrollContentBackground(.hidden)
            
                .navigationTitle("Store")
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
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                            .foregroundStyle(Color("Background"))
                    }
                    .navigationDestination(isPresented: $showHome){
                        Homepage()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                
                
                //                Spacer()
                
                
                
                
                
                Spacer()
                
                Button(action: {
                    //                self.selection = 4
                    print("buttpress")
                }) {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large) // Adjust icon size
                    
                        .foregroundStyle(Color("CustYell"))
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
//}

////#Preview {
//    StorePage()
//}
