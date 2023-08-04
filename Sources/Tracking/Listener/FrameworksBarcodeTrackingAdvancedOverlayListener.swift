/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksBarcodeTrackingAdvancedOverlayListener: NSObject, BarcodeTrackingAdvancedOverlayDelegate {
    private enum Constants {
        static let offsetForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.offsetForTrackedBarcode"
        static let anchorForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.anchorForTrackedBarcode"
        static let widgetForTrackedBarcode = "BarcodeTrackingAdvancedOverlayListener.viewForTrackedBarcode"
    }

    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private var isEnabled = AtomicBool()

    private let offsetForTrackedBarcodeEvent = Event(name: Constants.offsetForTrackedBarcode)
    private let anchorForTrackedBarcodeEvent = Event(name: Constants.anchorForTrackedBarcode)
    private let widgetForTrackedBarcodeEvent = Event(name: Constants.widgetForTrackedBarcode)

    public func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                               viewFor trackedBarcode: TrackedBarcode) -> UIView? {
        if isEnabled.value, emitter.hasListener(for: widgetForTrackedBarcodeEvent) {
            widgetForTrackedBarcodeEvent.emit(on: emitter,
                                              payload: ["trackedBarcode": trackedBarcode.jsonString])
        }
        return nil
    }

    public func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                               anchorFor trackedBarcode: TrackedBarcode) -> Anchor {
        if isEnabled.value, emitter.hasListener(for: anchorForTrackedBarcodeEvent) {
            anchorForTrackedBarcodeEvent.emit(on: emitter,
                                              payload: ["trackedBarcode": trackedBarcode.jsonString])
        }
        return .center
    }

    public func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                               offsetFor trackedBarcode: TrackedBarcode) -> PointWithUnit {
        if isEnabled.value, emitter.hasListener(for: offsetForTrackedBarcodeEvent) {
            offsetForTrackedBarcodeEvent.emit(on: emitter,
                                              payload: ["trackedBarcode": trackedBarcode.jsonString])
        }
        return .zero
    }

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
    }
}
