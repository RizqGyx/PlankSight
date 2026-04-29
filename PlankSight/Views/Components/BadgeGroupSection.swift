import SwiftUI

struct BadgeGroupSection: View {
    let group: BadgeGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(group.label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textBody)
                Spacer()
                Text("\(group.obtainedCount)/\(group.badges.count)")
                    .font(.caption2)
                    .foregroundColor(.textCaption)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(group.badges) { badge in
                        BadgeItem(badge: badge)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }
}
