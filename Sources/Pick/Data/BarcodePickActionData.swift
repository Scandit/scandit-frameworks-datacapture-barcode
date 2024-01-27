/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodePickActionData {
    let pickActionData: String
    let result: Bool

    init(jsonString: String) {
        let jsonValue = JSONValue(string: jsonString)
        self.pickActionData = jsonValue.string(forKey: "itemData")
        self.result = jsonValue.bool(forKey: "result")
    }
}
