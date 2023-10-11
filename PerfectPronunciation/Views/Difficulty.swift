//
//  Difficulty.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-10.
//

import SwiftUI

struct Difficulty: View {
    @State private var selectedDifficulty: String?
    @State private var selection: Int? = nil
    

    let difficulties = ["I'm new to English and want to work on my basic pronunciation skills.",
        "I've been learning English and I want to enhance my pronunciation and fluency.",
        "I'm an advanced English learner aiming for near-native pronunciation and fluency refinement."]

    var body: some View {
        VStack{
            
            NavigationLink(destination: Homepage(), tag: 1, selection: self.$selection){}
            
            Text("Select Your Exerience Level")
                .fontWeight(.bold)
                .font(Font.system(size: 40))
                .foregroundColor(Color.yellow)
                .padding(.top, 50)
                .multilineTextAlignment(.center)
            
            List(difficulties, id: \.self, selection: $selectedDifficulty) { difficulty in
                HStack {
                    Text(difficulty)
                    Spacer()
                    if difficulty == selectedDifficulty {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .frame(height: 300)
            
            Spacer()
            
            Text("Depending on your selected proficiency level, our app will curate content tailored to your specific needs and goals")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black)
                .bold()
                .padding(.leading, 10)
                .padding(.trailing, 10)
            
            Spacer()
            
            Button(action: {
                self.selection = 1
            })
            {
                Text("Next")
                    .modifier(CustomTextM(fontName: "", fontSize: 30, fontColor: Color.black))
                
                    .frame(maxWidth: 270)
                    .frame(height: 56, alignment: .leading)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            
            Spacer()
            
        }
    }
}


struct Difficulty_Previews: PreviewProvider {
    static var previews: some View {
        Difficulty()
    }
}
