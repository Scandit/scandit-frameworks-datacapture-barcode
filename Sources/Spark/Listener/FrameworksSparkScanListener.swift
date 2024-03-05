/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public class FrameworksSparkScanListener: NSObject, SparkScanListener {
    private enum Constants {
        static let didScan = "SparkScanListener.didScan"
        static let didUpdate = "SparkScanListener.didUpdateSession"
    }

    private let emitter: Emitter

    private let didScanEvent = EventWithResult<Bool>(event: Event(name: Constants.didScan))
    private let didUpdateEvent = EventWithResult<Bool>(event: Event(name: Constants.didUpdate))

    private var isEnabled = AtomicBool()

    public func enable() {
        isEnabled.value = true
    }

    public func disable() {
        isEnabled.value = false
        didScanEvent.reset()
        didUpdateEvent.reset()
        lastSession = nil
    }

    private var lastSession: SparkScanSession?

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func sparkScan(_ sparkScan: SparkScan,
                          didScanIn session: SparkScanSession,
                          frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: Constants.didScan) else { return }
        lastSession = session
        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        didScanEvent.emit(on: emitter, payload: ["session": session.jsonString])
    }

    func finishDidScan(enabled: Bool) {
        didScanEvent.unlock(value: enabled)
    }

    public func sparkScan(_ sparkScan: SparkScan,
                          didUpdate session: SparkScanSession,
                          frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: Constants.didUpdate) else { return }
        lastSession = session
        LastFrameData.shared.frameData = frameData
        defer { LastFrameData.shared.frameData = nil }

        didUpdateEvent.emit(on: emitter, payload: ["session": session.jsonString])
    }

    func finishDidUpdate(enabled: Bool) {
        didUpdateEvent.unlock(value: enabled)
    }

    func resetLastSession() {
        lastSession?.reset()
    }
}
