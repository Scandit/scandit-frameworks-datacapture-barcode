/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class BarcodePickModule: NSObject, FrameworkModule, DeserializationLifeCycleObserver {
    let emitter: Emitter
    var actionListener: FrameworksBarcodePickActionListener
    let deserializer = BarcodePickDeserializer()

    private var context: DataCaptureContext?
    public var barcodePickView: BarcodePickView? {
        willSet {
            barcodePickView?.removeActionListener(actionListener)
        }
        didSet {
            barcodePickView?.addActionListener(actionListener)
        }
    }
    private var barcodePick: BarcodePick?
    private var asyncMapperProductProviderCallback: FrameworksBarcodePickAsyncMapperProductProviderCallback?

    public init(emitter: Emitter) {
        self.emitter = emitter
        actionListener = FrameworksBarcodePickActionListener(emitter: emitter)
    }

    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        actionListener.disable()
        barcodePickView?.stop()
        context = nil
        barcodePickView?.removeFromSuperview()
    }

    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }

    public let defaults: DefaultsEncodable = BarcodePickDefaults.shared

    public func addViewToContainer(container: UIView, jsonString: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let context = self.context else {
                result.reject(
                    code: "-1",
                    message: "Error during the barcode pick view deserialization.\nError: The DataCaptureContext has not been initialized yet.",
                    details: nil
                )
                return
            }
            let json = JSONValue(string: jsonString)
            guard json.containsKey("BarcodePick"), json.containsKey("View") else {
                result.reject(
                    code: "-1",
                    message: "Error during the barcode pick view deserialization.\nError: Error: Json string doesn't contain `BarcodePick` or `View`",
                    details: nil
                )
                return
            }
            let barcodePickJson = json.object(forKey: "BarcodePick")
            let productMapperJson = barcodePickJson.object(forKey: "ProductProvider").jsonString()

            do {
                let delegate = FrameworksBarcodePickAsyncMapperProductProviderCallback(emitter: self.emitter)
                let productProvider = try self.deserializer.asyncMapperProductProvider(fromJSONString: productMapperJson,
                                                                                       delegate: delegate)
                self.asyncMapperProductProviderCallback = delegate
                self.barcodePick = try self.deserializer.mode(fromJSONString: barcodePickJson.jsonString(),
                                                         context: context,
                                                         productProvider: productProvider)
                let barcodePickViewJson = json.object(forKey: "View")
                let hasActionListeners = barcodePickViewJson.bool(forKey: "hasActionListeners", default: false)
                let isStarted = barcodePickViewJson.bool(forKey: "isStarted", default: false)
                barcodePickViewJson.removeKeys(["hasActionListeners", "isStarted"])
                self.barcodePickView = try self.deserializer.view(fromJSONString: barcodePickViewJson.jsonString(),
                                                             context: context,
                                                             mode: self.barcodePick!)
                container.addSubview(self.barcodePickView!)
                if hasActionListeners {
                    self.addActionListener()
                }
                if isStarted {
                    self.viewStart()
                }
                result.success(result: nil)
            } catch let error {
                result.reject(error: error)
                return
            }
        }
        dispatchMain(block)
    }

    public func updateView(viewJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let view = self.barcodePickView else {
                result.reject(code: "-3", message: "BarcodePickView is nil", details: nil)
                return
            }
            do {
                self.barcodePickView = try self.deserializer.update(view, fromJSONString: viewJson)
            } catch let error {
                result.reject(error: error)
                return
            }
        }
        dispatchMain(block)
    }

    public func addActionListener() {
        actionListener.enable()
    }

    public func removeActionListener() {
        actionListener.disable()
    }

    public func finishProductIdentifierForItems(barcodePickProductProviderCallbackItemsJson: String) {
        asyncMapperProductProviderCallback?.finishMapIdentifiersForEvents(
            itemsJson: barcodePickProductProviderCallbackItemsJson
        )
    }

    public func finishPickAction(data: String, result: Bool) {
        actionListener.finishPickAction(with: data, result: result)
    }

    public func viewStart() {
        barcodePickView?.start()
    }

    public func viewPause() {
        barcodePickView?.pause()
    }
}
