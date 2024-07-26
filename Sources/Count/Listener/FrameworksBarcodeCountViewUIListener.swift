/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class FrameworksBarcodeCountViewUIListener: NSObject, BarcodeCountViewUIDelegate {
    public enum Constants {
        public static let exitButtonTapped = "BarcodeCountViewUiListener.onExitButtonTapped"
        public static let listButtonTapped = "BarcodeCountViewUiListener.onListButtonTapped"
        public static let singleScanButtonTapped = "BarcodeCountViewUiListener.onSingleScanButtonTapped"
    }

    private let emitter: Emitter

    private let exitButtonTappedEvent = Event(name: Constants.exitButtonTapped)
    private let listButtonTappedEvent = Event(name: Constants.listButtonTapped)
    private let singleScanButtonTappedEvent = Event(name: Constants.singleScanButtonTapped)

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func exitButtonTapped(for view: BarcodeCountView) {
        exitButtonTappedEvent.emit(on: emitter, payload: [:])
    }

    public func listButtonTapped(for view: BarcodeCountView) {
        listButtonTappedEvent.emit(on: emitter, payload: [:])
    }

    public func singleScanButtonTapped(for view: BarcodeCountView) {
        singleScanButtonTappedEvent.emit(on: emitter, payload: [:])
    }
}
