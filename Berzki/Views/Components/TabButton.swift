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
            // HIG Caption 1: 12pt Semibold (segmented control)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .textPrimary : .textCaption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isSelected ? Color.bgPressed : Color.clear)
                .cornerRadius(7)
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
