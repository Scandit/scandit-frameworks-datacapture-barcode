/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodeSelectionError: Error {
    case modeDoesNotExist
    case nilOverlay
}

public class BarcodeSelectionModule: NSObject, FrameworkModule {
    private let barcodeSelectionListener: FrameworksBarcodeSelectionListener
    private var aimedBrushProviderFlag: Bool = false
    private var trackedBrushProviderFlag: Bool = false
    private let aimedBrushProvider: FrameworksBarcodeSelectionAimedBrushProvider
    private let trackedBrushProvider: FrameworksBarcodeSelectionTrackedBrushProvider
    private let barcodeSelectionDeserializer: BarcodeSelectionDeserializer

    private var barcodeSelection: BarcodeSelection? {
        willSet {
            barcodeSelection?.removeListener(barcodeSelectionListener)
        }
        didSet {
            barcodeSelection?.addListener(barcodeSelectionListener)
        }
    }

    private var barcodeSelectionBasicOverlay: BarcodeSelectionBasicOverlay?

    public init(barcodeSelectionListener: FrameworksBarcodeSelectionListener,
                aimedBrushProvider: FrameworksBarcodeSelectionAimedBrushProvider,
                trackedBrushProvider: FrameworksBarcodeSelectionTrackedBrushProvider,
                barcodeSelectionDeserializer: BarcodeSelectionDeserializer = BarcodeSelectionDeserializer()) {
        self.barcodeSelectionListener = barcodeSelectionListener
        self.aimedBrushProvider = aimedBrushProvider
        self.trackedBrushProvider = trackedBrushProvider
        self.barcodeSelectionDeserializer = barcodeSelectionDeserializer
    }

    public func didStart() {
        barcodeSelectionDeserializer.delegate = self
        Deserializers.Factory.add(barcodeSelectionDeserializer)
    }

    public func didStop() {
        barcodeSelectionDeserializer.delegate = nil
        Deserializers.Factory.remove(barcodeSelectionDeserializer)
        aimedBrushProvider.clearCache()
        trackedBrushProvider.clearCache()
        barcodeSelectionBasicOverlay?.setAimedBarcodeBrushProvider(nil)
        barcodeSelectionBasicOverlay?.setTrackedBarcodeBrushProvider(nil)
        barcodeSelectionBasicOverlay = nil
    }

    // MARK: - Module API

    public let defaults: DefaultsEncodable = BarcodeSelectionDefaults.shared

    public func addListener() {
        barcodeSelectionListener.enable()
    }

    public func removeListener() {
        barcodeSelectionListener.disable()
    }

    public func unfreezeCamera() {
        barcodeSelection?.unfreezeCamera()
    }

    public func resetSelection() {
        barcodeSelection?.reset()
    }

    public func getBarcodeCount(selectionIdentifier: String) -> Int {
        barcodeSelectionListener.getBarcodeCount(selectionIdentifier: selectionIdentifier)
    }

    public func resetLatestSession(frameSequenceId: Int?) {
        barcodeSelectionListener.resetSession(frameSequenceId: frameSequenceId)
    }

    public func finishDidSelect(enabled: Bool) {
        barcodeSelectionListener.finishDidSelect(enabled: enabled)
    }

    public func finishDidUpdate(enabled: Bool) {
        barcodeSelectionListener.finishDidUpdate(enabled: enabled)
    }

    public func increaseCountForBarcodes(barcodesJson: String, result: FrameworksResult) {
        guard let selection = barcodeSelection else {
            result.reject(error: BarcodeSelectionError.modeDoesNotExist)
            return
        }
        selection.increaseCountForBarcodes(fromJsonString: barcodesJson)
        result.success(result: nil)
    }

    public func setAimedBrushProvider(result: FrameworksResult) {
        aimedBrushProviderFlag = true
        result.success(result: nil)
    }

    public func removeAimedBarcodeBrushProvider() {
        aimedBrushProviderFlag = false
        aimedBrushProvider.clearCache()
        barcodeSelectionBasicOverlay?.setAimedBarcodeBrushProvider(nil)
    }

    public func finishBrushForAimedBarcode(brushJson: String?, selectionIdentifier: String?) {
        aimedBrushProvider.finishCallback(brushJson: brushJson, selectionIdentifier: selectionIdentifier)
    }

    public func finishBrushForTrackedBarcode(brushJson: String?, selectionIdentifier: String?) {
        trackedBrushProvider.finishCallback(brushJson: brushJson, selectionIdentifier: selectionIdentifier)
    }

    public func setTextForAimToSelectAutoHint(text:String, result: FrameworksResult) {
        guard let overlay = barcodeSelectionBasicOverlay else {
            result.reject(error: BarcodeSelectionError.nilOverlay)
            return
        }
        overlay.setTextForAimToSelectAutoHint(text)
        result.success(result: nil)
    }
    
    public func setTrackedBrushProvider(result: FrameworksResult) {
        trackedBrushProviderFlag = true
        result.success(result: nil)
    }

    public func removeTrackedBarcodeBrushProvider() {
        trackedBrushProviderFlag = false
        trackedBrushProvider.clearCache()
        barcodeSelectionBasicOverlay?.setTrackedBarcodeBrushProvider(nil)
    }

    public func selectAimedBarcode() {
        barcodeSelection?.selectAimedBarcode()
    }

    public func unselectBarcodes(barcodesJson: String, result: FrameworksResult) {
        guard let mode = barcodeSelection else {
            result.reject(error: BarcodeSelectionError.modeDoesNotExist)
            return
        }
        mode.unselectBarcodes(fromJsonString: barcodesJson)
        result.success(result: nil)
    }

    public func setSelectBarcodeEnabled(barcodesJson: String, enabled: Bool, result: FrameworksResult) {
        guard let mode = barcodeSelection else {
            result.reject(error: BarcodeSelectionError.modeDoesNotExist)
            return
        }
        mode.setSelectBarcodeFromJsonString(barcodesJson, enabled: enabled)
        result.success(result: nil)
    }
}

extension BarcodeSelectionModule: BarcodeSelectionDeserializerDelegate {
    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didStartDeserializingMode mode: BarcodeSelection,
                                             from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didFinishDeserializingMode mode: BarcodeSelection,
                                             from jsonValue: JSONValue) {
        if jsonValue.containsKey("enabled") {
            mode.isEnabled = jsonValue.bool(forKey: "enabled")
        }
        barcodeSelection = mode
    }

    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didStartDeserializingSettings settings: BarcodeSelectionSettings,
                                             from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didFinishDeserializingSettings settings: BarcodeSelectionSettings,
                                             from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didStartDeserializingBasicOverlay overlay: BarcodeSelectionBasicOverlay,
                                             from jsonValue: JSONValue) {
        // not used in frameworks
    }

    public func barcodeSelectionDeserializer(_ deserializer: BarcodeSelectionDeserializer,
                                             didFinishDeserializingBasicOverlay overlay: BarcodeSelectionBasicOverlay,
                                             from jsonValue: JSONValue) {
        barcodeSelectionBasicOverlay = overlay
        

        if let barcodeSelectionBasicOverlay = barcodeSelectionBasicOverlay, trackedBrushProviderFlag {
            barcodeSelectionBasicOverlay.setTrackedBarcodeBrushProvider(trackedBrushProvider)
        }
        
        if let barcodeSelectionBasicOverlay = barcodeSelectionBasicOverlay, aimedBrushProviderFlag {
            barcodeSelectionBasicOverlay.setAimedBarcodeBrushProvider(aimedBrushProvider)
        }
    }
}
