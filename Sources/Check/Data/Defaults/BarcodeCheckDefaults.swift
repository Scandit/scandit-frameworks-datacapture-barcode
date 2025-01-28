/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCheckDefaults: DefaultsEncodable {
    let recommendedCameraSettings: CameraSettingsDefaults
    let barcodeCheckFeedback: BarcodeCheckFeedback
    let viewDefaults: DefaultsBarcodeCheckView

    static let shared = {
        BarcodeCheckDefaults(
            recommendedCameraSettings: CameraSettingsDefaults(cameraSettings: BarcodeCheck.recommendedCameraSettings),
            barcodeCheckFeedback: .default,
            viewDefaults: DefaultsBarcodeCheckView()
        )
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "barcodeCheckFeedback": barcodeCheckFeedback.jsonString,
            "BarcodeCheckView": viewDefaults.toEncodable()
        ]
    }
}
