/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksSparkScanViewUIEvent: String, CaseIterable  {
    case fastFindButtonTapped = "SparkScanViewUiListener.fastFindButtonTapped"
    case barcodeFindButtonTapped = "SparkScanViewUiListener.barcodeFindButtonTapped"
    case barcodeCountButtonTapped = "SparkScanViewUiListener.barcodeCountButtonTapped"
}

fileprivate extension Event {
    init(_ event: FrameworksSparkScanViewUIEvent) {
        self.init(name: event.rawValue)
    }
}

open class FrameworksSparkScanViewUIListener: NSObject, SparkScanViewUIDelegate {

    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private let fastFindButtonTappedEvent = Event(.fastFindButtonTapped)
    private let barcodeFindButtonTappedEvent = Event(.barcodeFindButtonTapped)
    private let barcodeCountButtonTappedEvent = Event(.barcodeCountButtonTapped)

    private var isEnabled = AtomicBool()

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
    }

    public func fastFindButtonTapped(in view: SparkScanView) {
        guard isEnabled.value, emitter.hasListener(for: fastFindButtonTappedEvent) else { return }
        fastFindButtonTappedEvent.emit(on: emitter, payload: [:])
    }

    public func barcodeCountButtonTapped(in view: SparkScanView) {
        guard isEnabled.value, emitter.hasListener(for: barcodeCountButtonTappedEvent) else { return }
        barcodeCountButtonTappedEvent.emit(on: emitter, payload: [:])
    }
    
    public func barcodeFindButtonTapped(in view: SparkScanView) {
        guard isEnabled.value, emitter.hasListener(for: barcodeFindButtonTappedEvent) else { return }
        barcodeFindButtonTappedEvent.emit(on: emitter, payload: [:])
    }
}
