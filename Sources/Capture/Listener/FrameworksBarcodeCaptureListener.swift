/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksBarcodeCaptureListener: NSObject, BarcodeCaptureListener {
    private enum Constants {
        static let barcodeScanned = "BarcodeCaptureListener.didScan"
        static let sessionUpdated = "BarcodeCaptureListener.didUpdateSession"
    }

    private let emitter: Emitter

    private var latestSession: BarcodeCaptureSession?
    private var isEnabled = AtomicBool()
    private let barcodeScannedEvent = EventWithResult<Bool>(event: Event(name: Constants.barcodeScanned))
    private let sessionUpdatedEvent = EventWithResult<Bool>(event: Event(name: Constants.sessionUpdated))

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: Constants.barcodeScanned) else { return }
        latestSession = session

        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeCapture.isEnabled = barcodeScannedEvent.emit(on: emitter,
                                                            payload: ["session": session.jsonString]) ?? barcodeCapture.isEnabled
    }

    public func finishDidScan(enabled: Bool) {
        barcodeScannedEvent.unlock(value: enabled)
    }

    public func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didUpdate session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: Constants.sessionUpdated) else { return }
        latestSession = session

        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeCapture.isEnabled = sessionUpdatedEvent.emit(on: emitter,
                                                            payload: ["session": session.jsonString]) ?? barcodeCapture.isEnabled
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
}
