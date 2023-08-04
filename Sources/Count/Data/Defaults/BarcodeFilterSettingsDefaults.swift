/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeFilterSettingsDefaults: DefaultsEncodable {
    let barcodeFilterSettings: BarcodeFilterSettings

    func toEncodable() -> [String: Any?] {
        [
            "excludeEan13": barcodeFilterSettings.excludeEAN13,
            "excludeUpca": barcodeFilterSettings.excludeUPCA,
            "excludedCodesRegex": barcodeFilterSettings.excludedCodesRegex,
            "excludedSymbolCounts": barcodeFilterSettings.excludedSymbolCounts.mapValues { Array($0) },
            "excludedSymbologies": Array(barcodeFilterSettings.excludedSymbologies)
        ]
    }
}
