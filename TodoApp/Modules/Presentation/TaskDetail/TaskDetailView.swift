//
//  TaskDetailView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI

struct TaskDetailView: View {
    // @Bindable — для @Observable классов когда нужен двусторонний биндинг ($item.title)
    // Используй когда View редактирует свойства модели напрямую
    @Bindable var item: TaskItem

    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""

    let viewModel: TaskListViewModel

    @Environment(\.dismiss) private var dismiss  // аналог router.close()

    var body: some View {
        Form {
            Section("Название") {
                if isEditing {
                    TextField("Название", text: $editedTitle)
                } else {
                    Text(item.title)
                }
            }

            Section("Описание") {
                if isEditing {
                    TextField("Описание (необязательно)",
                              text: Binding(
                                get: { editedDescription },
                                set: { editedDescription = $0 }
                              ),
                              axis: .vertical   // многострочный TextField, iOS 16+
                    )
                    .lineLimit(3...6)
                } else {
                    Text(item.taskDescription ?? "Нет описания")
                        .foregroundStyle(item.taskDescription == nil ? .secondary : .primary)
                }
            }

            Section {
                LabeledContent("Дата создания") {
                    Text(item.createdDate.formatted(date: .long, time: .omitted))
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Статус") {
                    Text(item.isCompleted ? "Выполнено ✅" : "В процессе ⏳")
                }
            }
        }
        .navigationTitle(isEditing ? "Редактирование" : "Задача")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Готово" : "Редактировать") {
                    if isEditing { saveChanges() } else { startEditing() }
                }
                .fontWeight(isEditing ? .semibold : .regular)
                .foregroundStyle(.yellow)
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { cancelEditing() }
                }
            }
        }
    }

    private func startEditing() {
        editedTitle = item.title
        editedDescription = item.taskDescription ?? ""
        withAnimation { isEditing = true }
    }

    private func saveChanges() {
        item.title = editedTitle  // @Model — просто присваиваем
        item.taskDescription = editedDescription.isEmpty ? nil : editedDescription
        Task { await viewModel.updateItem(item) }
        withAnimation { isEditing = false }
    }

    private func cancelEditing() {
        withAnimation { isEditing = false }
    }
}
