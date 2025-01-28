/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodeCheckListenerEvents: String, CaseIterable {
    case didUpdateSession = "BarcodeCheckListener.didUpdateSession"
}

fileprivate extension Event {
    init(_ event: BarcodeCheckListenerEvents) {
        self.init(name: event.rawValue)
    }
}

fileprivate extension Emitter {
    func hasListener(for event: BarcodeCheckListenerEvents) -> Bool {
        hasListener(for: event.rawValue)
    }
}

open class FrameworksBarcodeCheckListener: NSObject, BarcodeCheckListener {
    private let emitter: Emitter
    private var isEnabled = AtomicBool()

    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(.didUpdateSession))

    private var latestSession: BarcodeCheckSession?

    private let cache: BarcodeCheckAugmentationsCache

    public init(emitter: Emitter, cache: BarcodeCheckAugmentationsCache) {
        self.emitter = emitter
        self.cache = cache
    }

    public func enable() {
        if isEnabled.value { return }
        isEnabled.value = true
    }

    public func disable() {
        guard isEnabled.value else { return }
        isEnabled.value = false
    }

    public func barcodeCheck(
        _ barcodeCheck: BarcodeCheck, didUpdate session: BarcodeCheckSession, frameData: any FrameData
    ) {
        guard isEnabled.value, emitter.hasListener(for: .sessionUpdated) else { return }
        latestSession = session
        cache.updateFromSession(session)

        let frameId = LastFrameData.shared.addToCache(frameData: frameData)

        sessionUpdatedEvent.emit(
            on: emitter,
            payload: [
                "session": session.jsonString,
                "frameId": frameId
            ]
        )

        LastFrameData.shared.removeFromCache(frameId: frameId)
    }

    public func finishDidUpdateSession() {
        sessionUpdatedEvent.unlock(value: true)
    }

    public func resetSession() {
        latestSession?.reset()
    }
}
