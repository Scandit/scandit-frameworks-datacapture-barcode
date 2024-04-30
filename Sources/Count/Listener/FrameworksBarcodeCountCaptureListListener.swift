/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class FrameworksBarcodeCountCaptureListListener: NSObject, BarcodeCountCaptureListListener {
    private enum Constants {
        static let sessionUpdated = "BarcodeCountCaptureListListener.didUpdateSession"
    }

    private let emitter: Emitter
    private let sessionUpdatedEvent = Event(name: Constants.sessionUpdated)

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func captureList(_ captureList: BarcodeCountCaptureList,
                            didUpdate session: BarcodeCountCaptureListSession) {
        sessionUpdatedEvent.emit(on: emitter, payload: ["session": session.jsonString])
    }
}
