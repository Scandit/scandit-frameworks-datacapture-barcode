/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeCaptureDefaults: DefaultsEncodable {
    private let recommendedCameraSettings: CameraSettingsDefaults
    private let barcodeCaptureSettingsDefaults: BarcodeCaptureSettingsDefaults
    private let barcodeCaptureOverlayDefaults: BarcodeCaptureOverlayDefaults

    static let shared: BarcodeCaptureDefaults = {
        let cameraSettingsDefaults = CameraSettingsDefaults(cameraSettings: BarcodeCapture.recommendedCameraSettings)
        let barcodeCaptureSettingsDefaults = BarcodeCaptureSettingsDefaults(barcodeCaptureSettings: BarcodeCaptureSettings())

        let settings = BarcodeCaptureSettings()
        let mode = BarcodeCapture(context: nil, settings: settings)
        let overlay = BarcodeCaptureOverlay(barcodeCapture: mode)
        let barcodeCaptureOverlayDefaults = BarcodeCaptureOverlayDefaults(defaultStyle: overlay.style)
        return BarcodeCaptureDefaults(recommendedCameraSettings: cameraSettingsDefaults,
                                      barcodeCaptureSettingsDefaults: barcodeCaptureSettingsDefaults,
                                      barcodeCaptureOverlayDefaults: barcodeCaptureOverlayDefaults)
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeCaptureSettings": barcodeCaptureSettingsDefaults.toEncodable(),
            "BarcodeCaptureOverlay": barcodeCaptureOverlayDefaults.toEncodable()
        ]
    }
}
