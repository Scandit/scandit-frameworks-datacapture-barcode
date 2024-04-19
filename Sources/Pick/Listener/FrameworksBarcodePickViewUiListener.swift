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

open class FrameworksBarcodePickViewUiListener : NSObject, BarcodePickViewUIDelegate {
    private let emitter: Emitter
    private var isEnabled = AtomicBool()

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func enable() {
        if isEnabled.value { return }
        isEnabled.value = true
    }

    public func disable() {
        guard isEnabled.value else { return }
        isEnabled.value = false
    }
    
    public func barcodePickViewDidTapFinishButton(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewUiListenerEvents.didTapFinishButton) else { return }
        emitter.emit(.didTapFinishButton, payload: [:])
    }
}
