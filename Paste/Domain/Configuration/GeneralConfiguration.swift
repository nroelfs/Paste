// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  General.swift
//  Paste
//
//  Created by Nicklas Roelfs on 27.09.26.
//

struct GeneralConfiguration : Codable {
    
    // ##############
    // #   Props    #
    // ##############
    var capacity : Int = 10
    var autostart : Bool = false
    
    // #############
    // #   Ctor    #
    // #############
    init(){}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

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
    }
}

extension GeneralConfiguration: Equatable {
    static func == (lhs: GeneralConfiguration, rhs: GeneralConfiguration) -> Bool {
        lhs.capacity == rhs.capacity &&
        lhs.autostart == rhs.autostart
    }
}
