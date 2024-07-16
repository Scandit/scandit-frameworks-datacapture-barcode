/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksBarcodeTrackingEvent: String, CaseIterable {
    case sessionUpdated = "BarcodeTrackingListener.didUpdateSession"
    case brushForTrackedBarcode = "BarcodeTrackingBasicOverlayListener.brushForTrackedBarcode"
    case didTapOnTrackedBarcode = "BarcodeTrackingBasicOverlayListener.didTapTrackedBarcode"
    case offsetForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.offsetForTrackedBarcode"
    case anchorForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.anchorForTrackedBarcode"
    case widgetForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.viewForTrackedBarcode"
    case didTapViewForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.didTapViewForTrackedBarcode"
}

internal extension Event {
    init(_ event: FrameworksBarcodeTrackingEvent) {
        self.init(name: event.rawValue)
    }
}

internal extension Emitter {
    func hasListener(for event: FrameworksBarcodeTrackingEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

open class FrameworksBarcodeTrackingListener: NSObject, BarcodeTrackingListener {
    internal let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var latestSession: BarcodeTrackingSession?
    private var isEnabled = AtomicBool()

    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(.sessionUpdated))

    public func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                                didUpdate session: BarcodeTrackingSession,
                                frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: .sessionUpdated) else { return }
        latestSession = session

        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        sessionUpdatedEvent.emit(on: emitter,
                                                             payload: ["session": session.jsonString])
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

    public func getTrackedBarcodeFromLastSession(barcodeId: Int, sessionId: Int?) -> TrackedBarcode? {
        guard let session = latestSession, sessionId == nil || session.frameSequenceId == sessionId else {
            return nil
        }
        return session.trackedBarcodes[barcodeId]
    }
}
