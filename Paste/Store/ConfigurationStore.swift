//
//  ConfigurationStore.swift
//  Paste
//
//  Created by Nicklas Roelfs on 23.09.26.
//


import SwiftData
import Observation
import Foundation
import TOMLKit

@MainActor
@Observable
final class ConfigurationStore {
    
    private let home = FileManager.default.homeDirectoryForCurrentUser
    
    private let folderUrl = ".config/apizzacomp"
    private let configPaste = "paste.toml"
    private let configShortCut = "shortcuts.toml"
    
    private let fileManager = FileManager.default
    
    var configDir : URL
    
    init() throws{
        configDir = home.appendingPathComponent(folderUrl)
        try load()
    }
    
    @discardableResult
    func load() throws -> Configuration{

        let pasteUrl = configDir.appendingPathComponent(configPaste)
        
        guard fileManager.fileExists(atPath: pasteUrl.path) else {
             let configuration = Configuration()

             try save(configuration)

             return configuration
         }
        

        let configuration = try loadPasteConfig(pasteUrl)

        try save(configuration)
        
        return try loadPasteConfig(pasteUrl)
    }
    
    private func createConfig<T: Codable>(
        configuration: T,
        folderUrl: URL,
        configName: String,
        encoding: String.Encoding = .utf8
    ) throws {
        try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        let fileUrl = folderUrl.appendingPathComponent(configName)
        let encodedString = try TOMLEncoder().encode(configuration)
        try encodedString.write(to: fileUrl, atomically: true, encoding: encoding)
    }
    

    
    private func loadPasteConfig(_ pasteUrl: URL) throws -> Configuration {

        var fileEncoding: String.Encoding = .utf8

        let fileContent = try String(contentsOf: pasteUrl, usedEncoding: &fileEncoding)

        return try TOMLDecoder().decode(Configuration.self,from: fileContent)
    }
    
    
    func save(_ configuration: Configuration) throws {
        let folderUrl = home.appendingPathComponent(".config/apizzacomp")
        try createConfig(configuration: configuration, folderUrl: folderUrl, configName: configPaste)
    }
}


