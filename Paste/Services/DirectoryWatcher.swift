//
//  DirectoryWatcher.swift
//  Paste
//
//  Created by Nicklas Roelfs on 26.09.26.
//
import CoreServices
import Foundation


final class DirectoryWatcher {
    private var stream: FSEventStreamRef?
    private let onChange: () -> Void

    init(path: String, onChange: @escaping () -> Void) {
        self.onChange = onChange

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { _, clientCallBackInfo, _, _, _, _ in
            guard let info = clientCallBackInfo else { return }
            let watcher = Unmanaged<DirectoryWatcher>.fromOpaque(info).takeUnretainedValue()
            watcher.onChange()
        }

        stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            [path] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.3, // Debounce-Latenz in Sekunden
            UInt32(kFSEventStreamCreateFlagFileEvents)
        )

        if let stream {
            FSEventStreamSetDispatchQueue(stream, .main)
        }
    }

    func start() {
        guard let stream else { return }
        FSEventStreamStart(stream)
    }

    func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
    }

    deinit {
        stop()
    }
}
