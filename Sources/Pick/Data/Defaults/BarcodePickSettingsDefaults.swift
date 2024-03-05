/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct FrameworksBarcodePickSettingsDefaults: DefaultsEncodable {
    func toEncodable() -> [String: Any?] {
        [
            "hapticsEnabled": BarcodePickSettingsDefaults.hapticsEnabled,
            "soundEnabled": BarcodePickSettingsDefaults.soundEnabled
        ]
    }
}
