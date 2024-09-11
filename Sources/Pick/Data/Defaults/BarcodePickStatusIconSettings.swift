/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct BarcodePickStatusIconSettingsDefaults: DefaultsEncodable {
    private let settings: BarcodePickStatusIconSettings

    func toEncodable() -> [String: Any?] {
        [
            "ratioToHighlightSize": settings.ratioToHighlightSize,
            "minSize": settings.minSize,
            "maxSize": settings.maxSize
        ]
    }

    static let shared: BarcodePickStatusIconSettingsDefaults = {
        BarcodePickStatusIconSettingsDefaults(settings: BarcodePickStatusIconSettings())
    }()
}
