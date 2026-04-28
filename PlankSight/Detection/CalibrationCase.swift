import Foundation

enum PlankCalibrationCase: String, CaseIterable {
    case landscapeTiltLeftPlankLeft
    case portraitPlankLeft
    case portraitPlankRight
    case landscapeTiltRightPlankRight

    var shortLabel: String {
        switch self {
        case .landscapeTiltLeftPlankLeft: return "LS-L"
        case .portraitPlankLeft: return "P-L"
        case .portraitPlankRight: return "P-R"
        case .landscapeTiltRightPlankRight: return "LS-R"
        }
    }
}
