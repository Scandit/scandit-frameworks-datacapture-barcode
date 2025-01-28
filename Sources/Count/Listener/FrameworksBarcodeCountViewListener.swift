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
    case brushForAcceptedBarcode = "BarcodeCountViewListener.brushForAcceptedBarcode"
    case brushForRejectedBarcode = "BarcodeCountViewListener.brushForRejectedBarcode"

    case didTapRecognizedBarcode = "BarcodeCountViewListener.didTapRecognizedBarcode"
    case didTapFilteredBarcode = "BarcodeCountViewListener.didTapFilteredBarcode"
    case didTapRecognizedBarcodeNotInList = "BarcodeCountViewListener.didTapRecognizedBarcodeNotInList"
    case didTapAcceptedBarcode = "BarcodeCountViewListener.didTapAcceptedBarcode"
    case didTapRejectedBarcode = "BarcodeCountViewListener.didTapRejectedBarcode"
}

open class FrameworksBarcodeCountViewListener: NSObject, BarcodeCountViewDelegate {
    private let emitter: Emitter

    private let brushForRecognizedBarcodeEvent = Event(.brushForRecognizedBarcode)
    private let brushForRecognizedBarcodeNotInListEvent = Event(.brushForRecognizedBarcodeNotInList)
    private let brushForAcceptedBarcodeEvent = Event(.brushForAcceptedBarcode)
    private let brushForRejectedBarcodeEvent = Event(.brushForRejectedBarcode)

    private let didTapRecognizedBarcodeEvent = Event(.didTapRecognizedBarcode)
    private let didTapFilteredBarcodeEvent = Event(.didTapFilteredBarcode)
    private let didTapRecognizedBarcodeNotInListEvent = Event(.didTapRecognizedBarcodeNotInList)
    private let didTapAcceptedBarcodeEvent = Event(.didTapAcceptedBarcode)
    private let didTapRejectedBarcodeEvent = Event(.didTapRejectedBarcode)

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
        case .brushForAcceptedBarcode:
            return brushForAcceptedBarcodeEvent
        case .brushForRejectedBarcode:
            return brushForRejectedBarcodeEvent
        case .didTapRecognizedBarcode:
            return didTapRecognizedBarcodeEvent
        case .didTapFilteredBarcode:
            return didTapFilteredBarcodeEvent
        case .didTapRecognizedBarcodeNotInList:
            return didTapRecognizedBarcodeNotInListEvent
        case .didTapAcceptedBarcode:
            return didTapAcceptedBarcodeEvent
        case .didTapRejectedBarcode:
            return didTapRejectedBarcodeEvent
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
                                brushForAcceptedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
    brush(for: trackedBarcode, event: .brushForAcceptedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                brushForRejectedBarcode trackedBarcode: TrackedBarcode) -> Brush? {
    brush(for: trackedBarcode, event: .brushForRejectedBarcode)
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
                                 didTapAcceptedBarcode trackedBarcode: TrackedBarcode) {
        emit(event: .didTapAcceptedBarcode, for: trackedBarcode)
    }

    public func barcodeCountView(_ view: BarcodeCountView,
                                 didTapRejectedBarcode trackedBarcode: TrackedBarcode) {
        emit(event: .didTapRejectedBarcode, for: trackedBarcode)
    }

    public func clearCache() {
        brushRequests.removeAll()
    }
}
