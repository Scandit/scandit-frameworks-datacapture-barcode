/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCountToolbarSettingsDefaults: DefaultsEncodable {
    func toEncodable() -> [String: Any?] {
        [
            "audioOnButtonText": BarcodeCountToolbarDefaults.audioOnButtonText,
            "audioOffButtonText": BarcodeCountToolbarDefaults.audioOffButtonText,
            "audioButtonAccessibilityHint": BarcodeCountToolbarDefaults.audioButtonAccessibilityHint,
            "audioButtonAccessibilityLabel": BarcodeCountToolbarDefaults.audioButtonAccessibilityLabel,
            "vibrationOnButtonText": BarcodeCountToolbarDefaults.vibrationOnButtonText,
            "vibrationOffButtonText": BarcodeCountToolbarDefaults.vibrationOffButtonText,
            "vibrationButtonAccessibilityHint": BarcodeCountToolbarDefaults.vibrationButtonAccessibilityHint,
            "vibrationButtonAccessibilityLabel": BarcodeCountToolbarDefaults.vibrationButtonAccessibilityLabel,
            "strapModeOnButtonText": BarcodeCountToolbarDefaults.strapModeOnButtonText,
            "strapModeOffButtonText": BarcodeCountToolbarDefaults.strapModeOffButtonText,
            "strapModeButtonAccessibilityHint": BarcodeCountToolbarDefaults.strapModeButtonAccessibilityHint,
            "strapModeButtonAccessibilityLabel": BarcodeCountToolbarDefaults.strapModeButtonAccessibilityLabel,
            "colorSchemeOnButtonText": BarcodeCountToolbarDefaults.colorSchemeOnButtonText,
            "colorSchemeOffButtonText": BarcodeCountToolbarDefaults.colorSchemeOffButtonText,
            "colorSchemeButtonAccessibilityHint": BarcodeCountToolbarDefaults.colorSchemeButtonAccessibilityHint,
            "colorSchemeButtonAccessibilityLabel": BarcodeCountToolbarDefaults.colorSchemeButtonAccessibilityLabel
        ]
    }
}
