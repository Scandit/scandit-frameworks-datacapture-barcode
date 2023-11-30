/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class BarcodeCaptureModule: NSObject, FrameworkModule {
    private let barcodeCaptureDeserializer: BarcodeCaptureDeserializer
    private let barcodeCaptureListener: FrameworksBarcodeCaptureListener
    private var modeEnabled = true

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
        barcodeCaptureDeserializer.delegate = self
        Deserializers.Factory.add(barcodeCaptureDeserializer)
    }

    public func didStop() {
        barcodeCaptureDeserializer.delegate = nil
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
