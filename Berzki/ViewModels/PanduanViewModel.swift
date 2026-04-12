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
    @Published var dontShowAgain = false
    @Published var currentPage = 0
    
    func nextAction() {
        print("Lanjut ditekan, dontShowAgain: \(dontShowAgain)")
    }
    
    func setTab(_ index: Int) {
        selectedTab = index
        currentPage = 0
    }
}
