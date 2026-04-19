//
//  CameraViewModel.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import Foundation
import SwiftUI
import Combine

enum CameraSessionState {
    case searchingUser
    case waitingForPosition
    case tracking(sessionActive: Bool)
}

enum FormQuality: Equatable {
    case good
    case bad(errorMessage: String)
}

struct TrackedBodyPart: Identifiable {
    let id = UUID()
    let name: String
    var status: FormQuality
}

class CameraViewModel: ObservableObject {
    @Published var sessionState: CameraSessionState = .searchingUser
    
    // Timer properties
    let duration: Int? // nil means free time
    @Published var secondsElapsed: Int = 0
    @Published var secondsRemaining: Int = 0
    
    private var timerCancellable: AnyCancellable?
    
    init(duration: Int? = 30) {
        self.duration = duration
        if let d = duration {
            self.secondsRemaining = d
        }
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    // Tracking stats
    @Published var goodFormSeconds: Int = 0
    @Published var badFormSeconds: Int = 0
    
    private func tick() {
        guard case .tracking = sessionState else { return }
        
        // Stop timer if fixed duration is reached
        if let _ = duration, secondsRemaining <= 0 {
            return
        }
        
        if isFormPerfect {
            goodFormSeconds += 1
        } else {
            badFormSeconds += 1
        }
        
        if let _ = duration {
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            }
        } else {
            secondsElapsed += 1
        }
    }
    
    var displayTime: String {
        if let _ = duration {
            return formatTimer(secondsRemaining)
        } else {
            return formatTimer(secondsElapsed)
        }
    }

    private func formatTimer(_ totalSeconds: Int) -> String {
        if totalSeconds == 0 { return "0s" }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 3600) % 60
        
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 { parts.append("\(minutes)m") }
        if seconds > 0 || (hours == 0 && minutes == 0) { parts.append("\(seconds)s") }
        
        return parts.joined(separator: " ")
    }
    
    // Metrics tracked
    @Published var trackedParts: [TrackedBodyPart] = [
        TrackedBodyPart(name: "Kepala", status: .good),
        TrackedBodyPart(name: "Bahu", status: .good),
        TrackedBodyPart(name: "Punggung", status: .good),
        TrackedBodyPart(name: "Pinggul", status: .good),
        TrackedBodyPart(name: "Lutut", status: .good)
    ]
    
    // Derived property for the alert banner
    var currentAlertMessage: String? {
        // Collect any bad forms and show the first one, or join them
        let badForms = trackedParts.compactMap { part -> String? in
            if case .bad(let msg) = part.status { return "\(part.name): \(msg)" }
            return nil
        }
        return badForms.first
    }
    
    var isFormPerfect: Bool {
        return currentAlertMessage == nil
    }
    
    // Mock Actions for UI testing
    func toggleState() {
        switch sessionState {
        case .searchingUser:
            sessionState = .waitingForPosition
        case .waitingForPosition:
            sessionState = .tracking(sessionActive: true)
        case .tracking(let active):
            if active {
                // Simulate bad form
                trackedParts[3].status = .bad(errorMessage: "Terlalu rendah")
                sessionState = .tracking(sessionActive: false) // Plausibly paused or just warning
            } else {
                // Back to good
                for i in 0..<trackedParts.count {
                    trackedParts[i].status = .good
                }
                sessionState = .searchingUser
            }
        }
    }
}
