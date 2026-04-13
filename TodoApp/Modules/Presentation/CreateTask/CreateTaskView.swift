//
//  CreateTaskView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI

struct CreateTaskView: View {
    @State private var title = ""
    @State private var description = ""
    @Environment(\.dismiss) private var dismiss

    let viewModel: TaskListViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Название задачи") {
                    TextField("Обязательное поле", text: $title)
                }
                Section("Описание") {
                    TextField("Необязательно", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        Task {
                            await viewModel.createTask(
                                title: title,
                                description: description.isEmpty ? nil : description
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
