/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

open class FrameworksBarcodeFindViewUIListener: NSObject, BarcodeFindViewUIDelegate {
    private let emitter: Emitter
    private var isEnabled = AtomicBool()
    private let didTapFinishButtonEvent = Event(.finishButtonTapped)

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    func enable() {
        if isEnabled.value { return }
        isEnabled.value = true
    }

    func disable() {
        if isEnabled.value {
            isEnabled.value = false
        }
    }

    public func barcodeFindView(_ view: BarcodeFindView,
                                didTapFinishButton foundItems: Set<BarcodeFindItem>) {
        guard isEnabled.value, emitter.hasListener(for: .finishButtonTapped) else { return }
        let foundItemsBarcodeData = foundItems.map { $0.searchOptions.barcodeData }
        didTapFinishButtonEvent.emit(on: emitter, payload: ["foundItems": foundItemsBarcodeData])
    }
}
