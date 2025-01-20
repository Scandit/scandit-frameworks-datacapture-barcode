/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class BarcodeCaptureModule: NSObject, FrameworkModule {
    private let barcodeCaptureDeserializer: BarcodeCaptureDeserializer
    private let barcodeCaptureListener: FrameworksBarcodeCaptureListener
    private var modeEnabled = true
    private var context: DataCaptureContext?

    private var barcodeCapture: BarcodeCapture? {
        willSet {
            barcodeCapture?.removeListener(barcodeCaptureListener)
        }
        didSet {
            barcodeCapture?.addListener(barcodeCaptureListener)
        }
    }

    public init(barcodeCaptureListener: FrameworksBarcodeCaptureListener,
                deserializer: BarcodeCaptureDeserializer = BarcodeCaptureDeserializer()) {
        self.barcodeCaptureDeserializer = deserializer
        self.barcodeCaptureListener = barcodeCaptureListener
    }

    public func didStart() {
        Deserializers.Factory.add(barcodeCaptureDeserializer)
        self.barcodeCaptureDeserializer.delegate = self
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        self.barcodeCaptureDeserializer.delegate = nil
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        Deserializers.Factory.remove(barcodeCaptureDeserializer)
        barcodeCaptureListener.clearCache()
        barcodeCaptureListener.disable()
        barcodeCapture = nil
    }

    public let defaults: DefaultsEncodable = BarcodeCaptureDefaults.shared

    public func addListener() {
        barcodeCaptureListener.enable()
    }

    public func removeListener() {
        barcodeCaptureListener.disable()
    }
    
    public func addAsyncListener() {
        barcodeCaptureListener.enableAsync()
    }

    public func removeAsyncListener() {
        barcodeCaptureListener.disableAsync()
    }

    public func finishDidScan(enabled: Bool) {
        barcodeCaptureListener.finishDidScan(enabled: enabled)
    }

    public func finishDidUpdateSession(enabled: Bool) {
        barcodeCaptureListener.finishDidUpdateSession(enabled: enabled)
    }

    public func resetSession(frameSequenceId: Int?) {
        barcodeCaptureListener.resetSession(with: frameSequenceId)
    }
    
    public func setModeEnabled(enabled: Bool) {
        modeEnabled = enabled
        barcodeCapture?.isEnabled = enabled
    }
    
    public func isModeEnabled() -> Bool {
        return barcodeCapture?.isEnabled == true
    }
    
    public func updateModeFromJson(modeJson: String, result: FrameworksResult) {
        guard let mode = barcodeCapture else {
            result.success(result: nil)
            return
        }
        do {
            try barcodeCaptureDeserializer.updateMode(mode, fromJSONString: modeJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func applyModeSettings(modeSettingsJson: String, result: FrameworksResult) {
        guard let mode = barcodeCapture else {
            result.success(result: nil)
            return
        }
        do {
            let settings = try barcodeCaptureDeserializer.settings(fromJSONString: modeSettingsJson)
            mode.apply(settings)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func updateOverlay(overlayJson: String, result: FrameworksResult) {
        guard let overlay: BarcodeCaptureOverlay = DataCaptureViewHandler.shared.findFirstOverlayOfType() else {
            result.success(result: nil)
            return
        }
                
        do {
            try barcodeCaptureDeserializer.update(overlay, fromJSONString: overlayJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func updateFeedback(feedbackJson: String, result: FrameworksResult) {
        do {
            barcodeCapture?.feedback = try BarcodeCaptureFeedback(fromJSONString: feedbackJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }
    
    public func getLastFrameDataBytes(frameId: String, result: FrameworksResult) {
        LastFrameData.shared.getLastFrameDataBytes(frameId: frameId) {
            result.success(result: $0)
        }
    }
}

extension BarcodeCaptureModule: BarcodeCaptureDeserializerDelegate {
    public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didStartDeserializingMode mode: BarcodeCapture,
                                        from jsonValue: JSONValue) {
            // not used in frameworks
        }

        public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didFinishDeserializingMode mode: BarcodeCapture,
                                        from jsonValue: JSONValue) {
            mode.isEnabled = modeEnabled
            barcodeCapture = mode
        }

        public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didStartDeserializingSettings settings: BarcodeCaptureSettings,
                                        from jsonValue: JSONValue) {
            // not used in frameworks
        }

        public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didFinishDeserializingSettings settings: BarcodeCaptureSettings,
                                        from jsonValue: JSONValue) {
            // not used in frameworks
        }

        public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didStartDeserializingOverlay overlay: BarcodeCaptureOverlay,
                                        from jsonValue: JSONValue) {
            // not used in frameworks
        }

        public func barcodeCaptureDeserializer(_ deserializer: BarcodeCaptureDeserializer,
                                        didFinishDeserializingOverlay overlay: BarcodeCaptureOverlay,
                                        from jsonValue: JSONValue) {
            // not used in frameworks
        }
}

extension BarcodeCaptureModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }
    
    public func dataCaptureContext(addMode modeJson: String) throws {
        if JSONValue(string: modeJson).string(forKey: "type") != "barcodeCapture" {
            return
        }

        guard let dcContext = self.context else {
            return
        }

        let mode = try barcodeCaptureDeserializer.mode(fromJSONString: modeJson, with: dcContext)
        dcContext.addMode(mode)
    }
    
    public func dataCaptureContext(removeMode modeJson: String) {
        if JSONValue(string: modeJson).string(forKey: "type") != "barcodeCapture" {
            return
        }

        guard let dcContext = self.context else {
            return
        }
        
        guard let mode = self.barcodeCapture else {
            return
        }
        dcContext.removeMode(mode)
        self.barcodeCapture = nil
    }
    
    public func dataCaptureContextAllModeRemoved() {
        self.barcodeCapture = nil
    }
    
    public func didDisposeDataCaptureContext() {
        self.context = nil
        self.barcodeCapture = nil
    }
    
    public func dataCaptureView(addOverlay overlayJson: String, to view: DataCaptureView) throws {
        if JSONValue(string: overlayJson).string(forKey: "type") != "barcodeCapture" {
            return
        }
        
        guard let mode = self.barcodeCapture else {
            return
        }
        
        try dispatchMainSync {
            let overlay = try barcodeCaptureDeserializer.overlay(fromJSONString: overlayJson, withMode: mode)
            DataCaptureViewHandler.shared.addOverlayToView(view, overlay: overlay)
        }
    }
}
