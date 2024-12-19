/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class FrameworksBarcodeBatchBasicOverlayListener: NSObject, BarcodeBatchBasicOverlayDelegate {
    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicBool()

    private let brushForTrackedBarcodeEvent = Event(.brushForTrackedBarcode)
    private let didTapOnTrackedBarcodeEvent = Event(.didTapOnTrackedBarcode)

    public func barcodeBatchBasicOverlay(_ overlay: BarcodeBatchBasicOverlay,
                                            brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        guard isEnabled.value, emitter.hasListener(for: brushForTrackedBarcodeEvent) else { return overlay.brush }
        brushForTrackedBarcodeEvent.emit(on: emitter,
                                         payload: ["trackedBarcode": trackedBarcode.jsonString])
        return overlay.brush
    }

    public func barcodeBatchBasicOverlay(_ overlay: BarcodeBatchBasicOverlay,
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
