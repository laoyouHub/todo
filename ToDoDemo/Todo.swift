//
//  Todo.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
class Todo: Codable {
    var id: UInt?
    var title: String
    var completed: Bool

    init(id: UInt, title: String, completed: Bool) {
        self.id = id
        self.title = title
        self.completed = completed
    }
    
    required init?(json: [String: Any]) {
        guard let todoId = json["id"] as? UInt,
            let title = json["title"] as? String,
            let completed = json["completed"] as? Bool else {
            return nil
        }

        self.id = todoId
        self.title = title
        self.completed = completed
    }
}
/// 为了方便调试，我们让它遵从了CustomStringConvertible，它把Todo的所有属性放在一行上，返回了一个字符串对象；
extension Todo: CustomStringConvertible {
    var description: String {
        return "ID: \(self.id ?? 0), " +
                "title: \(self.title), " +
                "completed: \(self.completed)"
    }
}
