/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class BarcodeTrackingModule: NSObject, FrameworkModule {
    private let barcodeTrackingListener: FrameworksBarcodeTrackingListener
    private let barcodeTrackingBasicOverlayListener: FrameworksBarcodeTrackingBasicOverlayListener
    private let barcodeTrackingAdvancedOverlayListener: FrameworksBarcodeTrackingAdvancedOverlayListener
    private let barcodeTrackingDeserializer: BarcodeTrackingDeserializer
    private let emitter: Emitter
    private let didTapViewForTrackedBarcodeEvent = Event(.didTapViewForTrackedBarcode)
    private var context: DataCaptureContext?
    private var dataCaptureView: DataCaptureView?
    
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
    
    private var modeEnabled = true
    
    // MARK: - FrameworkModule API
    
    public func didStart() {
        Deserializers.Factory.add(barcodeTrackingDeserializer)
        self.barcodeTrackingDeserializer.delegate = self
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }
    
    public func didStop() {
        Deserializers.Factory.remove(barcodeTrackingDeserializer)
        self.barcodeTrackingDeserializer.delegate = nil
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
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
    
    public func setModeEnabled(enabled: Bool) {
        modeEnabled = enabled
        barcodeTracking?.isEnabled = enabled
    }
    
    public func isModeEnabled() -> Bool {
        return barcodeTracking?.isEnabled == true
    }
    
    public func updateModeFromJson(modeJson: String, result: FrameworksResult) {
        guard let mode = barcodeTracking else {
            result.success(result: nil)
            return
        }
        do {
            try barcodeTrackingDeserializer.updateMode(mode, fromJSONString: modeJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func applyModeSettings(modeSettingsJson: String, result: FrameworksResult) {
        guard let mode = barcodeTracking else {
            result.success(result: nil)
            return
        }
        do {
            let settings = try barcodeTrackingDeserializer.settings(fromJSONString: modeSettingsJson)
            mode.apply(settings)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func updateBasicOverlay(overlayJson: String, result: FrameworksResult) {
        guard let overlay = self.basicOverlay else {
            result.success(result: nil)
            return
        }
                
        do {
            try barcodeTrackingDeserializer.update(overlay, fromJSONString: overlayJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func updateAdvancedOverlay(overlayJson: String, result: FrameworksResult) {
        guard let overlay = self.advancedOverlay else {
            result.success(result: nil)
            return
        }
                
        do {
            try barcodeTrackingDeserializer.update(overlay, fromJSONString: overlayJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    func onModeRemovedFromContext() {
        barcodeTracking = nil
        
        if let basicOverlay = self.basicOverlay, let dataCaptureView = self.dataCaptureView {
            dataCaptureView.removeOverlay(basicOverlay)
        }
        self.basicOverlay = nil
        
        if let advancedOverlay = self.advancedOverlay, let dataCaptureView = self.dataCaptureView {
            dataCaptureView.removeOverlay(advancedOverlay)
        }
        self.advancedOverlay = nil
        
        self.advancedOverlayViewPool?.clear()
        self.advancedOverlay = nil
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
        mode.isEnabled = modeEnabled
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

extension BarcodeTrackingModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }
    
    public func dataCaptureView(deserialized view: DataCaptureView?) {
        self.dataCaptureView = view
        
        guard let dcView = view else {
            return
        }
        
        if let basicTrackingOverlay = self.basicOverlay {
            dcView.addOverlay(basicTrackingOverlay)
        }
        
        if let advancedTrackingOverlay = self.advancedOverlay {
            dcView.addOverlay(advancedTrackingOverlay)
        }
    }
    
    public func dataCaptureContext(addMode modeJson: String) throws {
        if JSONValue(string: modeJson).string(forKey: "type") != "barcodeTracking" {
            return
        }
        
        guard let dcContext = self.context else {
            return
        }
        
        let mode = try barcodeTrackingDeserializer.mode(fromJSONString: modeJson, with: dcContext)
        dcContext.addMode(mode)
    }
    
    public func dataCaptureContext(removeMode modeJson: String) {
        if JSONValue(string: modeJson).string(forKey: "type") != "barcodeTracking" {
            return
        }
        
        guard let dcContext = self.context else {
            return
        }
        
        guard let mode = self.barcodeTracking else {
            return
        }
        dcContext.removeMode(mode)
        self.onModeRemovedFromContext()
    }
    
    public func dataCaptureContextAllModeRemoved() {
        self.onModeRemovedFromContext()
    }
    
    public func didDisposeDataCaptureContext() {
        self.context = nil
        self.onModeRemovedFromContext()
    }
    
    public func dataCaptureView(addOverlay overlayJson: String) throws {
        let overlayType = JSONValue(string: overlayJson).string(forKey: "type")
        if overlayType != "barcodeTrackingBasic" && overlayType != "barcodeTrackingAdvanced" {
            return
        }
        
        guard let mode = self.barcodeTracking else {
            return
        }
        
        try dispatchMainSync {
            let overlay: DataCaptureOverlay = (overlayType == "barcodeTrackingBasic") ?
            try barcodeTrackingDeserializer.basicOverlay(fromJSONString: overlayJson, withMode: mode) :
            try barcodeTrackingDeserializer.advancedOverlay(fromJSONString: overlayJson, withMode: mode)
            
            self.dataCaptureView?.addOverlay(overlay)
        }
    }
    
    public func dataCaptureView(removeOverlay overlayJson: String) {
        let overlayType = JSONValue(string: overlayJson).string(forKey: "type")
        if overlayType != "barcodeTrackingBasic" && overlayType != "barcodeTrackingAdvanced" {
            return
        }
        
       if overlayType == "barcodeTrackingBasic" {
            removeCurrentBasicaOverlay()
        } else {
             removeCurrentAdvancedOverlay()
        }
    }
    
    public func dataCaptureViewRemoveAllOverlays() {
        removeCurrentBasicaOverlay()
        removeCurrentAdvancedOverlay()
    }
    
    private func removeCurrentBasicaOverlay() {
        guard let overlay = self.basicOverlay else {
            return
        }
        
        dispatchMainSync {
            self.dataCaptureView?.removeOverlay(overlay)
        }
        self.basicOverlay = nil
    }
    
    private func removeCurrentAdvancedOverlay() {
        guard let overlay = self.advancedOverlay else {
            return
        }
        dispatchMainSync {
            self.dataCaptureView?.removeOverlay(overlay)
        }
        self.advancedOverlay = nil
    }
}
