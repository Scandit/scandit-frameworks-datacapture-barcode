/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksBarcodeSelectionTrackedBrushProviderEvent: String, CaseIterable {
    case brushForBarcode = "BarcodeSelectionTrackedBrushProvider.brushForBarcode"
}

open class FrameworksBarcodeSelectionTrackedBrushProvider: NSObject, BarcodeSelectionBrushProvider {
    private let emitter: Emitter
    private let queue: DispatchQueue

    private let brushForBarcodeEvent = Event(name: FrameworksBarcodeSelectionTrackedBrushProviderEvent.brushForBarcode.rawValue)

    private var cachedBrushes: [String: Brush] = [:]

    public init(emitter: Emitter, queue: DispatchQueue) {
        self.emitter = emitter
        self.queue = queue
    }

    public func brush(for barcode: Barcode) -> Brush? {
        if let brush = queue.sync(execute: { cachedBrushes[barcode.selectionIdentifier] }) {
            return brush
        }
        brushForBarcodeEvent.emit(on: emitter, payload: ["barcode": barcode.jsonString])
        return .transparent
    }

    public func finishCallback(brushJson: String?, selectionIdentifier: String?) {
        guard let selectionIdentifier = selectionIdentifier,
              let brushJson = brushJson, let brush = Brush(jsonString: brushJson) else { return }
        queue.async {
            self.cachedBrushes[selectionIdentifier] = brush
        }
    }

    public func clearCache() {
        cachedBrushes.removeAll()
    }
}
