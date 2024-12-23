/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

open class BarcodeFindModule: NSObject, FrameworkModule {
    private let listener: FrameworksBarcodeFindListener
    private let viewListener: FrameworksBarcodeFindViewUIListener
    private let barcodeTransformer: FrameworksBarcodeFindTransformer
    private let modeDeserializer: BarcodeFindDeserializer
    private let viewDeserializer: BarcodeFindViewDeserializer

    public init(listener: FrameworksBarcodeFindListener,
                viewListener: FrameworksBarcodeFindViewUIListener,
                barcodeTransformer: FrameworksBarcodeFindTransformer,
                modeDeserializer: BarcodeFindDeserializer = BarcodeFindDeserializer(),
                viewDeserializer: BarcodeFindViewDeserializer = BarcodeFindViewDeserializer()) {
        self.listener = listener
        self.viewListener = viewListener
        self.barcodeTransformer = barcodeTransformer
        self.modeDeserializer = modeDeserializer
        self.viewDeserializer = viewDeserializer
        super.init()
    }

    private var barcodeFind: BarcodeFind? {
        willSet {
            barcodeFind?.removeListener(listener)
        }
        didSet {
            barcodeFind?.addListener(listener)
        }
    }

    private var context: DataCaptureContext?

    private var modeEnabled = true
    
    private var barcodeFindFeedback: BarcodeFindFeedback?

    public var barcodeFindView: BarcodeFindView? {
        willSet {
            barcodeFindView?.uiDelegate = nil
        }
        didSet {
            barcodeFindView?.uiDelegate = viewListener
        }
    }

    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        barcodeFindView?.stopSearching()
        barcodeFindView?.removeFromSuperview()
        barcodeFind?.stop()
        barcodeFind = nil
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        context = nil
    }

    public let defaults: DefaultsEncodable = BarcodeFindDefaults.shared

    public func addViewToContainer(container: UIView, jsonString: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let context = self.context else {
                result.reject(error: ScanditFrameworksCoreError.nilDataCaptureContext)
                return
            }
            let jsonValue = JSONValue(string: jsonString)
            guard jsonValue.containsKey("BarcodeFind"), jsonValue.containsKey("View") else {
                result.reject(error: ScanditFrameworksCoreError.deserializationError(error: nil, json: jsonString))
                return
            }

            let barcodeFindModeJsonValue = jsonValue.object(forKey: "BarcodeFind")
            let barcodeFindModeJson = barcodeFindModeJsonValue.jsonString()
            let viewJsonValue = jsonValue.object(forKey: "View")
            let viewJson = viewJsonValue.jsonString()
            do {
                let mode = try self.modeDeserializer.mode(fromJSONString: barcodeFindModeJson)

                if barcodeFindModeJsonValue.containsKey("itemsToFind") {
                    let itemsToFind = barcodeFindModeJsonValue.string(forKey: "itemsToFind")
                    let data = BarcodeFindItemsData(jsonString: itemsToFind)
                    mode.setItemList(data.items)
                }

                self.barcodeFind = mode

                let view = try self.viewDeserializer.view(fromJSONString: viewJson,
                                                          with: context,
                                                          mode: mode,
                                                          parentView: container)
                view.prepareSearching()
                if viewJsonValue.containsKey("startSearching") &&
                    viewJsonValue.bool(forKey: "startSearching",
                                       default: false) {
                    view.startSearching()
                }
                self.barcodeFindView = view

                if barcodeFindModeJsonValue.bool(forKey: "hasBarcodeTransformer", default: false) {
                    self.barcodeFind?.setBarcodeTransformer(self.barcodeTransformer)
                }
                
                // update feedback in case the update call did run before the creation of the mode
                if let feedback = barcodeFindFeedback {
                    dispatchMain { [weak self] in
                        mode.feedback = feedback
                        self?.barcodeFindFeedback = nil
                    }
                }
            } catch {
                result.reject(error: error)
                return
            }
            result.success(result: nil)
        }
        dispatchMain(block)
    }

    public func updateBarcodeFindView(viewJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self, let view = self.barcodeFindView else {
                return
            }
            let viewJsonValue = JSONValue(string: viewJson)
            do {
                self.barcodeFindView = try self.viewDeserializer.update(view, fromJSONString: viewJson)
                if viewJsonValue.containsKey("startSearching") &&
                    viewJsonValue.bool(forKey: "startSearching",
                                       default: false) {
                    view.startSearching()
                }
                result.success(result: nil)
            } catch {
                Log.error("Error while updating the BarcodeFindView.", error: error)
                result.reject(error: error)
            }
        }
        dispatchMain(block)
    }

    public func updateBarcodeFindMode(modeJson: String, result: FrameworksResult) {
        guard let mode = barcodeFind else { return }
        do {
            barcodeFind = try self.modeDeserializer.updateMode(mode, fromJSONString: modeJson)
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

    public func addBarcodeFindListener(result: FrameworksResult) {
        listener.enable()
        result.success(result: nil)
    }

    public func removeBarcodeFindListener(result: FrameworksResult) {
        listener.disable()
        result.success(result: nil)
    }

    public func addBarcodeFindViewListener(result: FrameworksResult) {
        viewListener.enable()
        result.success(result: nil)
    }

    public func removeBarcodeFindViewListener(result: FrameworksResult) {
        viewListener.disable()
        result.success(result: nil)
    }

    public func setItemList(barcodeFindItemsJson: String, result: FrameworksResult) {
        let data = BarcodeFindItemsData(jsonString: barcodeFindItemsJson)
        barcodeFind?.setItemList(data.items)
        result.success(result: nil)
    }

    public func prepareSearching(result: FrameworksResult) {
        barcodeFindView?.prepareSearching()
        result.success(result: nil)
    }

    public func pauseSearching(result: FrameworksResult) {
        barcodeFindView?.pauseSearching()
        result.success(result: nil)
    }

    public func stopSearching(result: FrameworksResult) {
        barcodeFindView?.stopSearching()
        result.success(result: nil)
    }

    public func startSearching(result: FrameworksResult) {
        barcodeFindView?.startSearching()
        result.success(result: nil)
    }

    public func startMode(result: FrameworksResult) {
        barcodeFind?.start()
        result.success(result: nil)
    }

    public func stopMode(result: FrameworksResult) {
        barcodeFind?.stop()
        result.success(result: nil)
    }

    public func pauseMode(result: FrameworksResult) {
        barcodeFind?.pause()
        result.success(result: nil)
    }

    public func setModeEnabled(enabled: Bool) {
        modeEnabled = enabled
        barcodeFind?.isEnabled = enabled
    }

    public func isModeEnabled() -> Bool {
        return barcodeFind?.isEnabled == true
    }

    public func setBarcodeFindTransformer(result: FrameworksResult) {
        barcodeFind?.setBarcodeTransformer(self.barcodeTransformer)
        result.success(result: nil)
    }

    public func submitBarcodeFindTransformerResult(transformedData: String?, result: FrameworksResult) {
        self.barcodeTransformer.submitResult(result: transformedData)
        result.success(result: nil)
    }
    
    public func updateFeedback(feedbackJson: String, result: FrameworksResult) {
        do {
            barcodeFindFeedback = try BarcodeFindFeedback(fromJSONString: feedbackJson)
            // in case we don't have a mode yet, it will return success and cache the new
            // feedback to be applied after the creation of the view.
             if let mode = barcodeFind, let feedback = barcodeFindFeedback {
                mode.feedback = feedback
                barcodeFindFeedback = nil
            }
        
            result.success()
        } catch let error {
            result.reject(error: error)
        }
    }
}

extension BarcodeFindModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }
    
    public func didDisposeDataCaptureContext() {
        self.context = nil
        self.barcodeFindView = nil
        self.barcodeFind = nil
    }
}
