/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import Foundation

class BarcodeCountStatusProviderRequest {
    let barcodes: [TrackedBarcode]
    let callback: BarcodeCountStatusProviderCallback
    let requestId: String

    init(barcodes: [TrackedBarcode], callback: BarcodeCountStatusProviderCallback) {
        self.barcodes = barcodes
        self.callback = callback
        self.requestId = UUID().uuidString
    }

    static let ID = "requestId"
}
