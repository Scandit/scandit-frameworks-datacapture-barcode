/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

fileprivate extension Event {
    init(_ event: BarcodePickEvent) {
        self.init(name: event.rawValue)
    }
}

class FrameworksBarcodePickAsyncMapperProductProviderCallback: NSObject, BarcodePickAsyncMapperProductProviderDelegate {
    private let emitter: Emitter

    init(emitter: Emitter) {
        self.emitter = emitter
        identifiersForItemsEvent = EventWithResult(event: Event(.onProductIdentifierForItems))
    }

    let identifiersForItemsEvent: EventWithResult<[BarcodePickProductProviderCallbackItem]>

    func mapItems(_ items: [String],
                  completionHandler: @escaping ([BarcodePickProductProviderCallbackItem]) -> Void) {
        let result = identifiersForItemsEvent.emit(on: emitter,
                                                   payload: ["itemsData": items])
        if let result = result {
            completionHandler(result)
        }
    }

    func finishMapIdentifiersForEvents(itemsJson: String) {
        let wrapper = BarcodePickProductProviderCallbackItemData(jsonString: itemsJson)
        let items = wrapper.items
        identifiersForItemsEvent.unlock(value: items)
    }
}
