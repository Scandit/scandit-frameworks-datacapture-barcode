/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */


import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodePickScanningEvent: String, CaseIterable {
    case didUpdateScanningSession = "BarcodePickScanningListener.didUpdateScanningSession"
    case didCompleteScanningSession = "BarcodePickScanningListener.didCompleteScanningSession"
}

fileprivate extension Emitter {
    func emit(_ event: BarcodePickScanningEvent, payload: [String: Any?]) {
        emit(name: event.rawValue, payload: payload)
    }
    
    func hasListener(for event: BarcodePickScanningEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

class FrameworksBarcodePickScanningListener : NSObject, BarcodePickScanningListener {
    private var isEnabled = AtomicBool()
    private let emitter: Emitter

    init(emitter: Emitter) {
        self.emitter = emitter
    }

    func enable() {
        if isEnabled.value { return }
        isEnabled.value = true
    }

    func disable() {
        guard isEnabled.value else { return }
        isEnabled.value = false
    }
    
    func barcodePick(_ barcodePick: BarcodePick, didComplete scanningSession: BarcodePickScanningSession) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickScanningEvent.didCompleteScanningSession) else { return }
       
        emitter.emit(.didCompleteScanningSession, payload: ["session": scanningSession.jsonString])
    }
    
    func barcodePick(_ barcodePick: BarcodePick, didUpdate scanningSession: BarcodePickScanningSession) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickScanningEvent.didUpdateScanningSession) else { return }
       
        emitter.emit(.didUpdateScanningSession, payload: ["session": scanningSession.jsonString])
    }
}
