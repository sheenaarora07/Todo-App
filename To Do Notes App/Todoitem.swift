//
//  Todoitem.swift
//  To Do Notes App
//
//  Created by Sheena on 31/01/22.
//

import Foundation
import RealmSwift

class Todoitem: Object {
    @objc dynamic var name: String = ""
//    @objc dynamic var date: Date = Date()
    @objc dynamic var done: Bool = false
    @objc dynamic  var id = 0
    
    override static func primaryKey() -> String? {
            return "id"
        }
    var items = List<Todoitem>()
    
}
