/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct FrameworksBarcodePickSettingsDefaults: DefaultsEncodable {
    let barcodePickSettings: BarcodePickSettings
    func toEncodable() -> [String: Any?] {
        [
            "hapticsEnabled": barcodePickSettings.isHapticsEnabled,
            "soundEnabled": barcodePickSettings.isSoundEnabled,
            "cachingEnabled": barcodePickSettings.isCachingEnabled
        ]
    }
}
