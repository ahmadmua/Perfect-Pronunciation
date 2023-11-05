//
//  TestView.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-11-04.
//

import SwiftUI
import CoreML

let model = PronunciationModel()

struct TestView: View {
    
    @State var str = ""
    
    var body: some View {
        
        Button(action: {
            testModel()
        }){
            Text("TestModel")
                .modifier(CustomTextM(fontName: "MavenPro-Bold", fontSize: 16, fontColor: Color.black))
                .frame(maxWidth: .infinity)
                .frame(height: 56, alignment: .leading)
                .background(Color.yellow)
                .cornerRadius(10)
            
        }
    }
    
    
    func testModel(){
        let input = PronunciationModelInput(Feature1: 43, Feature2: 88, Feature3: 67, Feature4: 99, Feature5: 78)
        
        do {
            let prediction = try model.prediction(input: input)
            let outputClass = prediction.OutputClass
            
            if(outputClass == 1){
                str = "Your pronunciation is good"
            }
            else {
                str = "You need to work on your pronunciation"
            }
            
            print("Predicted Output Class: \(str)")
        } catch {
            print("Error making prediction: \(error)")
        }
        
        
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
