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
            "codeDuplicateFilter": barcodeCaptureSettings.codeDuplicateFilter <= 0 ?
            barcodeCaptureSettings.codeDuplicateFilter : Int(barcodeCaptureSettings.codeDuplicateFilter * 1000),
            "batterySaving": barcodeCaptureSettings.batterySaving.jsonString,
            "scanIntention": barcodeCaptureSettings.scanIntention.jsonString
        ]
    }
}
