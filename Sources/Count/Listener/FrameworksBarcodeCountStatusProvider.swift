/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

open class FrameworksBarcodeCountStatusProvider: NSObject, BarcodeCountStatusProvider {
    private enum Constants {
        static let onStatusRequested = "BarcodeCountStatusProvider.onStatusRequested"
    }

    private var events = [String: BarcodeCountStatusProviderRequest]()
    private let eventsQueue = DispatchQueue(label: "scandit-frameworks-barcode-count", attributes: .concurrent)

    private let emitter: Emitter
    private let onStatusRequestedEvent = Event(name: Constants.onStatusRequested)

    public init(emitter: Emitter) {
        self.emitter = emitter
    }

    public func statusRequested(for barcodes: [TrackedBarcode], callback: BarcodeCountStatusProviderCallback) {
        guard emitter.hasListener(for: Constants.onStatusRequested) else { return }

        let request = BarcodeCountStatusProviderRequest(barcodes: barcodes, callback: callback)

        addEvent(request: request)

        onStatusRequestedEvent.emit(
            on: emitter,
            payload: [
                "barcodes": barcodes.map {  $0.jsonString },
                BarcodeCountStatusProviderRequest.ID: request.requestId
            ]
        )
    }

    public func submitCallbackResult(resultJson: String) {
        guard let result = BarcodeCountStatusProviderResult.createFromJson(statusJson: resultJson) else {
            return
        }

        guard let event = getEvent(for: result.requestId) else {
            return
        }

        do {
            let statusesForBarcodes = try result.get(barcodesFromEvent: event.barcodes)

            event.callback.onStatusReady(statusesForBarcodes)
        } catch {
            Log.error(error)
        }
    }


    private func addEvent(request: BarcodeCountStatusProviderRequest) {
        eventsQueue.async { [weak self] in
            self?.events[request.requestId] = request
        }
    }

    private func getEvent(for key: String) -> BarcodeCountStatusProviderRequest? {
        var result: BarcodeCountStatusProviderRequest?
        eventsQueue.sync { [weak self] in
            result = self?.events[key]
        }
        return result
    }

    private func removeEvent(for key: String) {
        eventsQueue.async { [weak self] in
            self?.events.removeValue(forKey: key)
        }
    }
}
