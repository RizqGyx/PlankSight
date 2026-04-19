//
//  CustomDurationModalView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 19/04/26.
//

import SwiftUI

struct CustomDurationModalView: View {
    @Environment(\.dismiss) var dismiss
    
    // Callback or binding to pass back the custom duration in seconds
    var onSave: (Int) -> Void
    
    @State private var inputHours: Int = 0
    @State private var inputMinutes: Int = 0
    @State private var inputSeconds: Int = 0
    
    var totalComputedSeconds: Int {
        return (inputHours * 3600) + (inputMinutes * 60) + inputSeconds
    }
    
    var computedLabel: String {
        let t = totalComputedSeconds
        if t == 0 { return "0 dtk" }
        let h = t / 3600
        let m = (t % 3600) / 60
        let s = t % 60
        
        var parts: [String] = []
        if h > 0 { parts.append("\(h) jam") }
        if m > 0 { parts.append("\(m) mnt") }
        if s > 0 { parts.append("\(s) dtk") }
        
        return parts.joined(separator: " ")
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    // HIG Caption 2: 11pt Semibold
                    Text("DURASI CUSTOM")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                    
                    // HIG Title 1: 28pt Bold
                    Text("Atur waktumu")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    // HIG Footnote: 13pt Regular
                    Text("Masukkan jam, menit, dan detik sesuai targetmu")
                        .font(.footnote)
                        .foregroundColor(.textCaption)
                }
                .padding(.top, 24)
                
                // Wheel Pickers
                HStack(spacing: 4) {
                    // Jam Column
                    VStack(spacing: 8) {
                        // HIG Caption 2: 11pt Semibold
                        Text("JAM")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textCaption)
                        
                        Picker("Jam", selection: $inputHours) {
                            ForEach(0..<24) { i in
                                Text(String(format: "%02d", i)).tag(i)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 140)
                        .background(Color.bgInput)
                        .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(":")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.textCaption)
                        .padding(.top, 24)
                    
                    // Menit Column
                    VStack(spacing: 8) {
                        // HIG Caption 2: 11pt Semibold
                        Text("MENIT")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textCaption)
                        
                        Picker("Menit", selection: $inputMinutes) {
                            ForEach(0..<60) { i in
                                Text(String(format: "%02d", i)).tag(i)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 140)
                        .background(Color.bgInput)
                        .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(":")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.textCaption)
                        .padding(.top, 24)
                    
                    // Detik Column
                    VStack(spacing: 8) {
                        // HIG Caption 2: 11pt Semibold
                        Text("DETIK")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.5)
                            .foregroundColor(.textCaption)
                        
                        Picker("Detik", selection: $inputSeconds) {
                            ForEach(0..<60) { i in
                                Text(String(format: "%02d", i)).tag(i)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 140)
                        .background(Color.bgInput)
                        .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Selection Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // HIG Caption 2: 11pt Semibold
                        Text("DURASI YANG DIPILIH")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textCaption)
                        // HIG Title 3: 20pt Semibold
                        Text(computedLabel)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    // HIG Caption 2: 11pt Semibold
                    Text("\(totalComputedSeconds) dtk")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.brandBg)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandBorder, lineWidth: 1))
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderMain, lineWidth: 1))
                .padding(.top, 16)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    SecondaryButton(title: "Batal") {
                        dismiss()
                    }
                    
                    PrimaryButton(title: "Pakai Durasi Ini", iconName: "checkmark") {
                        onSave(totalComputedSeconds)
                        dismiss()
                    }
                    .disabled(totalComputedSeconds == 0)
                    .opacity(totalComputedSeconds == 0 ? 0.5 : 1)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    CustomDurationModalView(onSave: { _ in })
}
