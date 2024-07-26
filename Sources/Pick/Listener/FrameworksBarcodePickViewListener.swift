/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */


import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodePickViewListenerEvents: String, CaseIterable {
    case didStartScanning = "BarcodePickViewListener.didStartScanning"
    case didFreezeScanning = "BarcodePickViewListener.didFreezeScanning"
    case didPauseScanning = "BarcodePickViewListener.didPauseScanning"
    case didStopScanning = "BarcodePickViewListener.didStopScanning"
}

fileprivate extension Emitter {
    func emit(_ event: BarcodePickViewListenerEvents, payload: [String: Any?]) {
        emit(name: event.rawValue, payload: payload)
    }
    
    func hasListener(for event: BarcodePickViewListenerEvents) -> Bool {
        hasListener(for: event.rawValue)
    }
}

open class FrameworksBarcodePickViewListener : NSObject, BarcodePickViewListener {
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
    
    public func barcodePickViewDidFreezeScanning(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewListenerEvents.didFreezeScanning) else { return }
        emitter.emit(.didFreezeScanning, payload: [:])
    }
    
    public func barcodePickViewDidStopScanning(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewListenerEvents.didStopScanning) else { return }
        emitter.emit(.didStopScanning, payload: [:])
    }
    
    public func barcodePickViewDidPauseScanning(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewListenerEvents.didPauseScanning) else { return }
        emitter.emit(.didPauseScanning, payload: [:])
    }
    
    public func barcodePickViewDidStartScanning(_ view: BarcodePickView) {
        guard isEnabled.value else { return }
        guard emitter.hasListener(for: BarcodePickViewListenerEvents.didStartScanning) else { return }
        emitter.emit(.didStartScanning, payload: [:])
    }
}
