/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture

class AnnotationCallbackData {
    let barcode: Barcode
    let callback: ((any UIView & BarcodeCheckAnnotation)?) -> Void

    init(barcode: Barcode, callback: @escaping ((any UIView & BarcodeCheckAnnotation)?) -> Void) {
        self.barcode = barcode
        self.callback = callback
    }
}
