/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct BarcodePickDefaults: DefaultsEncodable {
    private let recommendedCameraSettings: CameraSettingsDefaults
    private let settingsDefaults: FrameworksBarcodePickSettingsDefaults
    private let viewSettingsDefaults: FrameworksBarcodePickViewDefaults
    private let barcodePickViewHighlightStyleDefaults: BarcodePickViewHighlightStyleDefaults
    private let barcodePickSymbologySettingsDefaults: BarcodePickSymbologySettingsDefaults
    private let barcodePickStatusIconSettingsDefaults: BarcodePickStatusIconSettingsDefaults

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodePickSettings": settingsDefaults.toEncodable(),
            "ViewSettings": viewSettingsDefaults.toEncodable(),
            "BarcodePickViewHighlightStyle": barcodePickViewHighlightStyleDefaults.toEncodable(),
            "SymbologySettings": barcodePickSymbologySettingsDefaults.toEncodable(),
            "BarcodePickStatusIconSettingsDefaults": barcodePickStatusIconSettingsDefaults.toEncodable()
        ]
    }

    static let shared: BarcodePickDefaults = {
        BarcodePickDefaults(
            recommendedCameraSettings: CameraSettingsDefaults(
                cameraSettings: BarcodePick.recommendedCameraSettings
            ),
            settingsDefaults: FrameworksBarcodePickSettingsDefaults(barcodePickSettings: BarcodePickSettings()),
            viewSettingsDefaults: FrameworksBarcodePickViewDefaults(),
            barcodePickViewHighlightStyleDefaults: .shared,
            barcodePickSymbologySettingsDefaults: .shared,
            barcodePickStatusIconSettingsDefaults: .shared
        )
    }()
}
