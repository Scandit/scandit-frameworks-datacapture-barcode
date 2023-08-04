/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksSparkScanViewUIListener: NSObject, SparkScanViewUIDelegate {
    private enum Constants {
        static let fastFindButtonTapped = "SparkScanViewUiListener.fastFindButtonTapped"
        static let barcodeCountButtonTapped = "SparkScanViewUiListener.barcodeCountButtonTapped"
    }

    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private let fastFindButtonTappedEvent = Event(name: Constants.fastFindButtonTapped)
    private let barcodeCountButtonTappedEvent = Event(name: Constants.barcodeCountButtonTapped)

    private var isEnabled = AtomicBool()

    func enable() {
        isEnabled.value = true
    }

    func disable() {
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
}
