/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCountDefaults: DefaultsEncodable {
    let recommendedCameraSettings: CameraSettingsDefaults
    let barcodeCountSettings: BarcodeCountSettingsDefaults
    let barcodeCountFeedback: BarcodeCountFeedback
    let barcodeCountView: DefaultsBarcodeCountView

    static let shared = {
        BarcodeCountDefaults(recommendedCameraSettings: CameraSettingsDefaults(cameraSettings: BarcodeCount.recommendedCameraSettings),
                             barcodeCountSettings: BarcodeCountSettingsDefaults(barcodeCountSettings: BarcodeCountSettings()),
                             barcodeCountFeedback: .default,
                             barcodeCountView: DefaultsBarcodeCountView(barcodeCountToolbarSettingsDefaults: BarcodeCountToolbarSettingsDefaults()))
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeCountSettings": barcodeCountSettings.toEncodable(),
            "BarcodeCountFeedback": barcodeCountFeedback.jsonString,
            "BarcodeCountView": barcodeCountView.toEncodable()
        ]
    }
}
