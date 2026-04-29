import SwiftUI

struct SectionCard: View {
    let section: HistorySection
    @Binding var isEditing: Bool
    var onTapItem: ((SessionHistory) -> Void)? = nil
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(section.header)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundColor(.textCaption)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bgInput)

            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 0) {
                        if isEditing {
                            Image(systemName: viewModel.selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.brand)
                                .padding(.trailing, 12)
                                .padding(.leading, 8)
                                .onTapGesture {
                                    viewModel.toggleSelection(for: item.id)
                                }
                        }

                        Button(action: {
                            if !isEditing { onTapItem?(item) }
                        }) {
                            HistoryItemCard(item: item)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isEditing)
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            viewModel.deleteItems(ids: [item.id])
                        }) {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }

                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.borderMain)
                            .padding(.leading, isEditing ? 56 : 82)
                    }
                }
            }
            .background(Color.bgPrimary)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}
