/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksBarcodeTrackingListener: NSObject, BarcodeTrackingListener {
    private enum Constants {
        static let sessionUpdated = "BarcodeTrackingListener.didUpdateSession"
    }

    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var latestSession: BarcodeTrackingSession?
    private var isEnabled = AtomicBool()

    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(name: Constants.sessionUpdated))

    public func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                                didUpdate session: BarcodeTrackingSession,
                                frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: Constants.sessionUpdated) else { return }
        latestSession = session

        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeTracking.isEnabled = sessionUpdatedEvent.emit(on: emitter,
                                                             payload: ["session": session.jsonString]) ?? barcodeTracking.isEnabled
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

    func getTrackedBarcodeFromLastSession(barcodeId: Int, sessionId: Int?) -> TrackedBarcode? {
        guard let session = latestSession, sessionId == nil || session.frameSequenceId == sessionId else {
            return nil
        }
        return session.trackedBarcodes[NSNumber(value: barcodeId)]
    }
}
