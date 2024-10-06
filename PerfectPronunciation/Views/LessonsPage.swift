//
//  LessonsPage.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2023-10-28.
//

import SwiftUI
import Combine

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
    //openai
    @State private var responseText: String = "Press the button to get a response"
    @State private var responseArray : [String] = []
    @State private var cancellable: AnyCancellable?
    private let openAIService = OpenAIService()
    
    
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
                            self.conversation.toggle()
                            
                            fetchOpenAiResponse()
                        }){
                            Image(systemName: "rectangle.3.group.bubble.left.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $conversation){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
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
                            
                            fetchOpenAiResponse()
                            
                        }){
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $numbers){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
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
                        
                        fetchOpenAiResponse()
                    }){
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food1){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
                            .navigationBarBackButtonHidden(true)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        //go to lesson
                        print("food2 btn press")

                        self.lessonName = "Food2"
                        self.food2.toggle()
                        
                        fetchOpenAiResponse()
                    }){
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50, weight: .light))
                    }//btn
                    .navigationDestination(isPresented: $food2){
                        IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
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
    
                            self.lessonName = "Conversational Directions"
                            self.direction.toggle()
                            
                            fetchOpenAiResponse()
                            
                        }){
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 50, weight: .light))
                        }//btn
                        .navigationDestination(isPresented: $direction){
                            IndividualLesson(audioController: AudioController(), lessonName: $lessonName, responseText: $responseText, responseArray: $responseArray)
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
            openAIService.fetchAPIKey()
            
            model.findUserDifficulty{
                print("USER DIFICULTY!! : \(model.difficulty!)")
                print("TEST")
                
                UserDefaults.standard.synchronize()
                
            }

            if(achieveModel.achievementOneCompletion()){
                achieveModel.updateUserAchievement(userAchievement: "Achievement 1")
            }
        }

        /*
         THIS WAS COMMENTED OUT - BUT I STILL DONT GET ALERT FOR CURRENCY WHEN IT IS UNCOMMENTED
         */
//        .alert("Congrats, You just earned currency!", isPresented: $showingAlert) {
//            Button("OK", role: .cancel) {
//                currModel.updateUserCurrency()
//            }
//                }//alert
            

    }//body view
    
    
    /*
     TODO: Save the AI response as a list and pass the list to the individual lesson
     TODO: Need to fix the prompt generation sentence
     
     */
    
    func fetchOpenAiResponse() {
        openAIService.fetchMultipleOpenAIResponses(prompt: "I am an english language learner. Please Create a \(model.difficulty!) sentence about \(lessonName) to perfect my pronunciation as an English learner. Please only include the sentence for me to pronounce. Ensure that the sentence is different from the following sentences, completely change the sentence and leave no trace:  \(responseArray)") { result in
            switch result {
            case .success(let responses):
                print("Got 5 responses:")
                responses.forEach{ response in
                    print(response)
                    responseArray.append(response)
                    
                    responseText = response
                    
                }
            case .failure(let error):
                responseText = "Error: \(error.localizedDescription)"
            }
        }
    }//func
        
}//view

//#Preview {
//    LessonsPage()
//}
