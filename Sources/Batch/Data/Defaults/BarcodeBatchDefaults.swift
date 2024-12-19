/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeBatchDefaults: DefaultsEncodable {
    let recommendedCameraSettings: CameraSettingsDefaults
    let basicOverlayDefaults: BarcodeBatchBasicOverlayDefaults

    public static let shared: BarcodeBatchDefaults = {
        let mode = BarcodeBatch(context: nil, settings: BarcodeBatchSettings())
        let overlay = BarcodeBatchBasicOverlay(barcodeBatch: mode, view: nil)
        let overlayDefaults = BarcodeBatchBasicOverlayDefaults(defaultStyle: overlay.style)
        return BarcodeBatchDefaults(recommendedCameraSettings: CameraSettingsDefaults(cameraSettings: BarcodeBatch.recommendedCameraSettings),
                                       basicOverlayDefaults: overlayDefaults)
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeBatchBasicOverlay": basicOverlayDefaults.toEncodable()
        ]
    }
}
