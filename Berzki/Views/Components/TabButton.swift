//
//  TabButton.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .textPrimary : .textCaption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.bgPrimary : Color.clear)
                .cornerRadius(10)
                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = PanduanViewModel()
    
    HStack(spacing: 0) {
        TabButton(title: "Panduan App", isSelected: viewModel.selectedTab == 0) {
            viewModel.setTab(0)
        }
        TabButton(title: "Panduan Plank", isSelected: viewModel.selectedTab == 1) {
            viewModel.setTab(1)
        }
    }
}
