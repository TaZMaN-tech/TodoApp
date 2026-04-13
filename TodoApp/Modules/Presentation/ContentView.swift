//
//  ContentView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI

struct ContentView: View {

    // Получаем DI контейнер из environment — он создан один раз в App
    @Environment(AppDependencies.self) private var deps

    // @State гарантирует что ViewModel создаётся ОДИН РАЗ
    // и НЕ пересоздаётся при перерисовке ContentView
    @State private var viewModel: TaskListViewModel?

    var body: some View {
        if let viewModel {
            TaskListView(viewModel: viewModel)
        } else {
            ProgressView()
                .onAppear {
                    // onAppear вызывается один раз при появлении View
                    // Здесь безопасно создавать ViewModel через DI
                    viewModel = deps.makeTaskListViewModel()
                }
        }
    }
}
