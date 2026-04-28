import Foundation
import SwiftUI
import Combine

class SummaryViewModel: ObservableObject {
    @Published var dateString: String = ""
    @Published var qualityScore: Int = 0
    @Published var metrics: [SessionMetric] = []
    @Published var errors: [ErrorAnalysis] = []
    @Published var currentErrorIndex: Int = 0

    let result: SessionResult

    var duration: Int? { result.targetDuration }

    init(result: SessionResult) {
        self.result = result
        buildData()
    }

    private func buildData() {
        let totalSec = max(result.totalDisplaySeconds, 1)
        let strictSec = result.strictSeconds
        let badSec = max(0, totalSec - strictSec)

        dateString = formatDateString()
        qualityScore = result.qualityPercent

        metrics = [
            SessionMetric(
                type: .total,
                title: "Total Plank",
                subtitle: "Durasi keseluruhan sesi",
                valueString: formatSeconds(totalSec),
                value: totalSec,
                maxValue: max(totalSec, 60)
            ),
            SessionMetric(
                type: .perfect,
                title: "Perfect Form",
                subtitle: "Waktu posisi benar terdeteksi",
                valueString: formatSeconds(strictSec),
                value: strictSec,
                maxValue: totalSec
            ),
            SessionMetric(
                type: .incorrect,
                title: "Form Errors",
                subtitle: "Waktu posisi salah terdeteksi",
                valueString: formatSeconds(badSec),
                value: badSec,
                maxValue: totalSec
            )
        ]

        errors = buildErrorCards(from: result.mistakes)
    }

    private func buildErrorCards(from mistakes: [RecordedMistake]) -> [ErrorAnalysis] {
        var seen: Set<String> = []
        return mistakes.compactMap { mistake in
            guard !seen.contains(mistake.typeName),
                  let type = PlankFormMistakeType(rawValue: mistake.typeName)
            else { return nil }
            seen.insert(mistake.typeName)
            let min = mistake.sessionSecond / 60
            let sec = mistake.sessionSecond % 60
            let timestamp = String(format: "%02d:%02d", min, sec)
            let (title, desc, tip, img) = errorContent(for: type)
            return ErrorAnalysis(timestamp: timestamp, title: title, descriptionHTML: desc, tip: tip, imageName: img)
        }
    }

    private func errorContent(for type: PlankFormMistakeType) -> (String, String, String, String) {
        switch type {
        case .hipsTooLow:
            return ("Pinggul Rendah",
                    "Pinggul turun di bawah garis ideal. Kondisi ini membebani **lower back** dan mengurangi efektivitas latihan core.",
                    "Tips: Kontraksikan otot perut, dorong tumit ke belakang, bayangkan papan lurus di punggungmu.",
                    "Pinggul")
        case .hipsTooHigh:
            return ("Pinggul Tinggi",
                    "Pinggul terlalu tinggi sehingga tubuh membentuk huruf V. Posisi ini mengurangi keterlibatan otot core.",
                    "Tips: Turunkan pinggul perlahan hingga tubuh membentuk garis lurus dari kepala ke tumit.",
                    "Pinggul")
        case .kneeBent:
            return ("Lutut Bengkok",
                    "Lutut bengkok mengurangi beban pada otot inti dan melemahkan postur plank secara keseluruhan.",
                    "Tips: Luruskan lutut sepenuhnya dan dorong tumit ke belakang.",
                    "Lutut")
        case .headDropped:
            return ("Kepala Menunduk",
                    "Kepala menunduk. Jaga pandangan ke arah lantai agar leher sejajar dengan punggung.",
                    "Tips: Pandang lantai di antara kedua tangan untuk menjaga leher tetap netral.",
                    "Kepala")
        case .elbowMisaligned:
            return ("Siku Tidak Sejajar",
                    "Siku tidak sejajar bahu — perbaiki posisi lengan untuk mendapatkan stabilitas optimal.",
                    "Tips: Pastikan siku tepat di bawah bahu, lengan bawah sejajar dengan tubuh.",
                    "Siku")
        }
    }

    private func formatDateString() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "id_ID")
        df.dateFormat = "dd MMMM yyyy"
        let date = df.string(from: Date())
        if let d = result.targetDuration {
            return "\(date) · \(d) Detik"
        }
        return "\(date) · Free Time"
    }

    private func formatSeconds(_ seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)s" }
        let m = seconds / 60
        let s = seconds % 60
        return s > 0 ? "\(m)m \(s)s" : "\(m)m"
    }

    func finishSession() {
        // Session already saved by CameraViewModel on finalization.
        // Only schedule notifications here.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationManager.shared.scheduleDailyNotifications()
        }
    }
}
