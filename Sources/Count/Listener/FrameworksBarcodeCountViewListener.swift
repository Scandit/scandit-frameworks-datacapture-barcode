/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

fileprivate extension Int {
    func key(for event: BarcodeCountViewListenerEvent) -> String {
        "\(event.rawValue)-\(self)"
    }
}

fileprivate extension Event {
    init(_ event: BarcodeCountViewListenerEvent) {
        self.init(name: event.rawValue)
    }
}

fileprivate extension Emitter {
    func hasListener(for event: BarcodeCountViewListenerEvent) -> Bool {
        return hasListener(for: event.rawValue)
    }
}

public enum BarcodeCountViewListenerEvent: String {
    case brushForRecognizedBarcode = "BarcodeCountViewListener.brushForRecognizedBarcode"
    case brushForRecognizedBarcodeNotInList = "BarcodeCountViewListener.brushForRecognizedBarcodeNotInList"
    case brushForUnrecognizedBarcode = "BarcodeCountViewListener.brushForUnrecognizedBarcode"

    case didTapRecognizedBarcode = "BarcodeCountViewListener.didTapRecognizedBarcode"
    case didTapUnrecognizedBarcode = "BarcodeCountViewListener.didTapUnrecognizedBarcode"
    case didTapFilteredBarcode = "BarcodeCountViewListener.didTapFilteredBarcode"
    case didTapRecognizedBarcodeNotInList = "BarcodeCountViewListener.didTapRecognizedBarcodeNotInList"
}

open class FrameworksBarcodeCountViewListener: NSObject, BarcodeCountViewDelegate {
    private let emitter: Emitter

    private let brushForRecognizedBarcodeEvent = Event(.brushForRecognizedBarcode)
    private let brushForRecognizedBarcodeNotInListEvent = Event(.brushForRecognizedBarcodeNotInList)
    private let brushForUnrecognizedBarcodeEvent = Event(.brushForUnrecognizedBarcode)

    private let didTapRecognizedBarcodeEvent = Event(.didTapRecognizedBarcode)
    private let didTapUnrecognizedBarcodeEvent = Event(.didTapUnrecognizedBarcode)
    private let didTapFilteredBarcodeEvent = Event(.didTapFilteredBarcode)
    private let didTapRecognizedBarcodeNotInListEvent = Event(.didTapRecognizedBarcodeNotInList)

    private var brushRequests: [String: TrackedBarcode] = [:]

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    private func eventDescriptor(for event: BarcodeCountViewListenerEvent) -> Event {
        switch event {
        case .brushForRecognizedBarcode:
            return brushForRecognizedBarcodeEvent
        case .brushForRecognizedBarcodeNotInList:
            return brushForRecognizedBarcodeNotInListEvent
        case .brushForUnrecognizedBarcode:
            return brushForUnrecognizedBarcodeEvent
        case .didTapRecognizedBarcode:
            return didTapRecognizedBarcodeEvent
        case .didTapUnrecognizedBarcode:
            return didTapUnrecognizedBarcodeEvent
        case .didTapFilteredBarcode:
            return didTapFilteredBarcodeEvent
        case .didTapRecognizedBarcodeNotInList:
            return didTapRecognizedBarcodeNotInListEvent
        }
    }

    private func brush(for trackedBarcode: TrackedBarcode, event: BarcodeCountViewListenerEvent) -> Brush? {
        if !emitter.hasListener(for: event) {
            return nil
        }
        eventDescriptor(for: event).emit(on: emitter, payload: ["trackedBarcode": trackedBarcode.jsonString])
        let key = trackedBarcode.identifier.key(for: event)
        brushRequests[key] = trackedBarcode
        return nil
    }

    private func emit(event: BarcodeCountViewListenerEvent, for trackedBarcode: TrackedBarcode) {
        if emitter.hasListener(for: event) {
            eventDescriptor(for: event).emit(on: emitter, payload: ["trackedBarcode": trackedBarcode.jsonString])
        }
    }

    func getTrackedBarcodeForBrush(with trackedBarcodeId: Int, for event: BarcodeCountViewListenerEvent) -> TrackedBarcode? {
        let key = trackedBarcodeId.key(for: event)
        let trackedBarcode = brushRequests[key]
        if trackedBarcode != nil {
            brushRequests.removeValue(forKey: key)
        }
        return trackedBarcode
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 brushForRecognizedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
        brush(for: trackedBarcode, event: .brushForRecognizedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 brushForRecognizedBarcodeNotInList trackedBarcode: TrackedBarcode) -> Brush? {
        brush(for: trackedBarcode, event: .brushForRecognizedBarcodeNotInList)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 brushForUnrecognizedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
        brush(for: trackedBarcode, event: .brushForUnrecognizedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 didTapRecognizedBarcode trackedBarcode: TrackedBarcode) {
        emit(event: .didTapRecognizedBarcode, for: trackedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 didTapFilteredBarcode trackedBarcode: TrackedBarcode) {
        emit(event: .didTapFilteredBarcode, for: trackedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 didTapRecognizedBarcodeNotInList trackedBarcode: TrackedBarcode) {
        emit(event: .didTapRecognizedBarcodeNotInList, for: trackedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 didTapUnrecognizedBarcode trackedBarcode: TrackedBarcode) {
        emit(event: .didTapUnrecognizedBarcode, for: trackedBarcode)
    }

    public func clearCache() {
        brushRequests.removeAll()
    }
}
