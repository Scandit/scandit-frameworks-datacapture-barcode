/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct SparkScanFeedbackDefaults: DefaultsEncodable {
    let feedback: SparkScanFeedback

    func toEncodable() -> [String: Any?] {
        [
            "success": feedback.success.jsonString,
            "error": feedback.error.jsonString
        ]
    }
}
