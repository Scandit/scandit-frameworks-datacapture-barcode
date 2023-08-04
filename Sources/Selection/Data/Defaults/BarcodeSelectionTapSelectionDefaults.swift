/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeSelectionTapSelectionDefaults: DefaultsEncodable {
    let tapSelection: BarcodeSelectionTapSelection

    func toEncodable() -> [String: Any?] {
        [
            "defaultFreezeBehaviour": tapSelection.freezeBehavior.jsonString,
            "defaultTapBehaviour": tapSelection.tapBehavior.jsonString
        ]
    }
}
