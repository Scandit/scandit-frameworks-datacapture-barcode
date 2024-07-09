/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

public enum FrameworksBarcodeFindEvent: String, CaseIterable {
    case didStartSearch = "FrameworksBarcodeFindListener.onSearchStarted"
    case didPauseSearch = "FrameworksBarcodeFindListener.onSearchPaused"
    case didStopSearch = "FrameworksBarcodeFindListener.onSearchStopped"
    case finishButtonTapped = "FrameworksBarcodeFindViewUiListener.onFinishButtonTapped"
}

extension Emitter {
    func hasListener(for event: FrameworksBarcodeFindEvent) -> Bool {
        hasListener(for: event.rawValue)
    }
}

extension Event {
    init(_ event: FrameworksBarcodeFindEvent) {
        self.init(name: event.rawValue)
    }
}

public class FrameworksBarcodeFindListener: NSObject, BarcodeFindListener {
    private let emitter: Emitter
    private var isEnabled = AtomicBool()
    private let didStartSearchEvent = Event(.didStartSearch)
    private let didPauseSearchEvent = Event(.didPauseSearch)
    private let didStopSearchEvent = Event(.didStopSearch)

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func enable() {
        if isEnabled.value { return }
        isEnabled.value = true
    }

    public func disable() {
        if isEnabled.value {
            isEnabled.value = false
        }
    }

    public func barcodeFindDidStartSearch(_ barcodeFind: BarcodeFind) {
        guard isEnabled.value, emitter.hasListener(for: .didStartSearch) else { return }
        dispatchMain { [weak self] in
            guard let self else { return }
            self.didStartSearchEvent.emit(on: self.emitter, payload: [:])
        }
    }

    public func barcodeFind(_ barcodeFind: BarcodeFind, didPauseSearch foundItems: Set<BarcodeFindItem>) {
        guard isEnabled.value, emitter.hasListener(for: .didPauseSearch) else { return }
        let foundItemsBarcodeData = foundItems.map { $0.searchOptions.barcodeData }
        dispatchMain { [weak self] in
            guard let self else { return }
            self.didPauseSearchEvent.emit(on: self.emitter, payload: ["foundItems": foundItemsBarcodeData])
        }
    }

    public func barcodeFind(_ barcodeFind: BarcodeFind, didStopSearch foundItems: Set<BarcodeFindItem>) {
        guard isEnabled.value, emitter.hasListener(for: .didStopSearch) else { return }
        let foundItemsBarcodeData = foundItems.map { $0.searchOptions.barcodeData }
        dispatchMain { [weak self] in
            guard let self else { return }
            self.didStopSearchEvent.emit(on: self.emitter, payload: ["foundItems": foundItemsBarcodeData])
        }
    }
}
