/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksSparkScanViewUIEvent: String, CaseIterable  {
    case barcodeFindButtonTapped = "SparkScanViewUiListener.barcodeFindButtonTapped"
    case barcodeCountButtonTapped = "SparkScanViewUiListener.barcodeCountButtonTapped"
    case didChangeViewState = "SparkScanViewUiListener.didChangeViewState"
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

    private let didChangeViewStateEvent = Event(.didChangeViewState)
    private let barcodeFindButtonTappedEvent = Event(.barcodeFindButtonTapped)
    private let barcodeCountButtonTappedEvent = Event(.barcodeCountButtonTapped)

    private var isEnabled = AtomicBool()

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
    }
    
    public func sparkScanView(_ view: SparkScanView, didChange viewState: SparkScanViewState) {
        guard isEnabled.value, emitter.hasListener(for: didChangeViewStateEvent) else { return }
        didChangeViewStateEvent.emit(on: emitter, payload: ["state" : viewState.jsonString])
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
