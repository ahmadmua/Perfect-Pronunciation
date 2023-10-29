//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI


struct LessonsPage: View {
//    @State private var msg = ""
    @State private var selection: Int? = nil
    
    
    var body: some View {
        //        NavigationStack{
        
        NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}

            NavigationLink(destination: IndividualLesson(), tag: 1, selection: self.$selection){}
        NavigationLink(destination: LessonsPage(), tag: 2, selection: self.$selection){}
        NavigationLink(destination: WeeklyGamePage(), tag: 3, selection: self.$selection){}
        NavigationLink(destination: AchievementPage(), tag: 5, selection: self.$selection){}
        NavigationLink(destination: StorePage(), tag: 4, selection: self.$selection){}
        NavigationLink(destination: Homepage(), tag: 6, selection: self.$selection){}
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
                                    self.selection = 1
                                }){
                                    Image(systemName: "mouth.fill")
                                        .font(.system(size: 50, weight: .light))
                                }//btn
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
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn
                            
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
                            
                            Button(action: {
                                print("food4 btn press")
                                self.selection = 1
                            }){
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 50, weight: .light))
                            }//btn food 4
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
                            self.selection = 1
                        }){
                            Image(systemName: "birthday.cake.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        
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
                .padding(.vertical, -15)
                .padding(.horizontal, -20)
                
            }//list
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
            
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CustYell"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
            
            
            //            LessonsPage()
            //                .tabItem{
            //                    Image(systemName: "book.fill")
            //                }
            
            
        HStack {
            Spacer()
            
            Button(action: {
                self.selection = 1
            }) {
                Image(systemName: "person.circle")
                    .imageScale(.large) // Adjust icon size
            }
            
            Spacer()
            
            Button(action: {
                self.selection = 2
            }) {
                Image(systemName: "person.circle")
                    .imageScale(.large) // Adjust icon size
            }
            
            Spacer()
            
            Button(action: {
                self.selection = 3
            }) {
                Image(systemName: "person.circle")
                    .imageScale(.large) // Adjust icon size
            }
            
            Spacer()
            
            Button(action: {
                self.selection = 4
            }) {
                Image(systemName: "person.circle")
                    .imageScale(.large) // Adjust icon size
            }
            
            Spacer()
        }

        
        HStack {
                    Spacer()
                    
                    Button(action: {
                        self.selection = 6
                    }) {
                        Image(systemName: "book.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 3
                    }) {
                        Image(systemName: "gamecontroller.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 4
                    }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selection = 5
                    }) {
                        Image(systemName: "trophy.fill")
                            .imageScale(.large) // Adjust icon size
                    }
                    
                    Spacer()
                }
        


            
//        }//nav view
    }
            
        }

            
//        }//nav view
    


//#Preview {
//    LessonsPage()
//}
