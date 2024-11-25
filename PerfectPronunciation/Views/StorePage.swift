//
//  StorePage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI

struct StorePage: View {
    //nav vars
    @State private var selection: Int? = nil
    @State private var showLesson = false
    @State private var showIndiLesson = false
    @State private var showWeekly = false
    @State private var showAchievement = false
    @State private var showStore = false
    @State private var showHome = false
    //controller vars
    @ObservedObject var currModel = CurrencyController()
    @ObservedObject var model = LessonController()
    //alert
    @State var showingAlert : Bool = false
    
    
    var body: some View {
  
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
                                        //this is to test subtracting small currency
//                                        currModel.subUserCurrency(cost: 200, item: "TimeIncrease")
                                        
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 1")
                                    
                                    HStack(alignment: .center){
                                        Text("200")
                                    }
                                    .padding(.leading, 60)
                                }// hstack item 1
                                
                                
                                    HStack{
                                        Button(action: {
                                            print("Theme2 btn press")
                                            //this is to test subtracting large currency
//                                            currModel.subUserCurrency(cost: 1000, item: "TimeIncrease")
                                            
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Theme 2")
                                        
                                        HStack(alignment: .center){
                                            Text("200")
                                            
                                        }
                                        .padding(.leading, 60)
                                    }//hstack item 2
                                
                                HStack{
                                    Button(action: {
                                        print("theme 3 btn press")
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Theme 3")
                                    
                                    HStack(alignment: .center){
                                        Text("200")
                                        
                                    }
                                    .padding(.leading, 60)
                                }//hstack item 3
                              
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
                                        print("time increase btn press")
                                        //purchase the item and update firebase with the purchase
                                        currModel.subUserCurrency(cost: 300, item: "TimeIncrease")
                                        
//                                        if(currModel.canUserPurchase == true){
//                                            currModel.buyItem(storeItem: "TimeIncrease")
//                                        }
                                        
                                        
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    //disable when user purchases
                                    .disabled(currModel.timeIncreasePurchase)
                                    
                                    Text("Time Increase")
                                    
                                    HStack(alignment: .center){
                                        Text("300")
                                    }
                                    .padding(.leading, 60)
                                }//hstack item time purchase
                                
                                    HStack{
                                        Button(action: {
                                            print("item2 btn press")
                                            
                                        }){
                                            Image(systemName: "square.fill")
                                                .font(.system(size: 50, weight: .light))
                                        }//btn
                                        .buttonStyle(.borderless)
                                        
                                        Text("Item 2")
                                        
                                        HStack(alignment: .center){
                                            Text("300")
                                        }
                                        .padding(.leading, 60)
                                    }//hstack item 2
                                
                                HStack{
                                    Button(action: {
                                        print("item 3 btn press")
                                    }){
                                        Image(systemName: "square.fill")
                                            .font(.system(size: 50, weight: .light))
                                    }//btn
                                    .buttonStyle(.borderless)
                                    
                                    Text("Item 3")
                                    
                                    HStack(alignment: .center){
                                        Text("300")
                                    }
                                    .padding(.leading, 60)
                                }//hstack item 3
                              
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
                //need more money alert
                .alert("Sorry, You need \(currModel.neededToPurchase) more cuurency to purches this item!", isPresented: $currModel.canUserPurchase) {
                    Button("OK", role: .cancel) {
                        
                    }
                        }
                //purchase successful
                .alert("You successfuly bought this item", isPresented: $currModel.userDidPurchase) {
                    Button("OK", role: .cancel) {
                        currModel.checkBuyTime()
                    }
                        }
        
        ZStack{
            Rectangle()
                .fill(Color("Background"))
                .shadow(color: .gray, radius: 3, x: -2, y: 2)
                .frame(maxWidth: .infinity, maxHeight: 50)
        HStack {

            Spacer()
            
            Button(action: {
                //nav to page
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
                //nav to page
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
                        //nav to page
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
                    //nav to page
                    print("buttpress")
                }) {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large) // Adjust icon size
                    
                        .foregroundStyle(Color("CustYell"))
                }
                
                Spacer()
                
                Button(action: {
                    //nav to page
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
            
        }//hstack
        .background(Color("Background"))
    }//zstack
        .background(Color("Background"))
        .onAppear(){
            //find the users difficulty
            model.findUserDifficulty{
                //get the users current currency
                currModel.getUserCurrency()
            }
            //check if the user has purchased an item
            currModel.checkBuyTime()
        }//on appear
        }//body view
        
    }//view

////#Preview {
//    StorePage()
//}
