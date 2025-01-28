/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class BarcodeCheckModule: NSObject, FrameworkModule, DeserializationLifeCycleObserver {
    private let barcodeCheckListener: FrameworksBarcodeCheckListener
    private let barcodeCheckViewUiDelegate: FrameworksBarcodeCheckViewUiListener
    private let deserializer: BarcodeCheckDeserializer
    private let viewDeserialzier: BarcodeCheckViewDeserializer
    private let highlightProvider: FrameworksBarcodeCheckHighlightProvider
    private let annotationProvider: FrameworksBarcodeCheckAnnotationProvider
    private let augmentationsCache: BarcodeCheckAugmentationsCache

    public init(emitter: Emitter) {
        self.deserializer = BarcodeCheckDeserializer()
        self.viewDeserialzier = BarcodeCheckViewDeserializer()
        self.augmentationsCache = BarcodeCheckAugmentationsCache()

        self.barcodeCheckViewUiDelegate = FrameworksBarcodeCheckViewUiListener(emitter: emitter)
        self.barcodeCheckListener = FrameworksBarcodeCheckListener(emitter: emitter, cache: augmentationsCache)
        self.highlightProvider = FrameworksBarcodeCheckHighlightProvider(
            emitter: emitter,
            parser: BarcodeCheckHighlightParser(emitter: emitter),
            cache: augmentationsCache
        )
        self.annotationProvider = FrameworksBarcodeCheckAnnotationProvider(
            emitter: emitter,
            parser: BarcodeCheckAnnotationParser(emitter: emitter, cache: augmentationsCache),
            cache: augmentationsCache
        )
    }

    private var context: DataCaptureContext?

    public var barcodeCheckView: BarcodeCheckView?

    private var barcodeCheck: BarcodeCheck? {
        willSet {
            barcodeCheck?.removeListener(barcodeCheckListener)
        }
        didSet {
            barcodeCheck?.addListener(barcodeCheckListener)
        }
    }

    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }

    public func didStop() {
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
        cleanup()
    }

    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }

    public func didDisposeDataCaptureContext() {
        self.context = nil
        cleanup()
    }

    private func cleanup() {
        augmentationsCache.clear()
        if let view = self.barcodeCheckView {
            view.stop()
            view.uiDelegate = nil
            view.highlightProvider = nil
            view.annotationProvider = nil
            view.removeFromSuperview()
        }
        self.barcodeCheckView = nil

        self.barcodeCheck?.removeListener(barcodeCheckListener)
        self.barcodeCheck = nil
    }

    public let defaults: DefaultsEncodable = BarcodeCheckDefaults.shared

    public func registerBarcodeCheckViewUiListener(result: FrameworksResult) {
        self.barcodeCheckView?.uiDelegate = self.barcodeCheckViewUiDelegate
        result.success()
    }

    public func unregisterBarcodeCheckViewUiListener(result: FrameworksResult) {
        self.barcodeCheckView?.uiDelegate = nil
        result.success()
    }

    public func registerBarcodeCheckHighlightProvider(result: FrameworksResult) {
        self.barcodeCheckView?.highlightProvider = self.highlightProvider
        result.success()
    }

    public func unregisterBarcodeCheckHighlightProvider(result: FrameworksResult) {
        self.barcodeCheckView?.highlightProvider = nil
        result.success()
    }

    public func registerBarcodeCheckAnnotationProvider(result: FrameworksResult) {
        self.barcodeCheckView?.annotationProvider = self.annotationProvider
        result.success()
    }

    public func unregisterBarcodeCheckAnnotationProvider(result: FrameworksResult) {
        self.barcodeCheckView?.annotationProvider = nil
        result.success()
    }

    public func updateFeedback(feedbackJson: String, result: FrameworksResult) {
        do {
            barcodeCheck?.feedback = try BarcodeCheckFeedback(fromJSONString: feedbackJson)
            result.success(result: nil)
        } catch {
            result.reject(error: error)
        }
    }

    public func resetLatestBarcodeCheckSession(result: FrameworksResult) {
        barcodeCheckListener.resetSession()
        result.success()
    }

    public func applyBarcodeCheckModeSettings(modeSettingsJson: String, result: FrameworksResult) {
        guard let mode = barcodeCheck else {
            result.success()
            return
        }

        do {
            let settings = try self.deserializer.settings(fromJSONString: modeSettingsJson)
            mode.apply(settings)

            result.success()
        } catch {
            result.reject(error: error)
        }
    }

    public func addModeListener(result: FrameworksResult) {
        barcodeCheckListener.enable()
        result.success()
    }

    public func removeModeListener(result: FrameworksResult) {
        barcodeCheckListener.disable()
        result.success()
    }

    public func finishDidUpdateSession(result: FrameworksResult) {
        barcodeCheckListener.finishDidUpdateSession()
        result.success()
    }

    public func getLastFrameDataBytes(frameId: String, result: FrameworksResult) {
        LastFrameData.shared.getLastFrameDataBytes(frameId: frameId) {
            result.success(result: $0)
        }
    }

    public func finishHighlightForBarcode(highlightJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            self.highlightProvider.finishHighlightForBarcode(highlightJson: highlightJson)
        }
        dispatchMain(block)
        result.success()
    }

    public func finishAnnotationForBarcode(annotationJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            self.annotationProvider.finishAnnotationForBarcode(annotationJson: annotationJson)
        }
        dispatchMain(block)
        result.success()
    }

    public func updateBarcodeCheckPopoverButtonAtIndex(updateJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            self.annotationProvider.updateBarcodeCheckPopoverButtonAtIndex(updateJson: updateJson)
        }
        dispatchMain(block)
        result.success()
    }

    public func updateHighlight(highlightJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            self.highlightProvider.updateHighlight(highlightJson: highlightJson)
        }
        dispatchMain(block)
        result.success()
    }

    public func updateAnnotation(annotationJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            self.annotationProvider.updateAnnotation(annotationJson: annotationJson)
        }
        dispatchMain(block)
        result.success()
    }
}

public extension BarcodeCheckModule {

    // swiftlint:disable function_body_length
    func addViewToContainer(container: UIView, jsonString: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let context = self.context else {
                result.reject(error: ScanditFrameworksCoreError.nilDataCaptureContext)
                return
            }
            let json = JSONValue(string: jsonString)
            guard json.containsKey("BarcodeCheck"), json.containsKey("View") else {
                result.reject(error: ScanditFrameworksCoreError.deserializationError(error: nil,
                                                                                     json: jsonString))
                return
            }
            let barcodeCheckJson = json.object(forKey: "BarcodeCheck")

            do {
                let barcodeCheck = try self.deserializer.mode(fromJSONString: barcodeCheckJson.jsonString(),
                                                             context: context)
                self.barcodeCheck = barcodeCheck

                let barcodeCheckViewJson = json.object(forKey: "View")
                let hasUiListener = barcodeCheckViewJson.bool(forKey: "hasUiListener", default: false)
                let hasHighlightProvider = barcodeCheckViewJson.bool(forKey: "hasHighlightProvider", default: false)
                let hasAnnotationProvider = barcodeCheckViewJson.bool(forKey: "hasAnnotationProvider", default: false)
                let isStarted = barcodeCheckViewJson.bool(forKey: "isStarted", default: false)

                barcodeCheckViewJson.removeKeys(
                    ["hasUiListener", "hasHighlightProvider", "hasAnnotationProvider", "isStarted"]
                )
                let barcodeCheckView = try self.viewDeserialzier.view(
                    fromJSONString: barcodeCheckViewJson.jsonString(),
                    parentView: container,
                    mode: barcodeCheck
                )

                self.barcodeCheckView = barcodeCheckView
                if hasUiListener {
                    self.registerBarcodeCheckViewUiListener(result: NoopFrameworksResult())
                }
                if hasHighlightProvider {
                    self.registerBarcodeCheckHighlightProvider(result: NoopFrameworksResult())
                }
                if hasAnnotationProvider {
                    self.registerBarcodeCheckAnnotationProvider(result: NoopFrameworksResult())
                }
                if isStarted {
                    self.viewStart(result: NoopFrameworksResult())
                }
                result.success(result: nil)
            } catch let error {
                result.reject(error: ScanditFrameworksCoreError.deserializationError(error: error,
                                                                                     json: nil))
                return
            }
        }
        dispatchMain(block)
    }
    // swiftlint:enable function_body_length

    func updateView(viewJson: String, result: FrameworksResult) {
        let block = { [weak self] in
            guard let self = self else {
                result.reject(error: ScanditFrameworksCoreError.nilSelf)
                return
            }
            guard let view = self.barcodeCheckView else {
                result.reject(code: "-3", message: "BarcodeCheckView is nil", details: nil)
                return
            }
            do {
                self.barcodeCheckView = try self.viewDeserialzier.update(view, fromJSONString: viewJson)
            } catch let error {
                result.reject(error: error)
                return
            }
        }
        dispatchMain(block)
    }

    func viewStart(result: FrameworksResult) {
        self.barcodeCheckView?.start()
        result.success()
    }

    func viewStop(result: FrameworksResult) {
        self.barcodeCheckView?.stop()
        result.success()
    }

    func viewPause(result: FrameworksResult) {
        self.barcodeCheckView?.pause()
        result.success()
    }
}
