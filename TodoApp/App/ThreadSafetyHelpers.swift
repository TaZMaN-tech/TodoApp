//
//  ThreadSafetyHelpers.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

enum ThreadSafetyHelpers {
    
    static func assertMainThread(file: String = #file, line: Int = #line) {
        assert(Thread.isMainThread, "❌ Этот код должен выполняться на main thread! \(file):\(line)")
    }
    
    static func ensureMainThread(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
}
