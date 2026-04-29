import Foundation
import Combine

class PanduanViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var currentPage = 0
    @Published var dontShowAgain: Bool = UserDefaults.standard.bool(forKey: "skipPanduan")

    func setTab(_ index: Int) {
        selectedTab = index
        currentPage = 0
    }
}
