import SwiftUI

// MARK: - Card View

struct MotivationCardView: View {
    let card: MotivationCard

    private let amber = Color(red: 0.58, green: 0.32, blue: 0.06)

    var body: some View {
        ZStack(alignment: .topLeading) {

            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(amber)

            // Decorative background circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 180, height: 180)
                    .offset(x: geo.size.width - 70, y: -50)
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 110, height: 110)
                    .offset(x: geo.size.width - 20, y: 60)
            }
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: 10) {

                // Emoji icon bubble
                Text(card.emoji)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Label
                Text("MOTIVASI HARI INI")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.2)
                    .foregroundColor(Color.white.opacity(0.65))

                // Headline
                Text(card.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                // Body
                Text(card.message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.78))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Motivation Logic Helper

class MotivationCardHelper {
    static func generateMotivationCard(
        lastSessionDate: Date?,
        streak: Int,
        today completedToday: Bool
    ) -> MotivationCard {
        let calendar = Calendar.current
        let now = Date()

        if completedToday {
            // Milestone kelipatan 7
            if streak % 7 == 0 && streak > 0 {
                return MotivationCard(
                    color: .orange,
                    emoji: "🏆",
                    title: "\(streak) hari streak! Luar biasa.",
                    message: "Kamu telah membangun kebiasaan kuat. Tubuhmu pasti sudah merasakan manfaatnya!"
                )
            }
            // Mendekati milestone berikutnya
            let milestones = [3, 7, 14, 21, 28, 365]
            if let next = milestones.first(where: { $0 > streak }) {
                let daysLeft = next - streak
                if daysLeft == 1 {
                    return MotivationCard(
                        color: .green,
                        emoji: "💪",
                        title: "1 hari lagi untuk streak sempurna!",
                        message: "Kamu sudah plank \(streak) hari berturut-turut — badan mulai terbiasa. Jangan putus sekarang."
                    )
                } else if daysLeft <= 3 {
                    return MotivationCard(
                        color: .green,
                        emoji: "🔥",
                        title: "\(daysLeft) hari lagi menuju \(next) hari!",
                        message: "Streak-mu semakin solid. Pertahankan ritme ini dan capai milestone berikutnya."
                    )
                }
            }
            // Plank biasa hari ini
            return MotivationCard(
                color: .green,
                emoji: "💪",
                title: "Plank selesai hari ini!",
                message: "Kamu satu langkah lebih konsisten dari kemarin. Teruskan momentum ini!"
            )
        }

        // Belum pernah plank
        guard let lastDate = lastSessionDate else {
            return MotivationCard(
                color: .blue,
                emoji: "🚀",
                title: "Mulai perjalananmu hari ini.",
                message: "Satu menit plank sehari bisa mengubah segalanya. Konsistensi adalah kuncinya!"
            )
        }

        let daysSinceLastSession = calendar.dateComponents([.day], from: lastDate, to: now).day ?? 0

        if daysSinceLastSession == 0 {
            return MotivationCard(
                color: .yellow,
                emoji: "⚡",
                title: "Kemarin kamu keren banget!",
                message: "Hari ini mau plank lagi kan? Jangan biarkan momentum berhenti di sini."
            )
        } else if daysSinceLastSession == 1 {
            return MotivationCard(
                color: .orange,
                emoji: "🔥",
                title: "Jangan putus streak-mu!",
                message: "Streakmu masih bisa diselamatkan. Mulai plank sekarang sebelum hari ini berlalu."
            )
        } else if daysSinceLastSession < 4 {
            return MotivationCard(
                color: .red,
                emoji: "⚠️",
                title: "\(daysSinceLastSession) hari absen...",
                message: "Streakmu hampir putus. Mulai lagi sekarang — satu sesi sudah cukup untuk bangkit!"
            )
        } else {
            return MotivationCard(
                color: .red,
                emoji: "😤",
                title: "Saatnya bangkit lagi!",
                message: "Streak lama mungkin sudah putus, tapi hari ini adalah awal yang baru. Yuk mulai lagi!"
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        MotivationCardView(card: MotivationCard(
            color: .green,
            emoji: "💪",
            title: "1 hari lagi untuk streak sempurna!",
            message: "Kamu sudah plank 4 hari berturut-turut — badan mulai terbiasa. Jangan putus sekarang."
        ))
        MotivationCardView(card: MotivationCard(
            color: .orange,
            emoji: "🏆",
            title: "7 hari streak! Luar biasa.",
            message: "Kamu telah membangun kebiasaan kuat. Tubuhmu pasti sudah merasakan manfaatnya!"
        ))
        MotivationCardView(card: MotivationCard(
            color: .blue,
            emoji: "🚀",
            title: "Mulai perjalananmu hari ini.",
            message: "Satu menit plank sehari bisa mengubah segalanya. Konsistensi adalah kuncinya!"
        ))
    }
    .padding()
}
