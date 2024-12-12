/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeTrackingDefaults: DefaultsEncodable {
    let recommendedCameraSettings: CameraSettingsDefaults
    let basicOverlayDefaults: BarcodeTrackingBasicOverlayDefaults

    public static let shared: BarcodeTrackingDefaults = {
        let mode = BarcodeTracking(context: nil, settings: BarcodeTrackingSettings())
        let overlay = BarcodeTrackingBasicOverlay(barcodeTracking: mode, view: nil)
        let overlayDefaults = BarcodeTrackingBasicOverlayDefaults(defaultStyle: overlay.style)
        return BarcodeTrackingDefaults(recommendedCameraSettings: CameraSettingsDefaults(cameraSettings: BarcodeTracking.recommendedCameraSettings),
                                       basicOverlayDefaults: overlayDefaults)
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeTrackingBasicOverlay": basicOverlayDefaults.toEncodable()
        ]
    }
}
