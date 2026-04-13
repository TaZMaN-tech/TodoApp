//
//  Int+Tasks.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

extension Int {
    // Это та самая русская плюрализация из BottomBarView — теперь переиспользуемая
    var taskCountString: String {
        let mod100 = self % 100
        if (11...14).contains(mod100) { return "\(self) задач" }
        switch self % 10 {
        case 1: return "\(self) задача"
        case 2, 3, 4: return "\(self) задачи"
        default: return "\(self) задач"
        }
    }
}
