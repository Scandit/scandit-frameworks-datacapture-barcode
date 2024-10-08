/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCountSettingsDefaults: DefaultsEncodable {
    let barcodeCountSettings: BarcodeCountSettings

    func toEncodable() -> [String: Any?] {
        [
            "barcodeFilterSettings": BarcodeFilterSettingsDefaults(barcodeFilterSettings: barcodeCountSettings.filterSettings).toEncodable(),
            "expectOnlyUniqueBarcodes": barcodeCountSettings.expectsOnlyUniqueBarcodes,
            "mappingEnabled": barcodeCountSettings.mappingEnabled
        ]
    }
}
