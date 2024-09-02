/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCaptureSettingsDefaults: DefaultsEncodable {
    let barcodeCaptureSettings: BarcodeCaptureSettings

    func toEncodable() -> [String: Any?] {
        [
            "codeDuplicateFilter": Int(barcodeCaptureSettings.codeDuplicateFilter * 1000),
            "batterySavingMode": barcodeCaptureSettings.batterySavingMode.jsonString,
            "scanIntention": barcodeCaptureSettings.scanIntention.jsonString
        ]
    }
}
