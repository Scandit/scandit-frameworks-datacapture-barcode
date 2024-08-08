/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum SparkScanError: Error {
    case nilContext
    case json(String, String)
    case nilView
    case nilParent
}

open class SparkScanModule: NSObject, FrameworkModule {
    private let sparkScanListener: FrameworksSparkScanListener
    private let sparkScanViewUIListener: FrameworksSparkScanViewUIListener
    private let feedbackDelegate: FrameworksSparkScanFeedbackDelegate
    private let sparkScanDeserializer: SparkScanDeserializer
    private let sparkScanViewDeserializer: SparkScanViewDeserializer

    public var shouldBringSparkScanViewToFront = true

    private var sparkScan: SparkScan? {
        willSet {
            sparkScan?.removeListener(sparkScanListener)
        }
        didSet {
            sparkScan?.addListener(sparkScanListener)
        }
    }

    public var sparkScanView: SparkScanView?

    private var dataCaptureContext: DataCaptureContext?

    private var modeEnabled = true

    public init(sparkScanListener: FrameworksSparkScanListener,
                sparkScanViewUIListener: FrameworksSparkScanViewUIListener,
                feedbackDelegate: FrameworksSparkScanFeedbackDelegate,
                sparkScanDeserializer: SparkScanDeserializer = SparkScanDeserializer(),
                sparkScanViewDeserializer: SparkScanViewDeserializer = SparkScanViewDeserializer()) {
        self.sparkScanListener = sparkScanListener
        self.sparkScanViewUIListener = sparkScanViewUIListener
        self.feedbackDelegate = feedbackDelegate
        self.sparkScanDeserializer = sparkScanDeserializer
        self.sparkScanViewDeserializer = sparkScanViewDeserializer
    }

    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
    }

    public let defaults: DefaultsEncodable = dispatchMainSync { SparkScanDefaults.shared }

    public func addSparkScanListener() {
        sparkScanListener.enable()
    }

    public func removeSparkScanListener() {
        sparkScanListener.disable()
    }

    public func finishDidUpdateSession(enabled: Bool) {
        sparkScanListener.finishDidUpdate(enabled: enabled)
    }

    public func finishDidScan(enabled: Bool) {
        sparkScanListener.finishDidScan(enabled: enabled)
    }

    public func resetSession() {
        sparkScanListener.resetLastSession()
    }

    public func addSparkScanViewUiListener() {
        sparkScanViewUIListener.enable()
    }

    public func removeSparkScanViewUiListener() {
        sparkScanViewUIListener.disable()
    }

    public func addViewToContainer(_ container: UIView, jsonString: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else { return }
            guard let context = self.dataCaptureContext else {
                Log.error(SparkScanError.nilContext)
                result.reject(error: SparkScanError.nilContext)
                return
            }
            let json = JSONValue(string: jsonString)

            if !json.containsKey("SparkScan") {
                let error = SparkScanError.json("Invalid json. Missing 'SparkScan' key.", jsonString)
                Log.error(error)
                result.reject(error: error)
                return
            }
            var mode: SparkScan
            do {
                let sparkScanModeJson = json.object(forKey: "SparkScan").jsonString()
                mode = try self.sparkScanDeserializer.mode(fromJSONString: sparkScanModeJson)
            } catch {
                Log.error(error)
                result.reject(error: error)
                return
            }
            mode.isEnabled = self.modeEnabled
            self.sparkScan = mode

            if !json.containsKey("SparkScanView") {
                let error = SparkScanError.json("Invalid json. Missing 'SparkScanView' key.", jsonString)
                Log.error(error)
                result.reject(error: error)
                return
            }
            do {
                let sparkScanViewJson = json.object(forKey: "SparkScanView")
                let viewSettingsJson = sparkScanViewJson.object(forKey: "viewSettings")
                if viewSettingsJson.containsKey("shouldShowOnTopAlways") {
                    self.shouldBringSparkScanViewToFront = viewSettingsJson.bool(forKey: "shouldShowOnTopAlways")
                }
                viewSettingsJson.removeKeys(["shouldShowOnTopAlways"])
                let sparkScanView = try self.sparkScanViewDeserializer.view(fromJSONString: sparkScanViewJson.jsonString(),
                                                                            with: context,
                                                                            mode: mode,
                                                                            parentView: container)
                sparkScanView.prepareScanning()
                if sparkScanViewJson.containsKey("hasFeedbackDelegate") {
                    sparkScanView.feedbackDelegate = self.feedbackDelegate
                }
                self.sparkScanView = sparkScanView
                self.sparkScanView?.uiDelegate = self.sparkScanViewUIListener
            } catch {
                Log.error(error)
                result.reject(error: error)
                return
            }
            result.success(result: nil)
        }
        dispatchMain(block)
    }

    public func updateView(viewJson: String, result: FrameworksResult) {
        dispatchMain { [weak self] in
            guard let self = self else { return }
            do {
                guard let view = self.sparkScanView else {
                    let error = SparkScanError.nilView
                    Log.error(error)
                    result.reject(error: error)
                    return
                }
                let viewSettingsJson = JSONValue(string: viewJson)
                if viewSettingsJson.containsKey("shouldShowOnTopAlways") {
                    self.shouldBringSparkScanViewToFront = viewSettingsJson.bool(forKey: "shouldShowOnTopAlways")
                }
                viewSettingsJson.removeKeys(["shouldShowOnTopAlways"])
                try self.sparkScanViewDeserializer.update(view, fromJSONString: viewJson)
            } catch {
                Log.error(error)
                result.reject(error: error)
                return
            }
            result.success(result: nil)
        }
    }

    public func updateMode(modeJson: String, result: FrameworksResult) {
        guard let mode = self.sparkScan else {
            do {
                self.sparkScan = try self.sparkScanDeserializer.mode(fromJSONString: modeJson)
                result.success(result: nil)
            } catch {
                Log.error(error)
                result.reject(error: error)
            }
            return
        }

        do {
            try self.sparkScanDeserializer.updateMode(mode, fromJSONString: modeJson)
            result.success(result: nil)
        } catch {
            Log.error(error)
            result.reject(error: error)
        }
    }

    public func emitFeedback(feedbackJson: String, result: FrameworksResult) {
        // Noop operation on the native sdk so we avoid calling anything here
        result.success()
    }

    public func pauseScanning() {
        dispatchMain { [weak self] in
            self?.sparkScanView?.pauseScanning()
        }

    }

    public func startScanning(result: FrameworksResult) {
        dispatchMain { [weak self] in
            guard let self = self else { return }
            guard let view = self.sparkScanView else {
                let error = SparkScanError.nilView
                Log.error(error)
                result.reject(error: error)
                return
            }
            view.startScanning()
            result.success(result: nil)
        }
    }

    public func onResume(result: FrameworksResult) {
        dispatchMain { [weak self] in
            guard let self = self else { return }
            guard let view = self.sparkScanView else {
                let error = SparkScanError.nilView
                Log.error(error)
                result.reject(error: error)
                return
            }
            view.prepareScanning()
            result.success(result: nil)
        }
    }

    public func onPause(result: FrameworksResult) {
        dispatchMain { [weak self] in
            guard let self = self else { return }
            guard let view = self.sparkScanView else {
                let error = SparkScanError.nilView
                Log.error(error)
                result.reject(error: error)
                return
            }
            view.pauseScanning()
            result.success(result: nil)
        }
    }

    public func showToast(text: String, result: FrameworksResult) {
        dispatchMain { [weak self] in
            guard let self = self else { return }
            guard let view = self.sparkScanView else {
                let error = SparkScanError.nilView
                Log.error(error)
                result.reject(error: error)
                return
            }
            view.showToast(text)
            result.success(result: nil)
        }
    }

    public func setModeEnabled(enabled: Bool) {
        modeEnabled = true
        sparkScan?.isEnabled = enabled
    }

    public func isModeEnabled() -> Bool {
        return sparkScan?.isEnabled == true
    }

    public func addFeedbackDelegate(result: FrameworksResult) {
        self.sparkScanView?.feedbackDelegate = self.feedbackDelegate
        result.success()
    }

    public func removeFeedbackDelegate(result: FrameworksResult) {
        self.sparkScanView?.feedbackDelegate = nil
        result.success()
    }

    public func submitFeedbackForBarcode(feedbackJson: String?, result: FrameworksResult) {
        self.feedbackDelegate.submitFeedback(feedbackJson: feedbackJson)
        result.success()
    }

    public func disposeView() {
        sparkScanView?.removeFromSuperview()
        sparkScanView?.uiDelegate = nil
        sparkScanView = nil
    }
}

extension SparkScanModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        dataCaptureContext = context
    }
}
