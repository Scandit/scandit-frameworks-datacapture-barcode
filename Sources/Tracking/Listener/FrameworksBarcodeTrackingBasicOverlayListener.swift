/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksBarcodeTrackingBasicOverlayListener: NSObject, BarcodeTrackingBasicOverlayDelegate {
    private enum Constants {
        static let brushForTrackedBarcode = "BarcodeTrackingBasicOverlayListener.brushForTrackedBarcode"
        static let didTapOnTrackedBarcode = "BarcodeTrackingBasicOverlayListener.didTapTrackedBarcode"
    }

    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicBool()

    private let brushForTrackedBarcodeEvent = Event(name: Constants.brushForTrackedBarcode)
    private let didTapOnTrackedBarcodeEvent = Event(name: Constants.didTapOnTrackedBarcode)

    public func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                            brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        guard isEnabled.value, emitter.hasListener(for: brushForTrackedBarcodeEvent) else { return nil }
        brushForTrackedBarcodeEvent.emit(on: emitter,
                                         payload: ["trackedBarcode": trackedBarcode.jsonString])
        return nil
    }

    public func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                            didTap trackedBarcode: TrackedBarcode) {
        guard isEnabled.value, emitter.hasListener(for: didTapOnTrackedBarcodeEvent) else { return }
        didTapOnTrackedBarcodeEvent.emit(on: emitter,
                                         payload: ["trackedBarcode": trackedBarcode.jsonString])
    }

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
    }
}
