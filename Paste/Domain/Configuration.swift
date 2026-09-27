//
//  Configuration.swift
//  Paste
//
//  Created by Nicklas Roelfs on 23.09.26.
//

struct Configuration : Codable{
    var capacity : Int = 10
    var autostart : Bool = false
}

extension Configuration: Equatable {
    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        lhs.capacity == rhs.capacity &&
        lhs.autostart == rhs.autostart
    }
}
