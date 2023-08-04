/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension Barcode {
    var selectionIdentifier: String {
        return "\(data ?? "")\(SymbologyDescription(symbology: symbology).identifier)"
    }
}

public class FrameworksBarcodeSelectionListener: NSObject, BarcodeSelectionListener {
    private enum Constants {
        static let didUpdateSelection = "BarcodeSelectionListener.didUpdateSelection"
        static let didUpdateSession = "BarcodeSelectionListener.didUpdateSession"
    }

    private let emitter: Emitter

    private let didUpdateSelectionEvent = EventWithResult<Bool>(event: Event(name: Constants.didUpdateSelection))
    private let didUpdateSessionEvent = EventWithResult<Bool>(event: Event(name: Constants.didUpdateSession))

    private var isEnabled = AtomicBool()

    private var lastSession: BarcodeSelectionSession?

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    func enable() {
        isEnabled.value = true
    }

    func disable() {
        isEnabled.value = false
        lastSession = nil
        didUpdateSessionEvent.reset()
        didUpdateSelectionEvent.reset()
    }

    func finishDidSelect(enabled: Bool) {
        didUpdateSelectionEvent.unlock(value: enabled)
    }

    func finishDidUpdate(enabled: Bool) {
        didUpdateSessionEvent.unlock(value: enabled)
    }

    func getBarcodeCount(selectionIdentifier: String) -> Int {
        guard let session = lastSession else { return 0 }
        return session.selectedBarcodes.filter { $0.selectionIdentifier == selectionIdentifier }.count
    }

    func resetSession(frameSequenceId: Int?) {
        guard let session = lastSession,
              let frameSequenceId = frameSequenceId,
              session.frameSequenceId == frameSequenceId else { return }
        session.reset()
    }

    public func barcodeSelection(_ barcodeSelection: BarcodeSelection,
                                 didUpdateSelection session: BarcodeSelectionSession,
                                 frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: Constants.didUpdateSelection) else { return }
        lastSession = session
        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeSelection.isEnabled = didUpdateSelectionEvent.emit(on: emitter,
                                                                  payload: ["session": session.jsonString]) ?? barcodeSelection.isEnabled
    }

    public func barcodeSelection(_ barcodeSelection: BarcodeSelection,
                                 didUpdate session: BarcodeSelectionSession,
                                 frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: Constants.didUpdateSession) else { return }
        lastSession = session
        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        barcodeSelection.isEnabled = didUpdateSessionEvent.emit(on: emitter,
                                                                payload: ["session": session.jsonString]) ?? barcodeSelection.isEnabled
    }
}
