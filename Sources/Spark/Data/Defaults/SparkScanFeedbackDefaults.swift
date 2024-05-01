/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct SparkScanFeedbackDefaults: DefaultsEncodable {
    let successFeedback: SparkScanBarcodeSuccessFeedback
    let errorFeedback: SparkScanBarcodeErrorFeedback

    func toEncodable() -> [String: Any?] {
        [
            "success": successFeedback.jsonString,
            "error": errorFeedback.jsonString
        ]
    }
}
