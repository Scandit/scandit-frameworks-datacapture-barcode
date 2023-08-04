/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksBarcodeCountListener: NSObject, BarcodeCountListener {
    private enum Constants {
        static let barcodeScanned = "BarcodeCountListener.onScan"
    }

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

    public func barcodeCount(_ barcodeCount: BarcodeCount,
                             didScanIn session: BarcodeCountSession,
                             frameData: FrameData) {
        guard isEnabled.value, emitter.hasListener(for: Constants.barcodeScanned) else { return }
        lastSession = session
        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeScannedEvent.emit(on: emitter,
                                 payload: ["session": session.jsonString],
                                 default: barcodeCount.isEnabled)
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
}
