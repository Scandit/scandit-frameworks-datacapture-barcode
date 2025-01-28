/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodeCheckViewUiDelegateEvents: String, CaseIterable {
    case didTapHighlightForBarcodeEvent = "BarcodeCheckViewUiListener.didTapHighlightForBarcode"
}

open class FrameworksBarcodeCheckViewUiListener: NSObject, BarcodeCheckViewUIDelegate {
    private let emitter: Emitter

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private let didTapHighlightForBarcode = Event(
        name: BarcodeCheckViewUiDelegateEvents.didTapHighlightForBarcodeEvent.rawValue
    )

    public func barcodeCheck(
        _ barcodeCheck: BarcodeCheck, didTapHighlightFor barcode: Barcode, highlight: any UIView & BarcodeCheckHighlight
    ) {
        didTapHighlightForBarcode.emit(on: emitter, payload: [
            "barcode": barcode.jsonString,
            "barcodeId": barcode.uniqueId
        ])
    }

}
