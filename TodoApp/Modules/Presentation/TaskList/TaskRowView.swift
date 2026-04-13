//
//  TaskRowView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI

struct TaskRowView: View {
    let item: TaskItem
    let onToggle: () -> Void   // замыкание вместо делегата

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Чекбокс
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCompleted ? .yellow : .secondary)
                    // .animation привязан к конкретному значению — перерисуется только чекбокс
                    .animation(.spring(duration: 0.2), value: item.isCompleted)
            }
            .buttonStyle(.plain)  // убирает highlight на весь Row при тапе на кнопку

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(.medium)
                    // strikethrough вместо NSAttributedString
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                if let desc = item.taskDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text(item.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskRowView(item: .mock(), onToggle: {})
        .padding()
}
