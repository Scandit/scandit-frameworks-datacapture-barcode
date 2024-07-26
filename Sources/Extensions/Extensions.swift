/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture

public extension ScanIntention {
    var jsonString : String {
        switch self {
        case .manual:
            return "manual"
        case .smart:
            return "smart"
        }
    }
}
