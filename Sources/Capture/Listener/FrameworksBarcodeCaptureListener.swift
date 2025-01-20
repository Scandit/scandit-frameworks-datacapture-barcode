/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksBarcodeCaptureEvent: String, CaseIterable {
    case barcodeScanned = "BarcodeCaptureListener.didScan"
    case sessionUpdated = "BarcodeCaptureListener.didUpdateSession"
}

fileprivate extension Event {
    init(_ event: FrameworksBarcodeCaptureEvent) {
        self.init(name: event.rawValue)
    }
}

fileprivate extension Emitter {
    func hasListener(for event: FrameworksBarcodeCaptureEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

open class FrameworksBarcodeCaptureListener: NSObject, BarcodeCaptureListener {
    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2

    private let emitter: Emitter

    private var latestSession: BarcodeCaptureSession?
    private var isEnabled = AtomicBool()
    private let barcodeScannedEvent = EventWithResult<Bool>(event: Event(FrameworksBarcodeCaptureEvent.barcodeScanned))
    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(FrameworksBarcodeCaptureEvent.sessionUpdated))

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: .barcodeScanned) else { return }
        latestSession = session

        let frameId = LastFrameData.shared.addToCache(frameData: frameData)

        barcodeScannedEvent.emit(
            on: emitter,
            payload: [
                "session": session.jsonString,
                "frameId": frameId
            ]
        )
        
        LastFrameData.shared.removeFromCache(frameId: frameId)
    }

    public func finishDidScan(enabled: Bool) {
        barcodeScannedEvent.unlock(value: enabled)
    }

    public func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didUpdate session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: FrameworksBarcodeCaptureEvent.sessionUpdated) else { return }
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
        guard let session = latestSession, frameSequenceId == nil || session.frameSequenceId == frameSequenceId else {
            return
        }
        session.reset()
    }

    public func clearCache() {
        latestSession = nil
    }

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
        latestSession = nil
        barcodeScannedEvent.reset()
        sessionUpdatedEvent.reset()
    }
    
    public func enableAsync() {
        [barcodeScannedEvent, sessionUpdatedEvent].forEach {
            $0.timeout = Self.asyncTimeoutInterval
        }
        enable()
    }

    public func disableAsync() {
        disable()
        [barcodeScannedEvent, sessionUpdatedEvent].forEach {
            $0.timeout = Self.defaultTimeoutInterval
        }
    }
}
