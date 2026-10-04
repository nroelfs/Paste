//
//  ConfigLoader.swift
//  Paste
//
//  Created by Nicklas Roelfs on 27.09.26.
//
import ServiceManagement

final class ConfigLoader{
    static func Load(_ conf: Configuration, store: ClipboardStore, lifetimeService: LifetimeService) throws {
        try handleGeneral(conf.general, store: store)
        try lifetimeUpdate(conf: conf.clipboardLifeTime, service: lifetimeService)
    }
    
    private static func handleGeneral(_ conf: GeneralConfiguration, store: ClipboardStore) throws{
        if store.clipboard.capacity != conf.capacity {
            store.clipboard.updateCapacity(newCapacity: conf.capacity)
        }
        try autostartCheck(conf: conf)
        
    }
    
    private static func autostartCheck(conf: GeneralConfiguration) throws{
        let status = SMAppService.mainApp.status
        switch status{
        case .enabled:
            if !conf.autostart { try SMAppService.mainApp.unregister()}
            break
        case .notRegistered, .notFound:
            if conf.autostart { try SMAppService.mainApp.register() }
            break
        case .requiresApproval:
            print("Benutzer muss den Login-Item-Eintrag bestätigen")
            break
        @unknown default:
            break;
        }
    }
    
    private static func lifetimeUpdate (conf: ClipboardLifeTimeConfiguration, service: LifetimeService) throws {
        service.updateConfig(conf)
    }
}
