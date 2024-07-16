/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BrushAndTrackedBarcode {
    let brush: Brush?
    let trackedBarcodeId: Int
    let sessionFrameSequenceId: Int?

    init(_ brush: Brush?, _ trackedBarcodeId: Int, _ sessionFrameSequenceId: Int?) {
        self.brush = brush
        self.trackedBarcodeId = trackedBarcodeId
        self.sessionFrameSequenceId = sessionFrameSequenceId
    }

    init(jsonValue: JSONValue) {
        let brush = Brush(jsonString: jsonValue.string(forKey: "brush"))
        let trackedBarcodeId = jsonValue.integer(forKey: "trackedBarcodeID")
        var sessionFrameSequenceId: Int?
        if jsonValue.containsKey("sessionFrameSequenceID") {
            sessionFrameSequenceId = jsonValue.integer(forKey: "sessionFrameSequenceID")
        }
        self.init(brush, trackedBarcodeId, sessionFrameSequenceId)
    }
}
