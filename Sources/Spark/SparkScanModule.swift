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
}

public class SparkScanModule: NSObject, FrameworkModule {
    private let sparkScanListener: FrameworksSparkScanListener
    private let sparkScanViewUIListener: FrameworksSparkScanViewUIListener
    private let sparkScanDeserializer: SparkScanDeserializer
    private let sparkScanViewDeserializer: SparkScanViewDeserializer

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

    public init(sparkScanListener: FrameworksSparkScanListener,
                sparkScanViewUIListener: FrameworksSparkScanViewUIListener,
                sparkScanDeserializer: SparkScanDeserializer = SparkScanDeserializer(),
                sparkScanViewDeserializer: SparkScanViewDeserializer = SparkScanViewDeserializer()) {
        self.sparkScanListener = sparkScanListener
        self.sparkScanViewUIListener = sparkScanViewUIListener
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
            let sparkScanModeJson = json.object(forKey: "SparkScan").jsonString()
            var mode: SparkScan
            do {
                mode = try self.sparkScanDeserializer.mode(fromJSONString: sparkScanModeJson)
            } catch {
                Log.error(error)
                result.reject(error: error)
                return
            }
            self.sparkScan = mode

            if !json.containsKey("SparkScanView") {
                let error = SparkScanError.json("Invalid json. Missing 'SparkScanView' key.", jsonString)
                Log.error(error)
                result.reject(error: error)
                return
            }
            let sparkScanViewJson = json.object(forKey: "SparkScanView").jsonString()
            do {
                let sparkScanView = try self.sparkScanViewDeserializer.view(fromJSONString: sparkScanViewJson,
                                                                            with: context,
                                                                            mode: mode,
                                                                            parentView: container)
                sparkScanView.viewWillAppear()
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
        let block = { [weak self] in
            guard let self = self else { return }
            guard let view = self.sparkScanView else {
                let error = SparkScanError.nilView
                Log.error(error)
                result.reject(error: error)
                return
            }
            let jsonValue = JSONValue(string: feedbackJson)
            var feedback: SparkScanViewFeedback
            let type = jsonValue.string(forKey: "type")

            var visualFeedbackColor: UIColor?
            if jsonValue.containsKey("visualFeedbackColor") {
                visualFeedbackColor = UIColor(sdcHexString: jsonValue.string(forKey: "visualFeedbackColor" ))
            }
            if type == "success" {
                feedback = visualFeedbackColor != nil ? SparkScanViewSuccessFeedback(visualFeedbackColor: visualFeedbackColor!) : SparkScanViewSuccessFeedback()
            } else {
                let timeinterval = jsonValue.timeinterval(forKey: "resumeCapturingDelay")
                if visualFeedbackColor != nil {
                    feedback = SparkScanViewErrorFeedback(message: jsonValue.string(forKey: "message"),
                                                          resumeCapturingDelay: timeinterval / 1000,
                                                          visualFeedbackColor: visualFeedbackColor!)
                } else {
                    feedback = SparkScanViewErrorFeedback(message: jsonValue.string(forKey: "message"),
                                                          resumeCapturingDelay: timeinterval / 1000)
                }
            }
            view.emitFeedback(feedback)
            result.success(result: nil)
        }
        dispatchMain(block)
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
            view.stopScanning()
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
        sparkScan?.isEnabled = enabled
    }
    
    public func isModeEnabled() -> Bool {
        return sparkScan?.isEnabled == true
    }
}

extension SparkScanModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        dataCaptureContext = context
    }
}
