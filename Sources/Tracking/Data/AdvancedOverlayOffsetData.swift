/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditCaptureCore
import ScanditBarcodeCapture
import ScanditFrameworksCore

struct AdvancedOverlayOffsetData {
    let offset: PointWithUnit
    let trackedBarcodeId: Int
    let sessionFrameSequenceId: Int?

    init(offset: PointWithUnit, trackedBarcodeId: Int, sessionFrameSequenceId: Int?) {
        self.offset = offset
        self.trackedBarcodeId = trackedBarcodeId
        self.sessionFrameSequenceId = sessionFrameSequenceId
    }

    init(dictionary: [String: Any?]) {
        var offset: PointWithUnit = .zero
        SDCPointWithUnitFromJSONString(dictionary["offset"] as! String, &offset)
        self.init(offset: offset,
                  trackedBarcodeId: dictionary["identifier"] as! Int,
                  sessionFrameSequenceId: dictionary["sessionFrameSequenceID"] as? Int)
    }
}
