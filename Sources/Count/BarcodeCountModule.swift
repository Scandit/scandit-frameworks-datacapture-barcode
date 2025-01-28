/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class BarcodeCountModule: NSObject, FrameworkModule, DeserializationLifeCycleObserver {
    private let barcodeCountListener: FrameworksBarcodeCountListener
    private let captureListListener: FrameworksBarcodeCountCaptureListListener
    private let viewListener: FrameworksBarcodeCountViewListener
    private let viewUiListener: FrameworksBarcodeCountViewUIListener
    private let statusProvider: FrameworksBarcodeCountStatusProvider
    private let barcodeCountDeserializer: BarcodeCountDeserializer
    private let barcodeCountViewDeserializer: BarcodeCountViewDeserializer

    public init(barcodeCountListener: FrameworksBarcodeCountListener,
                captureListListener: FrameworksBarcodeCountCaptureListListener,
                viewListener: FrameworksBarcodeCountViewListener,
                viewUiListener: FrameworksBarcodeCountViewUIListener,
                statusProvider: FrameworksBarcodeCountStatusProvider,
                barcodeCountDeserializer: BarcodeCountDeserializer = BarcodeCountDeserializer(),
                barcodeCountViewDeserializer: BarcodeCountViewDeserializer = BarcodeCountViewDeserializer()) {
        self.barcodeCountListener = barcodeCountListener
        self.captureListListener = captureListListener
        self.viewListener = viewListener
        self.viewUiListener = viewUiListener
        self.statusProvider = statusProvider
        self.barcodeCountDeserializer = barcodeCountDeserializer
        self.barcodeCountViewDeserializer = barcodeCountViewDeserializer
    }

    private var context: DataCaptureContext?

    private var modeEnabled = true

    public var barcodeCountView: BarcodeCountView?

    private var barcodeCountCaptureList: BarcodeCountCaptureList?

    private var barcodeCountFeedback: BarcodeCountFeedback?

    private var barcodeCount: BarcodeCount? {
        willSet {
            barcodeCount?.removeListener(barcodeCountListener)
        }
        didSet {
            barcodeCount?.addListener(barcodeCountListener)
            if let captureList = barcodeCountCaptureList {
                barcodeCount?.setCaptureList(captureList)
            }
        }
    }

    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        removeBarcodeCountListener()
        removeBarcodeCountViewListener(result: NoopFrameworksResult())
        removeBarcodeCountViewUiListener(result: NoopFrameworksResult())
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        disposeBarcodeCountView()
    }

    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }

    public func didDisposeDataCaptureContext() {
        self.context = nil
        self.barcodeCountView?.delegate = nil
        self.barcodeCountView?.uiDelegate = nil
        self.barcodeCountView = nil
        self.barcodeCount?.removeListener(barcodeCountListener)
        self.barcodeCount = nil
    }

    public let defaults: DefaultsEncodable = BarcodeCountDefaults.shared

    public func addViewFromJson(parent: UIView, viewJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else { return }
            guard let context = self.context else {
                result.reject(error: ScanditFrameworksCoreError.nilDataCaptureContext)
                Log.error("Error during the barcode count view deserialization.\nError: The DataCaptureView has not been initialized yet.")
                return
            }
            let json = JSONValue(string: viewJson)
            guard json.containsKey("BarcodeCount"), json.containsKey("View") else {
                result.reject(error: ScanditFrameworksCoreError.deserializationError(error: nil, json: viewJson))
                Log.error("Error during the barcode count view deserialization.\nError: Json string doesn't contain `BarcodeCount`")
                return
            }
            let barcodeCountModeJson = json.getObjectAsString(forKey: "BarcodeCount")

            var mode: BarcodeCount
            do {
                mode = try self.barcodeCountDeserializer.mode(fromJSONString: barcodeCountModeJson,
                                                              context: context)
            } catch {
                Log.error("Error during the barcode count view deserialization.\nError:", error: error)
                return
            }
            mode.isEnabled = self.modeEnabled
            self.barcodeCount = mode

            guard json.containsKey("View") else {
                Log.error("Error during the barcode count view deserialization.\nError: Json string doesn't contain `View`")
                return
            }
            let barcodeCountViewJson = json.getObjectAsString(forKey: "View")
            do {
                let view = try self.barcodeCountViewDeserializer.view(fromJSONString: barcodeCountViewJson,
                                                                      barcodeCount: mode,
                                                                      context: context)
                view.delegate = self.viewListener
                view.uiDelegate = self.viewUiListener
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                parent.addSubview(view)

                if json.object(forKey: "View").getObjectAsBool(forKey: "hasStatusProvider") {
                    view.setStatusProvider(self.statusProvider)
                }

                self.barcodeCountView = view

                // update feedback in case the update call did run before the creation of the mode
                if let feedback = self.barcodeCountFeedback {
                    mode.feedback = feedback
                    self.barcodeCountFeedback = nil
                }
            } catch {
                result.reject(error: error)
                Log.error("Error during the barcode count view deserialization.\nError:", error: error)
                return
            }
            result.success(result: nil)
        }
        dispatchMainSync(block)
    }

    public func updateBarcodeCountView(viewJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else { return }
            guard let view = self.barcodeCountView else {
                return
            }
            do {
                self.barcodeCountView = try self.barcodeCountViewDeserializer.update(view, fromJSONString: viewJson)
                result.success(result: nil)
            } catch {
                Log.error("Error while updating the BarcodeCountView.", error: error)
                result.reject(error: error)
                return
            }
        }
        dispatchMainSync(block)
    }

    public func removeBarcodeCountView(result: FrameworksResult) {
        removeBarcodeCountListener()
        removeBarcodeCountViewListener(result: NoopFrameworksResult())
        removeBarcodeCountViewUiListener(result: NoopFrameworksResult())
        disposeBarcodeCountView()
        result.success(result: nil)
    }

    public func addBarcodeCountStatusProvider(result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else { return }
            self.barcodeCountView?.setStatusProvider(self.statusProvider)
            result.success(result: nil)
        }
        dispatchMainSync(block)
    }

    public func updateBarcodeCount(modeJson: String, result: FrameworksResult) {
        guard let mode = barcodeCount else { return }
        do {
            barcodeCount = try self.barcodeCountDeserializer.updateMode(mode, fromJSONString: modeJson)
            let jsonValue = JSONValue(string: modeJson)
            if jsonValue.containsKey("enabled") {
                mode.isEnabled = jsonValue.bool(forKey: "enabled")
            }
            result.success(result: nil)
        } catch {
            Log.error("Error while updating the BarcodeFind mode.", error: error)
            result.reject(error: error)
        }
    }

    public func addBarcodeCountViewListener(result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            self?.barcodeCountView?.delegate = self?.viewListener
            result.success(result: nil)
        }
    }

    public func removeBarcodeCountViewListener(result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            self?.barcodeCountView?.delegate = nil
            result.success(result: nil)
        }
    }

    public func addBarcodeCountViewUiListener(result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            self?.barcodeCountView?.uiDelegate = self?.viewUiListener
            result.success(result: nil)
        }
    }

    public func removeBarcodeCountViewUiListener(result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            self?.barcodeCountView?.uiDelegate = nil
            result.success(result: nil)
        }
    }

    public func clearHighlights() {
        barcodeCountView?.clearHighlights()
    }

    public func finishBrushForRecognizedBarcodeEvent(brush: Brush?, trackedBarcodeId: Int, result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            let barcode = self?.viewListener.getTrackedBarcodeForBrush(with: trackedBarcodeId,
                                                                       for: .brushForRecognizedBarcode)
            if let trackedBarcode = barcode, let brush = brush {
                self?.barcodeCountView?.setBrush(brush, forRecognizedBarcode: trackedBarcode)
            }
            result.success(result: nil)
        }
    }

    public func finishBrushForRecognizedBarcodeNotInListEvent(brush: Brush?, trackedBarcodeId: Int, result: FrameworksResult) {
        dispatchMainSync { [weak self] in
            let barcode = self?.viewListener.getTrackedBarcodeForBrush(with: trackedBarcodeId,
                                                                       for: .brushForRecognizedBarcodeNotInList)
            if let trackedBarcode = barcode, let brush = brush {
                self?.barcodeCountView?.setBrush(brush, forRecognizedBarcodeNotInList: trackedBarcode)
            }
            result.success(result: nil)
        }
    }

    public func finishBrushForAcceptedBarcodeEvent(brush: Brush?, trackedBarcodeId: Int) {
        dispatchMainSync{ [weak self] in
            let barcode = self?.viewListener.getTrackedBarcodeForBrush(with: trackedBarcodeId,
                                                                       for: .brushForAcceptedBarcode)

            if let trackedBarcode = barcode, let brush = brush {
                self?.barcodeCountView?.setBrush(brush, forAcceptedBarcode: trackedBarcode)
            }
        }
    }

    public func finishBrushForRejectedBarcodeEvent(brush: Brush?, trackedBarcodeId: Int) {
        dispatchMainSync{ [weak self] in
            let barcode = self?.viewListener.getTrackedBarcodeForBrush(with: trackedBarcodeId,
                                                                       for: .brushForRejectedBarcode)

            if let trackedBarcode = barcode, let brush = brush {
                self?.barcodeCountView?.setBrush(brush, forRejectedBarcode: trackedBarcode)
            }
        }
    }

    public func setBarcodeCountCaptureList(barcodesJson: String) {
        let jsonArray = JSONValue(string: barcodesJson).asArray()
        let targetBarcodes = Set((0...jsonArray.count() - 1).map { jsonArray.atIndex($0).asObject() }.map {
            TargetBarcode(data: $0.string(forKey: "data"), quantity: $0.integer(forKey: "quantity"))
        })
        barcodeCountCaptureList = BarcodeCountCaptureList(listener: captureListListener, targetBarcodes: targetBarcodes)

        guard let mode = barcodeCount else {
            return
        }

        mode.setCaptureList(barcodeCountCaptureList)
    }

    public func resetBarcodeCountSession(frameSequenceId: Int?) {
        barcodeCountListener.resetSession(frameSequenceId: frameSequenceId)
    }

    public func finishOnScan(enabled: Bool) {
        barcodeCountListener.finishDidScan(enabled: enabled)
    }

    public func addBarcodeCountListener() {
        barcodeCountListener.enable()
    }

    public func removeBarcodeCountListener() {
        barcodeCountListener.disable()
    }

    public func addAsyncBarcodeCountListener() {
        barcodeCountListener.enableAsync()
    }

    public func removeAsyncBarcodeCountListener() {
        barcodeCountListener.disableAsync()
    }

    public func resetBarcodeCount() {
        barcodeCount?.reset()
    }

    public func startScanningPhase() {
        barcodeCount?.startScanningPhase()
    }

    public func endScanningPhase() {
        barcodeCount?.endScanningPhase()
    }

    public func disposeBarcodeCountView() {
        barcodeCountView?.delegate = nil
        barcodeCountView?.uiDelegate = nil
        barcodeCountView?.removeFromSuperview()
        barcodeCountView = nil
        barcodeCount?.removeListener(barcodeCountListener)
        barcodeCount = nil
    }

    public func submitSpatialMap(result: FrameworksResult) {
        result.success(result: barcodeCountListener.getSpatialMap()?.jsonString)
    }

    public func submitSpatialMap(expectedNumberOfRows: Int, expectedNumberOfColumns: Int, result: FrameworksResult) {
        result.success(
            result: barcodeCountListener.getSpatialMap(
                expectedNumberOfRows: expectedNumberOfRows,
                expectedNumberOfColumns: expectedNumberOfColumns
            )?.jsonString
        )
    }

    public func setModeEnabled(enabled: Bool) {
        modeEnabled = enabled
        barcodeCount?.isEnabled = enabled
    }

    public func isModeEnabled() -> Bool {
        return barcodeCount?.isEnabled == true
    }

    public func updateFeedback(feedbackJson: String, result: FrameworksResult) {
        guard let jsonData = feedbackJson.data(using: .utf8) else {
            result.reject(code: "-1", message: "Invalid feedback json", details: nil)
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let newFeedback = barcodeCount?.feedback ?? BarcodeCountFeedback.default

                if let successData = json["success"] as? [String: Any] {
                    if let success = successData.encodeToJSONString() {
                        newFeedback.success = try Feedback(fromJSONString: success)
                    }
                }

                if let failureData = json["failure"] as? [String: Any] {
                    if let failure = failureData.encodeToJSONString() {
                        newFeedback.failure = try Feedback(fromJSONString: failure)
                    }
                }

                barcodeCountFeedback = newFeedback
            }

            // in case we don't have a mode yet, it will return success and cache the new
            // feedback to be applied after the creation of the view.
             if let mode = barcodeCount, let feedback = barcodeCountFeedback {
                mode.feedback = feedback
                barcodeCountFeedback = nil
            }

            result.success()
        } catch let error {
            result.reject(error: error)
        }
    }

    public func submitBarcodeCountStatusProviderCallbackResult(statusJson: String, result: FrameworksResult) {
        statusProvider.submitCallbackResult(resultJson: statusJson)
        result.success()
    }

    public func getLastFrameDataBytes(frameId: String, result: FrameworksResult) {
        LastFrameData.shared.getLastFrameDataBytes(frameId: frameId) {
            result.success(result: $0)
        }
    }
}
