//
//  Configuration.swift
//  Paste
//
//  Created by Nicklas Roelfs on 23.09.26.
//
import TOMLKit

struct Configuration : Codable{
    
    // ##############
    // #   Props    #
    // ##############
    var general : GeneralConfiguration = GeneralConfiguration()
    var clipboardLifeTime : ClipboardLifeTimeConfiguration = ClipboardLifeTimeConfiguration()
    
    // #############
    // #   Ctor    #
    // #############
    init(){}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.clipboardLifeTime = 
            try container.decodeIfPresent(
                ClipboardLifeTimeConfiguration.self,
                forKey: .clipboardLifeTime
            ) ?? ClipboardLifeTimeConfiguration()

        self.general =
            try container.decodeIfPresent(
                GeneralConfiguration.self,
                forKey: .general
            ) ?? GeneralConfiguration()

    }
    
    enum CodingKeys: String, CodingKey {
        case general
        case clipboardLifeTime
    }
}

extension Configuration: Equatable {
    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        lhs.general == rhs.general &&
        lhs.clipboardLifeTime == rhs.clipboardLifeTime
    }
}



