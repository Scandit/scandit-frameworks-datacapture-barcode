/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class FrameworksBarcodeCountListener: NSObject, BarcodeCountListener {
    public enum Constants {
        public static let barcodeScanned = "BarcodeCountListener.onScan"
    }
    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2
    private let emitter: Emitter
    private let barcodeScannedEvent = EventWithResult<Bool>(event: Event(name: Constants.barcodeScanned))

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicBool()
    private var lastSession: BarcodeCountSession?

    func enable() {
        isEnabled.value = true
    }

    func disable() {
        isEnabled.value = false
        barcodeScannedEvent.reset()
        lastSession = nil
    }
    
    public func enableAsync() {
        barcodeScannedEvent.timeout = Self.asyncTimeoutInterval
        enable()
    }

    public func disableAsync() {
        disable()
        barcodeScannedEvent.timeout = Self.defaultTimeoutInterval
    }

    public func barcodeCount(_ barcodeCount: BarcodeCount,
                             didScanIn session: BarcodeCountSession,
                             frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: Constants.barcodeScanned) else { return }
        lastSession = session
        
        let frameId = LastFrameData.shared.addToCache(frameData: frameData)

        barcodeScannedEvent.emit(
            on: emitter,
            payload: [
                "session": session.jsonString,
                "frameId": frameId,
            ],
            default: barcodeCount.isEnabled
        )
        
        LastFrameData.shared.removeFromCache(frameId: frameId)
    }

    func finishDidScan(enabled: Bool) {
        barcodeScannedEvent.unlock(value: enabled)
    }

    func resetSession(frameSequenceId: Int?) {
        guard let session = lastSession else { return }
        if frameSequenceId == nil || session.frameSequenceId == frameSequenceId {
            session.reset()
        }
    }

    func getSpatialMap() -> BarcodeSpatialGrid? {
        guard let session = lastSession else { return nil }
        return session.spatialMap()
    }

    func getSpatialMap(expectedNumberOfRows: Int, expectedNumberOfColumns: Int) -> BarcodeSpatialGrid? {
        guard let session = lastSession else { return nil }
        return session.spatialMap(withExpectedNumberOfRows: expectedNumberOfRows, expectedNumberOfColumns: expectedNumberOfColumns)
    }

}
