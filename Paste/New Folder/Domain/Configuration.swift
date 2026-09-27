//
//  Configuration.swift
//  Paste
//
//  Created by Nicklas Roelfs on 23.09.26.
//
import TOMLKit

enum ClipboardLifetimeKind: String, Codable {
    case hours
    case minutes
    case seconds
}

struct ClipboardLifeTime : Codable {
    var timespan : Int = 36
    var kind : ClipboardLifetimeKind = .hours
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        self.timespan = try container.decodeIfPresent(
            Int.self,
            forKey: .timespan
        ) ?? 36

        self.kind = try container.decodeIfPresent(
            ClipboardLifetimeKind.self,
            forKey: .kind
        ) ?? .hours
    }
    
    enum CodingKeys: String, CodingKey {
        case timespan = "timespan"
        case kind = "kind"
    }
    
}

struct Configuration : Codable{
    
    var capacity : Int = 10
    var autostart : Bool = false
    var clipboardLifeTime : ClipboardLifeTime = ClipboardLifeTime()
    
    init(){}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.clipboardLifeTime =
            try container.decodeIfPresent(
                ClipboardLifeTime.self,
                forKey: .clipboardLifeTime
            ) ?? ClipboardLifeTime()

        self.capacity =
            try container.decodeIfPresent(
                Int.self,
                forKey: .capacity
            ) ?? 10
        
        self.autostart =
        try container.decodeIfPresent(
            Bool.self,
            forKey: .autostart
            ) ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case capacity
        case autostart
        case clipboardLifeTime
    }
}

extension Configuration: Equatable {
    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        lhs.capacity == rhs.capacity &&
        lhs.autostart == rhs.autostart &&
        lhs.clipboardLifeTime == rhs.clipboardLifeTime
    }
}


extension ClipboardLifeTime: Equatable {
    static func ==(lhs: ClipboardLifeTime, rhs: ClipboardLifeTime) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.timespan == lhs.timespan
    }
}
