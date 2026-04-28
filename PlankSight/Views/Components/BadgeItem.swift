//
//  BadgeItem.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 27/04/26.
//

import SwiftUI

// MARK: - Badge Item

struct BadgeItem: View {
    let badge: AchievementBadge

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                ZStack{
                    Circle()
                        .fill(badge.isObtained ? badge.color.opacity(0.15) : Color.textMuted.opacity(0.18))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    badge.isObtained ? badge.color.opacity(0.4) : Color.textMuted.opacity(0.35),
                                    lineWidth: 1.5
                                )
                        )

                    Image(systemName: badge.icon)
                        .font(.system(size: 22))
                        .foregroundColor(badge.isObtained ? badge.color : Color.textMuted.opacity(0.5))
                }

                if !badge.isObtained {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.textMuted.opacity(0.6))
                        .padding(3)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .offset(x: 2, y: 2)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(3)
                        .background(badge.color)
                        .clipShape(Circle())
                        .offset(x: 2, y: 2)
                }
            }

            Text(badge.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(badge.isObtained ? .textPrimary : .textMuted.opacity(0.65))
                .multilineTextAlignment(.center)
                .frame(width: 62)
                .lineLimit(2)
        }
    }
}
