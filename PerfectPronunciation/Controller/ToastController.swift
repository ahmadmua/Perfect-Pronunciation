//
//  ToastController.swift
//  PerfectPronunciation
//
//  Created by Nichoalas Cammisuli on 2024-11-25.
//

import Foundation
import SwiftUI

class ToastController: ObservableObject {
    @Published var showToast = false
    @Published var toastMessage = ""

    func showToast(message: String, duration: TimeInterval = 2) {
        toastMessage = message
        showToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.showToast = false
            }
        }
    }
}
