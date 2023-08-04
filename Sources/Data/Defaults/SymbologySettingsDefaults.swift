/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

 import ScanditBarcodeCapture
 import ScanditFrameworksCore

public struct SymbologySettingsDefaults: DefaultsEncodable {
    private let barcodeCaptureSettings: BarcodeCaptureSettings

    init(barcodeCaptureSettings: BarcodeCaptureSettings) {
        self.barcodeCaptureSettings = barcodeCaptureSettings
    }

    public func toEncodable() -> [String: Any?] {
        let settingsTuples = SymbologyDescription.all.map {
            ($0.identifier, barcodeCaptureSettings.settings(for: $0.symbology).jsonString)
        }
        return Dictionary(uniqueKeysWithValues: settingsTuples) as [String: Any]
    }
 }
