/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */


import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodePickViewUiListenerEvents: String, CaseIterable {
    case didTapFinishButton = "BarcodePickViewUiListener.didTapFinishButton"
}

fileprivate extension Emitter {
    func emit(_ event: BarcodePickViewUiListenerEvents, payload: [String: Any?]) {
        emit(name: event.rawValue, payload: payload)
    }
    
    func hasListener(for event: BarcodePickViewUiListenerEvents) -> Bool {
        hasListener(for: event.rawValue)
    }
}

class FrameworksBarcodePickViewUiListener : NSObject, BarcodePickViewUIDelegate {
    private let emitter: Emitter
    private var isEnabled = AtomicBool()

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
    
    func barcodePickViewDidTapFinishButton(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewUiListenerEvents.didTapFinishButton) else { return }
        emitter.emit(.didTapFinishButton, payload: [:])
    }
}
