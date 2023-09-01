/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class BarcodeTrackingModule: NSObject, FrameworkModule {
    private let barcodeTrackingListener: FrameworksBarcodeTrackingListener
    private let barcodeTrackingBasicOverlayListener: FrameworksBarcodeTrackingBasicOverlayListener
    private let barcodeTrackingAdvancedOverlayListener: FrameworksBarcodeTrackingAdvancedOverlayListener
    private let barcodeTrackingDeserializer: BarcodeTrackingDeserializer
    private let emitter: Emitter
    private let didTapViewForTrackedBarcodeEvent = Event(.didTapViewForTrackedBarcode)

    public init(barcodeTrackingListener: FrameworksBarcodeTrackingListener,
                barcodeTrackingBasicOverlayListener: FrameworksBarcodeTrackingBasicOverlayListener,
                barcodeTrackingAdvancedOverlayListener: FrameworksBarcodeTrackingAdvancedOverlayListener,
                emitter: Emitter,
                barcodeTrackingDeserializer: BarcodeTrackingDeserializer = BarcodeTrackingDeserializer()) {
        self.barcodeTrackingListener = barcodeTrackingListener
        self.barcodeTrackingBasicOverlayListener = barcodeTrackingBasicOverlayListener
        self.barcodeTrackingAdvancedOverlayListener = barcodeTrackingAdvancedOverlayListener
        self.barcodeTrackingDeserializer = barcodeTrackingDeserializer
        self.emitter = emitter
    }

    private var barcodeTracking: BarcodeTracking? {
        willSet {
            barcodeTracking?.removeListener(barcodeTrackingListener)
        }
        didSet {
            barcodeTracking?.addListener(barcodeTrackingListener)
        }
    }

    private var basicOverlay: BarcodeTrackingBasicOverlay?
    private var advancedOverlay: BarcodeTrackingAdvancedOverlay?
    private var advancedOverlayViewPool: AdvancedOverlayViewPool?

    // MARK: - FrameworkModule API

    public func didStart() {
        barcodeTrackingDeserializer.delegate = self
        Deserializers.Factory.add(barcodeTrackingDeserializer)
    }

    public func didStop() {
        barcodeTrackingDeserializer.delegate = nil
        Deserializers.Factory.remove(barcodeTrackingDeserializer)
    }

    // MARK: - Module API exposed to the platform native modules

    public let defaults: DefaultsEncodable = BarcodeTrackingDefaults.shared

    public func addBarcodeTrackingListener() {
        barcodeTrackingListener.enable()
    }

    public func removeBarcodeTrackingListener() {
        barcodeTrackingListener.disable()
    }

    public func finishDidUpdateSession(enabled: Bool) {
        barcodeTrackingListener.finishDidUpdateSession(enabled: enabled)
    }

    public func resetSession(frameSequenceId: Int?) {
        barcodeTrackingListener.resetSession(with: frameSequenceId)
    }

    public func addBasicOverlayListener() {
        barcodeTrackingBasicOverlayListener.enable()
    }

    public func removeBasicOverlayListener() {
        barcodeTrackingBasicOverlayListener.disable()
    }

    public func clearBasicOverlayTrackedBarcodeBrushes() {
        basicOverlay?.clearTrackedBarcodeBrushes()
    }

    public func setBasicOverlayBrush(with brushJson: String) {
        let jsonValue = JSONValue(string: brushJson)
        let data = BrushAndTrackedBarcode(jsonValue: jsonValue)
        if let trackedBarcode = barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: data.trackedBarcodeId,
                                                                                         sessionId: data.sessionFrameSequenceId) {
            basicOverlay?.setBrush(data.brush, for: trackedBarcode)
        }
    }

    public func addAdvancedOverlayListener() {
        dispatchMainSync {
            self.barcodeTrackingAdvancedOverlayListener.enable()
            self.advancedOverlayViewPool = AdvancedOverlayViewPool(
                emitter: self.barcodeTrackingListener.emitter,
                didTapViewForTrackedBarcodeEvent: didTapViewForTrackedBarcodeEvent
            )
        }
    }

    public func removeAdvancedOverlayListener() {
        dispatchMainSync {
            self.barcodeTrackingAdvancedOverlayListener.disable()
            self.advancedOverlay?.delegate = nil
            self.advancedOverlayViewPool?.clear()
        }
    }

    public func clearAdvancedOverlayTrackedBarcodeViews() {
        dispatchMainSync {
            self.advancedOverlay?.clearTrackedBarcodeViews()
        }
    }

    public func setWidgetForTrackedBarcode(with viewParams: [String: Any?]) {
        let data = AdvancedOverlayViewData(dictionary: viewParams)
        guard let barcode = barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: data.trackedBarcodeId,
                                                                                     sessionId: data.sessionFrameSequenceId) else { return }
        guard let widgedData = data.widgetData else {
            advancedOverlayViewPool?.removeView(for: barcode)
            dispatchMainSync {
                self.advancedOverlay?.setView(nil, for: barcode)
            }
            return
        }
        guard let view = advancedOverlayViewPool?.getOrCreateView(barcode: barcode, widgetData: widgedData) else { return }
        dispatchMainSync {
            self.advancedOverlay?.setView(view, for: barcode)
        }
    }

    public func setViewForTrackedBarcode(view: TappableView?,
                                         trackedBarcodeId: Int,
                                         sessionFrameSequenceId: Int?) {
        guard let barcode = barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: trackedBarcodeId,
                                                                                     sessionId: sessionFrameSequenceId) else {
            return
        }
        view?.didTap = { [weak self] in
            guard let self = self else { return }
            self.didTapViewForTrackedBarcodeEvent.emit(
                on: self.emitter,
                payload: ["trackedBarcode": barcode.jsonString]
            )
        }
        dispatchMainSync {
            self.advancedOverlay?.setView(view, for: barcode)
        }
    }

    public func setAnchorForTrackedBarcode(anchorParams: [String: Any?]) {
        let data = AdvancedOverlayAnchorData(dictionary: anchorParams)
        guard let barcode = barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: data.trackedBarcodeId,
                                                                                     sessionId: data.sessionFrameSequenceId) else {
            return
        }
        dispatchMainSync {
            self.advancedOverlay?.setAnchor(data.anchor, for: barcode)
        }
    }

    public func setOffsetForTrackedBarcode(offsetParams: [String: Any?]) {
        let data = AdvancedOverlayOffsetData(dictionary: offsetParams)
        guard let barcode = barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: data.trackedBarcodeId,
                                                                                     sessionId: data.sessionFrameSequenceId) else {
            return
        }
        dispatchMainSync {
            self.advancedOverlay?.setOffset(data.offset, for: barcode)
        }
    }

    public func trackedBarcode(by id: Int) -> TrackedBarcode? {
        barcodeTrackingListener.getTrackedBarcodeFromLastSession(barcodeId: id, sessionId: nil)
    }
}

extension BarcodeTrackingModule: BarcodeTrackingDeserializerDelegate {
    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didStartDeserializingMode mode: BarcodeTracking,
                                            from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didFinishDeserializingMode mode: BarcodeTracking,
                                            from jsonValue: JSONValue) {
        if jsonValue.containsKey("enabled") {
            mode.isEnabled = jsonValue.bool(forKey: "enabled")
        }
        barcodeTracking = mode
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didStartDeserializingSettings settings: BarcodeTrackingSettings,
                                            from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didFinishDeserializingSettings settings: BarcodeTrackingSettings,
                                            from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didStartDeserializingBasicOverlay overlay: BarcodeTrackingBasicOverlay,
                                            from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didFinishDeserializingBasicOverlay overlay: BarcodeTrackingBasicOverlay,
                                            from jsonValue: JSONValue) {
        basicOverlay?.delegate = nil
        basicOverlay = overlay
        basicOverlay?.delegate = barcodeTrackingBasicOverlayListener
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didStartDeserializingAdvancedOverlay overlay: BarcodeTrackingAdvancedOverlay,
                                            from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeTrackingDeserializer(_ deserializer: BarcodeTrackingDeserializer,
                                            didFinishDeserializingAdvancedOverlay overlay: BarcodeTrackingAdvancedOverlay,
                                            from jsonValue: JSONValue) {
        advancedOverlay?.delegate = nil
        advancedOverlay = overlay
        advancedOverlay?.delegate = barcodeTrackingAdvancedOverlayListener
    }
}
