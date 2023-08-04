/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeSelectionAimerSelectionDefaults: DefaultsEncodable {
    let aimerSelection: BarcodeSelectionAimerSelection

    func toEncodable() -> [String: Any?] {
        [
            "defaultSelectionStrategy": aimerSelection.selectionStrategy.jsonString
        ]
    }
}
