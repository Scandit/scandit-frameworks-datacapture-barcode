/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksBarcodeBatchEvent: String, CaseIterable {
    case sessionUpdated = "BarcodeBatchListener.didUpdateSession"
    case brushForTrackedBarcode = "BarcodeBatchBasicOverlayListener.brushForTrackedBarcode"
    case didTapOnTrackedBarcode = "BarcodeBatchBasicOverlayListener.didTapTrackedBarcode"
    case offsetForTrackedBarcode = "BarcodeBatchAdvancedOverlayListener.offsetForTrackedBarcode"
    case anchorForTrackedBarcode = "BarcodeBatchAdvancedOverlayListener.anchorForTrackedBarcode"
    case widgetForTrackedBarcode = "BarcodeBatchAdvancedOverlayListener.viewForTrackedBarcode"
    case didTapViewForTrackedBarcode = "BarcodeBatchAdvancedOverlayListener.didTapViewForTrackedBarcode"
}

internal extension Event {
    init(_ event: FrameworksBarcodeBatchEvent) {
        self.init(name: event.rawValue)
    }
}

internal extension Emitter {
    func hasListener(for event: FrameworksBarcodeBatchEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

open class FrameworksBarcodeBatchListener: NSObject, BarcodeBatchListener {
    internal let emitter: Emitter

    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var latestSession: BarcodeBatchSession?
    private var isEnabled = AtomicBool()

    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(.sessionUpdated))

    public func barcodeBatch(_ barcodeBatch: BarcodeBatch,
                                didUpdate session: BarcodeBatchSession,
                                frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: .sessionUpdated) else { return }
        latestSession = session

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

    public func finishDidUpdateSession(enabled: Bool) {
        sessionUpdatedEvent.unlock(value: enabled)
    }

    public func resetSession(with frameSequenceId: Int?) {
        guard
            let session = latestSession,
            frameSequenceId == nil || session.frameSequenceId == frameSequenceId else { return }
        session.reset()
    }

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
        latestSession = nil
        sessionUpdatedEvent.reset()
    }

    public func enableAsync() {
        sessionUpdatedEvent.timeout = Self.asyncTimeoutInterval
        enable()
    }

    public func disableAsync() {
        disable()
        sessionUpdatedEvent.timeout = Self.defaultTimeoutInterval
    }

    public func getTrackedBarcodeFromLastSession(barcodeId: Int, sessionId: Int?) -> TrackedBarcode? {
        guard let session = latestSession, sessionId == nil || session.frameSequenceId == sessionId else {
            return nil
        }
        return session.trackedBarcodes[barcodeId]
    }
}
