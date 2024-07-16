/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

open class FrameworksBarcodeFindTransformer: NSObject, BarcodeFindTransformer {
   
    private let emitter: Emitter
    
    private let onTransformBarcodeData = EventWithResult<String?>(event: Event(.transformBarcodeData))

    public init(emitter: Emitter) {
        self.emitter = emitter
        // Increase timeout to wait for result
        onTransformBarcodeData.timeout = 100
    }

    public func transformBarcodeData(_ data: String) -> String? {
        return onTransformBarcodeData.emit(on: emitter, payload: ["data": data]) ?? nil
    }

    public func submitResult(result: String?) {
        onTransformBarcodeData.unlock(value: result)
    }
}
