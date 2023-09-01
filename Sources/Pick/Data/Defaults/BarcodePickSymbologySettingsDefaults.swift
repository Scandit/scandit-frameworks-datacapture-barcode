/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct BarcodePickSymbologySettingsDefaults: DefaultsEncodable {
    private let settings: BarcodePickSettings

    func toEncodable() -> [String: Any?] {
        Dictionary(uniqueKeysWithValues: SymbologyDescription.all.map({
            ($0.identifier, settings.settings(for: $0.symbology).jsonString)
        }))
    }

    static let shared: BarcodePickSymbologySettingsDefaults = {
        BarcodePickSymbologySettingsDefaults(settings: BarcodePickSettings())
    }()
}
