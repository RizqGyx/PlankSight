//
//  NotificationService.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 21/04/26.
//

import Foundation

class NotificationService {
    static let shared = NotificationService()
    
    private let userDefaults = UserDefaults.standard
    private let lastSessionDateKey = "lastSessionDate"
    private let currentStreakKey = "currentStreak"
    
    private init() {}
    
    // MARK: - Streak Tracking
    
    func getCurrentStreak() -> Int {
        return userDefaults.integer(forKey: currentStreakKey)
    }
    
    func setCurrentStreak(_ streak: Int) {
        userDefaults.set(streak, forKey: currentStreakKey)
    }
    
    func isSessionCompletedToday() -> Bool {
        guard let lastSessionDate = userDefaults.object(forKey: lastSessionDateKey) as? Date else {
            return false
        }
        
        let calendar = Calendar.current
        return calendar.isDateInToday(lastSessionDate)
    }
    
    func logSessionCompleted() {
        let now = Date()
        let calendar = Calendar.current
        
        // Check if session was completed yesterday (to maintain streak)
        let lastSessionDate = userDefaults.object(forKey: lastSessionDateKey) as? Date
        let isYesterday = lastSessionDate.map { calendar.isDateInYesterday($0) } ?? false
        
        // Update streak
        let currentStreak = getCurrentStreak()
        if isYesterday || currentStreak == 0 {
            // Continue or start new streak
            setCurrentStreak(currentStreak + 1)
        }
        
        // Log today's session
        userDefaults.set(now, forKey: lastSessionDateKey)
        
        // Cancel notifications since session completed
        NotificationManager.shared.cancelAllNotifications()
    }
    
    // MARK: - Message Generation
    
    func getMorningMessage(streak: Int) -> String {
        let messages = [
            "Mulai hari mu dengan plank! Yakin bisa hari ini? 💪",
            "Pagi yang bagus! Saatnya plank dan mulai hari dengan energi 🌅",
            "Morning workout? Plank dulu yuk! 🔥",
            "Halo! Streak \(streak) hari menunggu kelanjutannya 🎯",
            "Jangan sia-siakan hari ini! Plank sekarang! 💯",
            "Selamat pagi! Waktunya mulai latihan plank harian mu 🏃",
            "Tubuh mu menunggu. Mulai plank hari ini! 💪"
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    func getEveningMessage(streak: Int) -> String {
        let messages: [String]
        
        if streak == 0 {
            messages = [
                "Malam! Jangan lupa mulai streak mu hari ini! 🚀",
                "Waktu terbaik untuk plank adalah sekarang! 💪",
                "Malam ini saatnya dimulai! Plank bisa 🔥",
                "Ayo dimulai! Plank malam ini untuk streak pertama mu!"
            ]
        } else if streak < 7 {
            messages = [
                "Jangan putus! Streak \(streak) hari mu menunggu! 🔥",
                "Tinggal plank 1x lagi hari ini buat streak \(streak) harimu! 💪",
                "Malam! Jangan lupa, streak \(streak) hari butuh 1 session lagi 🎯",
                "Ayo! Satu sesi plank untuk jaga streak \(streak) hari mu! 🌟",
                "Belum plank hari ini? Streak \(streak) harimu menunggu! ⏰"
            ]
        } else if streak < 30 {
            messages = [
                "WOW \(streak) hari! Jangan putus sekarang! 🏆",
                "Impresif! Streak \(streak) hari, tinggal 1 sesi lagi! 🔥",
                "Jangan sia-siakan \(streak) hari hard work mu! 💎",
                "\(streak) hari konsisten! Ayo satu sesi lagi! 🚀",
                "Keren banget! \(streak) hari streak jangan sampai putus sekarang 💪"
            ]
        } else {
            messages = [
                "LEGEND! \(streak) hari! Satu sesi lagi untuk legacy mu! 👑",
                "\(streak) hari MASTER PLANK! Tutup hari ini dengan sempurna! 💯",
                "Unbelievable! \(streak) hari! Ayo finish strong! 🔥",
                "Hall of fame pending! \(streak) hari, satu sesi lagi! 🏅",
                "\(streak) hari straight! Kamu luar biasa! Pertahankan! 🌟"
            ]
        }
        
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Reset Daily
    func checkAndResetStreak() {
        let lastSessionDate = userDefaults.object(forKey: lastSessionDateKey) as? Date
        guard let lastDate = lastSessionDate else { return }
        
        let calendar = Calendar.current
        let daysSinceLastSession = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        
        // If more than 1 day has passed, reset streak
        if daysSinceLastSession > 1 {
            setCurrentStreak(0)
        }
    }
}
