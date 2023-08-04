/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public struct BarcodeDefaults: DefaultsEncodable {
    private let symbologySettingsDefaults: [String: Any?]
    private let symbologyDescriptionDefaults: [String]
    private let compositeTypeDescriptions: [String]

    public static let shared: BarcodeDefaults = {
        let captureSettings = BarcodeCaptureSettings()
        let symbologyDescriptions = SymbologyDescription.all
        let compositeTypeDescriptions = CompositeTypeDescription.all
        return .init(symbologySettingsDefaults: SymbologySettingsDefaults(barcodeCaptureSettings: captureSettings).toEncodable(),
                     symbologyDescriptionDefaults: symbologyDescriptions.map { $0.jsonString },
                     compositeTypeDescriptions: compositeTypeDescriptions.map { $0.jsonString })
    }()

    init(symbologySettingsDefaults: [String: Any?],
         symbologyDescriptionDefaults: [String],
         compositeTypeDescriptions: [String]) {
        self.symbologySettingsDefaults = symbologySettingsDefaults
        self.symbologyDescriptionDefaults = symbologyDescriptionDefaults
        self.compositeTypeDescriptions = compositeTypeDescriptions
    }

    public func toEncodable() -> [String: Any?] {
        [
            "SymbologySettings": symbologySettingsDefaults,
            "SymbologyDescriptions": symbologyDescriptionDefaults,
            "CompositeTypeDescriptions": compositeTypeDescriptions
        ]
    }
}
