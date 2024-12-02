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
    @State var showingAlert: Bool = false

    var body: some View {
        Text("Current Currency: \(currModel.userCurr)")
            .font(.title2)  // Set a nice, prominent font size
            .fontWeight(.bold)  // Make the text bold for emphasis
            .padding()  // Add padding around the text
            .cornerRadius(10)  // Round the corners of the background
            .padding(.horizontal)  // Extra horizontal padding

        List {
            Grid {
//                VStack(alignment: .leading) { // Align content to the left
//                    GridRow {
//                        Text("Themes")
//                    } //grid row 1
//                    
//                    Divider()
//                    
//                    GridRow {
//                        VStack(alignment: .leading) { // Ensure all rows are left-aligned
//                            HStack(alignment: .top) {
//                                Button(action: {
//                                    print("theme1 btn press")
//                                }) {
//                                    Image(systemName: "square.fill")
//                                        .font(.system(size: 50, weight: .light))
//                                } //btn
//                                .buttonStyle(.borderless)
//                                
//                                VStack(alignment: .leading) {
//                                    Text("Theme 1")
//                                    Text("200")
//                                        .padding(.leading, 20)
//                                }
//                            } // hstack item 1
//                            
//                            HStack(alignment: .top) {
//                                Button(action: {
//                                    print("Theme2 btn press")
//                                }) {
//                                    Image(systemName: "square.fill")
//                                        .font(.system(size: 50, weight: .light))
//                                } //btn
//                                .buttonStyle(.borderless)
//                                
//                                VStack(alignment: .leading) {
//                                    Text("Theme 2")
//                                    Text("200")
//                                        .padding(.leading, 20)
//                                }
//                            } //hstack item 2
//                            
//                            HStack(alignment: .top) {
//                                Button(action: {
//                                    print("theme 3 btn press")
//                                }) {
//                                    Image(systemName: "square.fill")
//                                        .font(.system(size: 50, weight: .light))
//                                } //btn
//                                .buttonStyle(.borderless)
//                                
//                                VStack(alignment: .leading) {
//                                    Text("Theme 3")
//                                    Text("200")
//                                        .padding(.leading, 20)
//                                }
//                            } //hstack item 3
//                        } // VStack inside GridRow
//                        .padding()
//                    } //grid row 2
//                } //VStack Themes
                
                VStack(alignment: .leading) { // Align content to the left
                    GridRow {
                        Text("Items")
                            .font(.headline) // Make it more prominent
                            .padding(.vertical, 8) // Add vertical padding to prevent cutting off
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure alignment to the left
                    } // GridRow 1
                    
                    Divider()
                    
                    GridRow {
                        VStack(alignment: .leading, spacing: 16) { // Add spacing between items
                            HStack(alignment: .top) {
                                Button(action: {
                                    print("Time Increase btn press")
                                    currModel.subUserCurrency(cost: 300, item: "TimeIncrease")
                                }) {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                } // Button
                                .buttonStyle(.borderless)
                                .disabled(currModel.timeIncreasePurchase)
                                
                                VStack(alignment: .leading) {
                                    Text("Time Increase")
                                        .font(.body) // Consistent font size
                                    Text("300")
                                        .padding(.leading, 20)
                                }
                            } // HStack for Time Increase
                            
                            HStack(alignment: .top) {
                                Button(action: {
                                    print("Level Boost btn press")
                                    currModel.subUserCurrency(cost: 1000, item: "LevelBoost")
                                }) {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                } // Button
                                .buttonStyle(.borderless)
                                
                                VStack(alignment: .leading) {
                                    Text("Level Boost")
                                        .font(.body)
                                    Text("1000")
                                        .padding(.leading, 20)
                                }
                            } // HStack for Level Boost
                        } // VStack inside GridRow
                        .padding(.top, 8) // Add padding to avoid overlap
                    } // GridRow 2
                } // VStack Items
                .padding(.horizontal, 16) // Ensure padding for the entire section
                
                VStack(alignment: .leading) { // Align content to the left
                    GridRow {
                        Text("Wager")
                            .font(.headline) // Make it more prominent
                            .padding(.vertical, 8) // Add vertical padding to prevent cutting off
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure alignment to the left
                    } // GridRow 1
                    
                    Divider()
                    
                    GridRow {
                        VStack(alignment: .leading, spacing: 16) { // Add spacing between items
                            HStack(alignment: .top) {
                                Button(action: {
                                    print("Weekly Challenge Wager btn press")
                                    currModel.subUserCurrency(cost: 300, item: "WeeklyChallengeWager")
                                }) {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 50, weight: .light))
                                } // Button
                                .buttonStyle(.borderless)
                                .disabled(currModel.timeIncreasePurchase)
                                
                                VStack(alignment: .leading) {
                                    Text("Weekly Challenge Wager")
                                        .font(.body) // Consistent font size
                                    Text("500")
                                        .padding(.leading, 20)
                                }
                            } // HStack for Weekly Challenge Wager
                        } // VStack inside GridRow
                        .padding(.top, 8) // Add padding to avoid overlap
                    } // GridRow 2
                } // VStack Wager
                .padding(.horizontal, 16) // Ensure padding for the entire section

                
            } //grid
            
            .background(Color("Background"))
            .padding(.vertical, -15)
            .padding(.horizontal, -20)
        } //list
        .background(Color("Background"))
        .scrollContentBackground(.hidden)
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustYell"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Sorry, You need \(currModel.neededToPurchase) more currency to purchase this item!", isPresented: $currModel.canUserPurchase) {
            Button("OK", role: .cancel) {}
        }
        .alert("You successfully bought this item", isPresented: $currModel.userDidPurchase) {
            Button("OK", role: .cancel) {
                currModel.getUserCurrency()
                currModel.checkBuyTime()
            }
        }
        .alert("You successfully bought this item \n You have gained 1 Level", isPresented: $currModel.userDidPurchaseLevel) {
            Button("OK", role: .cancel) {
                currModel.getUserCurrency()
                currModel.userBuyLevel()
            }
        }
        
        ZStack {
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
                        .imageScale(.large)
                        .foregroundStyle(Color.gray)
                }
                .navigationDestination(isPresented: $showLesson) {
                    LessonsPage()
                        .navigationBarBackButtonHidden(true)
                }
                Spacer()
                Button(action: {
                    self.showWeekly.toggle()
                }) {
                    Image(systemName: "gamecontroller.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color.gray)
                }
                .navigationDestination(isPresented: $showWeekly) {
                    WeeklyGamePage()
                        .navigationBarBackButtonHidden(true)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color("WhiteDiff"))
                        .frame(width: 50, height: 50)
                    Button(action: {
                        self.showHome.toggle()
                    }) {
                        Image(systemName: "house.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color("Background"))
                    }
                    .navigationDestination(isPresented: $showHome) {
                        Homepage()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color("CustYell"))
                }
                Spacer()
                Button(action: {
                    self.showAchievement.toggle()
                }) {
                    Image(systemName: "trophy.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color.gray)
                }
                .navigationDestination(isPresented: $showAchievement) {
                    AchievementPage()
                        .navigationBarBackButtonHidden(true)
                }
                Spacer()
            } //hstack
            .background(Color("Background"))
        } //zstack
        .background(Color("Background"))
        .onAppear {
            model.findUserDifficulty {
                print("USER DIFICULTY!! : \(model.difficulty!)")
            }
            currModel.getUserCurrency()
            currModel.checkBuyTime()
        } //onAppear
    } //body view
} //view
