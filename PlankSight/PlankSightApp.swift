//
//  PlankSightApp.swift
//  Berzki
//
//  Created by Muhammad Rizki on 10/04/26.
//

import SwiftUI

@main
struct PlankSightApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appRouter = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            switch appRouter.rootScreen {
            case .splash:
                SplashView()
                    .environmentObject(appRouter)
            case .panduan:
                PanduanView()
                    .environmentObject(appRouter)
            case .main:
                NavigationStack(path: $appRouter.path) {
                    SetelWaktuView()
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .camera(let duration):
                                CameraView(duration: duration)
                            case .summary(let result):
                                SummaryView(result: result)
                            case .history:
                                HistoryView()
                            }
                        }
                }
                .environmentObject(appRouter)
            }
        }
    }
}
