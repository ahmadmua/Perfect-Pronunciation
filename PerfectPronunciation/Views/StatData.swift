//
//  StatData.swift
//  PerfectPronunciation
//
//  Created by Muaz on 2023-10-25.
//

import SwiftUI
import Charts

struct StatData: View {
    
    @ObservedObject private var viewModel = AccuracyViewModel()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
        
            Words(
                weekly: viewModel.word.name,
                sum: Double(viewModel.word.data.sum(\.AccuracyScore))
            )
            
            AccuracyBarChart(
                data: viewModel.word.data,
                range: viewModel.accuracyRange
            )
            
//            StatPicker(
//                options: viewModel.pickerOptions,
//                selection: $viewModel.selectedIndex.animation(.easeInOut(duration: 0.6))
//            )
            
            
        }.padding()
        
        
    }
}

struct StatData_Previews: PreviewProvider {
    static var previews: some View {
        StatData()
    }
}
