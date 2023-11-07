/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

public class BarcodeFindModule: NSObject, FrameworkModule {
    private let listener: FrameworksBarcodeFindListener
    private let viewListener: FrameworksBarcodeFindViewUIListener
    private let modeDeserializer: BarcodeFindDeserializer
    private let viewDeserializer: BarcodeFindViewDeserializer

    public init(listener: FrameworksBarcodeFindListener,
                viewListener: FrameworksBarcodeFindViewUIListener,
                modeDeserializer: BarcodeFindDeserializer = BarcodeFindDeserializer(),
                viewDeserializer: BarcodeFindViewDeserializer = BarcodeFindViewDeserializer()) {
        self.listener = listener
        self.viewListener = viewListener
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

    private var barcodeFindView: BarcodeFindView? {
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
            let barcodeFindModeJson = jsonValue.object(forKey: "BarcodeFind").jsonString()
            let viewJson = jsonValue.object(forKey: "View").jsonString()
            do {
                let mode = try self.modeDeserializer.mode(fromJSONString: barcodeFindModeJson)
                self.barcodeFind = mode

                let view = try self.viewDeserializer.view(fromJSONString: viewJson,
                                                          with: context,
                                                          mode: mode,
                                                          parentView: container)
                self.barcodeFindView = view
            } catch {
                result.reject(error: error)
                return
            }
            result.success(result: nil)
        }
        dispatchMain(block)
    }

    public func updateBarcodeFindView(viewJson: String) {
        let block = { [weak self] in
            guard let self = self, let view = self.barcodeFindView else {
                return
            }
            do {
                self.barcodeFindView = try self.viewDeserializer.update(view, fromJSONString: viewJson)
            } catch {
                Log.error("Error while updating the BarcodeFindView.", error: error)
            }
        }
        dispatchMain(block)
    }

    public func updateBarcodeFindMode(modeJson: String) {
        guard let mode = barcodeFind else { return }
        do {
            barcodeFind = try self.modeDeserializer.updateMode(mode, fromJSONString: modeJson)
            let jsonValue = JSONValue(string: modeJson)
            if jsonValue.containsKey("enabled") {
                mode.isEnabled = jsonValue.bool(forKey: "enabled")
            }
        } catch {
            Log.error("Error while updating the BarcodeFind mode.", error: error)
        }
    }

    public func addBarcodeFindListener() {
        listener.enable()
    }

    public func removeBarcodeFindListener() {
        listener.disable()
    }

    public func addBarcodeFindViewListener() {
        viewListener.enable()
    }

    public func removeBarcodeFindViewListener() {
        viewListener.disable()
    }

    public func setItemList(barcodeFindItemsJson: String) {
        let data = BarcodeFindItemsData(jsonString: barcodeFindItemsJson)
        barcodeFind?.setItemList(data.items)
    }

    public func prepareSearching() {
        barcodeFindView?.prepareSearching()
    }

    public func pauseSearching() {
        barcodeFindView?.pauseSearching()
    }

    public func stopSearching() {
        barcodeFindView?.stopSearching()
    }

    public func startSearching() {
        barcodeFindView?.startSearching()
    }

    public func startMode() {
        barcodeFind?.start()
    }

    public func stopMode() {
        barcodeFind?.stop()
    }

    public func pauseMode() {
        barcodeFind?.pause()
    }
}

extension BarcodeFindModule: DeserializationLifeCycleObserver {
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }
}
