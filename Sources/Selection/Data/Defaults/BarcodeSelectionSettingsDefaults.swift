/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeSelectionSettingsDefaults: DefaultsEncodable {
    let settings: BarcodeSelectionSettings

    func toEncodable() -> [String: Any?] {
        [
            "codeDuplicateFilter": Int(settings.codeDuplicateFilter * 1000),
            "singleBarcodeAutoDetectionEnabled": settings.singleBarcodeAutoDetection,
            "selectionType": settings.selectionType.jsonString
        ]
    }
}
