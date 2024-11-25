//
//  ToastView.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-11-25.
//

import SwiftUI

struct ToastView: View {
    @Binding var showToast: Bool
    let message : String

    var body: some View {
        if showToast {
            Text(message)
                .padding()
                .background(Color.blue.opacity(0.8)) // Customize as needed
                .cornerRadius(10)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .padding()
        }
    }
}
