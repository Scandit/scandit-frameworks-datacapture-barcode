/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum FrameworksSparkScanEvent: String, CaseIterable {
    case didScan = "SparkScanListener.didScan"
    case didUpdate = "SparkScanListener.didUpdateSession"
}

fileprivate extension Event {
    init(_ event: FrameworksSparkScanEvent) {
        self.init(name: event.rawValue)
    }
}

open class FrameworksSparkScanListener: NSObject, SparkScanListener {
    private static let asyncTimeoutInterval: TimeInterval = 600 // 10 mins
    private static let defaultTimeoutInterval: TimeInterval = 2
    private let emitter: Emitter

    private let didScanEvent = EventWithResult<Bool>(event: Event(.didScan))
    private let didUpdateEvent = EventWithResult<Bool>(event: Event(.didUpdate))

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

    public func enableAsync() {
        [didScanEvent, didUpdateEvent].forEach {
            $0.timeout = Self.asyncTimeoutInterval
        }
        enable()
    }

    public func disableAsync() {
        disable()
        [didScanEvent, didUpdateEvent].forEach {
            $0.timeout = Self.defaultTimeoutInterval
        }
    }

    private var lastSession: SparkScanSession?

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func sparkScan(_ sparkScan: SparkScan,
                          didScanIn session: SparkScanSession,
                          frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: FrameworksSparkScanEvent.didScan.rawValue) else { return }
        lastSession = session
        var frameId: String? = nil

        if let data = frameData {
            frameId = LastFrameData.shared.addToCache(frameData: data)
        }

        didScanEvent.emit(
            on: emitter,
            payload: [
                "session": session.jsonString,
                "frameId": frameId
            ]
        )

        if let id = frameId {
            LastFrameData.shared.removeFromCache(frameId: id)
        }
    }

    public func finishDidScan(enabled: Bool) {
        didScanEvent.unlock(value: enabled)
    }

    public func sparkScan(_ sparkScan: SparkScan,
                          didUpdate session: SparkScanSession,
                          frameData: FrameData?) {
        guard isEnabled.value, emitter.hasListener(for: FrameworksSparkScanEvent.didUpdate.rawValue) else { return }
        lastSession = session
        var frameId: String? = nil

        if let data = frameData {
            frameId = LastFrameData.shared.addToCache(frameData: data)
        }

        didUpdateEvent.emit(
            on: emitter,
            payload: [
                "session": session.jsonString,
                "frameId": frameId
            ]
        )

        if let id = frameId {
            LastFrameData.shared.removeFromCache(frameId: id)
        }
    }

    public func finishDidUpdate(enabled: Bool) {
        didUpdateEvent.unlock(value: enabled)
    }

    public func resetLastSession() {
        lastSession?.reset()
    }
}
