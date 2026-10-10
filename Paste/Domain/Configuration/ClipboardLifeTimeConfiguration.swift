//
//  ClipboardLifetime.swift
//  Paste
//
//  Created by Nicklas Roelfs on 27.09.26.
//

import Foundation

struct ClipboardLifeTimeConfiguration : Codable {
    
    // ##############
    // #   Props    #
    // ##############
    var timespan : Int = 36
    var kind : ClipboardLifetimeKind = .hours
    
    // #############
    // #   Ctor    #
    // #############
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

extension ClipboardLifeTimeConfiguration: Equatable {
    static func ==(lhs: ClipboardLifeTimeConfiguration, rhs: ClipboardLifeTimeConfiguration) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.timespan == lhs.timespan
    }
}

extension ClipboardLifeTimeConfiguration {
    func expirationDate(from date: Date = Date()) -> Date? {
        let component: Calendar.Component
        switch kind {
        case .seconds: component = .second
        case .minutes: component = .minute
        case .hours:   component = .hour

        }
        return Calendar.current.date(byAdding: component, value: timespan, to: date)
    }
}
