//
//  AppRouter.swift
//  Berzki
//
//  Created by Muhammad Rizki on 17/04/26.
//

import SwiftUI
import Combine

enum RootScreen {
    case splash
    case panduan
    case main
}

enum AppRoute: Hashable {
    case camera(duration: Int?)
    case summary
    case history
}

class AppRouter: ObservableObject {
    @Published var rootScreen: RootScreen = .splash
    @Published var path = NavigationPath()
    
    // User Default Keys
    @AppStorage("skipPanduan") var skipPanduan: Bool = false
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Logic to decide where to go after Splash
    func finishSplash() {
        if skipPanduan {
            rootScreen = .main
        } else {
            rootScreen = .panduan
        }
    }
    
    /// Logic from PanduanView
    func finishPanduan(dontShowAgain: Bool) {
        if dontShowAgain {
            skipPanduan = true
        }
        rootScreen = .main
    }
    
    /// Logic to go back to Panduan explicitly (e.g. from SetelWaktuView X button)
    func goToPanduan() {
        rootScreen = .panduan
    }
}
