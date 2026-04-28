//
//  PanduanViewModel.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import Foundation
import Combine

class PanduanViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var isNextTapped: Bool = false
    @Published var currentPage = 0
    
    @Published var dontShowAgain: Bool = UserDefaults.standard.bool(forKey: "skipPanduan")
    
    func nextAction() {
        UserDefaults.standard.set(dontShowAgain, forKey: "skipPanduan")
        isNextTapped = true
    }
    
    func setTab(_ index: Int) {
        selectedTab = index
        currentPage = 0
    }
}
