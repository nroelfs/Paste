// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  LifetimeService.swift
//  Paste
//
//  Created by Nicklas Roelfs on 04.10.26.
//

import Foundation

struct LifetimeEntry
{
    let id: UUID
    var expiresAt : Date
    let createdAt: Date
    
}

@MainActor
final class LifetimeService{
    
    private(set) var queue : [LifetimeEntry] = [ ]
    private(set) var lifeTimeConfiguration: ClipboardLifeTimeConfiguration
    
    private var lifetimeTask: Task<Void, Never>?
    private var wakeContinuation: CheckedContinuation<Void, Never>?
    private var sleepTask: Task<Void, Never>?
    
    var onEntryExpire: ((UUID) -> Void)?
    
    init(_ config: ClipboardLifeTimeConfiguration) { lifeTimeConfiguration = config }
    
    
    private func sleep(for duration: TimeInterval) async {
        do {
            try await Task.sleep( for: .seconds(duration) )
        } catch {
            print("task stopped")
            // Task wurde beendet.
        }
    }
    
    private func waitForWakeUp() async {
        await withCheckedContinuation{ continuation in
            wakeContinuation = continuation
        }
    }
    
    private func wakeWorker() {
        wakeContinuation?.resume()
        wakeContinuation = nil
    }
    
    private func sortQueue() {
        queue.sort{$0.expiresAt < $1.expiresAt}
    }
    
    private func expireEntries() {
        let now = Date()
        let expired = queue.prefix { $0.expiresAt <= now }
        for entry in expired {
            onEntryExpire?(entry.id)
        }
        if queue.count >= expired.count {
            queue.removeFirst(expired.count)
        }
        else if queue.count < expired.count {
            queue.removeAll()
        }
    }
    
    func schedule(id: UUID, createdAt: Date) {
        let expiresAt = lifeTimeConfiguration.expirationDate( from: createdAt )!
        queue.append( LifetimeEntry( id: id, expiresAt: expiresAt, createdAt: createdAt ) )
        sortQueue()
        wakeWorker()
    }
    
    func remove(id: UUID){
        queue.removeAll { $0.id == id }
        wakeWorker()
    }
    
    func updateConfig(_ config: ClipboardLifeTimeConfiguration) {
        lifeTimeConfiguration = config
        for index in queue.indices {
            queue[index].expiresAt = config.expirationDate( from: queue[index].createdAt )!
        }
        sortQueue()
        wakeWorker()
        sleepTask?.cancel()
    }
    
    private func run() async {
        while !Task.isCancelled {
            guard let next = queue.first else {
                await waitForWakeUp()
                continue
            }
            let duration = next.expiresAt.timeIntervalSinceNow
            
            if duration <= 0 {
                expireEntries()
                continue
            }
            
            sleepTask = Task {
                try? await Task.sleep(for: .seconds(duration))
            }

            await sleepTask?.value
            sleepTask = nil

        }
    }
    
    func start(onEntryExpire: @escaping (UUID) -> Void) {
        self.onEntryExpire = onEntryExpire
        guard lifetimeTask == nil else { return }
        lifetimeTask = Task { [weak self] in
            guard let self else { return }
            await run()
        }
    }
    
    func stop() {
        lifetimeTask?.cancel()
        lifetimeTask = nil
        wakeWorker()
    }
}
