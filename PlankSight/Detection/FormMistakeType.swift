import Foundation

enum PlankFormMistakeType: String, CaseIterable, Hashable, Identifiable {
    case hipsTooLow
    case hipsTooHigh
    case kneeBent
    case headDropped
    case elbowMisaligned

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .hipsTooLow: return "Pinggul terlalu rendah"
        case .hipsTooHigh: return "Pinggul terlalu tinggi"
        case .kneeBent: return "Lutut bengkok"
        case .headDropped: return "Kepala menunduk"
        case .elbowMisaligned: return "Siku tidak sejajar bahu"
        }
    }

    var priorityRank: Int {
        switch self {
        case .hipsTooLow, .hipsTooHigh: return 1
        case .kneeBent: return 2
        case .headDropped: return 3
        case .elbowMisaligned: return 4
        }
    }

    var coachingInstruction: String {
        switch self {
        case .hipsTooLow: return "Angkat pinggul dan jaga tubuh dalam satu garis lurus"
        case .hipsTooHigh: return "Turunkan pinggul sedikit dan kencangkan otot inti"
        case .kneeBent: return "Luruskan lutut dan dorong tumit ke belakang"
        case .headDropped: return "Jaga leher netral dan pandang ke bawah"
        case .elbowMisaligned: return "Letakkan siku tepat di bawah bahu"
        }
    }

    // (partName, errorMessage) aligned with TrackedBodyPart names in CameraViewModel
    var bodyPartMapping: (partName: String, errorMessage: String) {
        switch self {
        case .hipsTooLow:      return ("Pinggul", "Terlalu rendah")
        case .hipsTooHigh:     return ("Pinggul", "Terlalu tinggi")
        case .kneeBent:        return ("Lutut", "Lutut bengkok")
        case .headDropped:     return ("Kepala", "Kepala menunduk")
        case .elbowMisaligned: return ("Bahu", "Siku tidak sejajar")
        }
    }
}
