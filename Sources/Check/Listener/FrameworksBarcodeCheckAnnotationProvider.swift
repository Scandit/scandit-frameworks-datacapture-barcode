/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

public enum BarcodeCheckAnnotationProviderEvents: String, CaseIterable {
    case annotationForBarcode = "BarcodeCheckAnnotationProvider.annotationForBarcode"
}

open class FrameworksBarcodeCheckAnnotationProvider: NSObject, BarcodeCheckAnnotationProvider {

    private let emitter: Emitter

    private let parser: BarcodeCheckAnnotationParser

    private let cache: BarcodeCheckAugmentationsCache

    public init(emitter: Emitter, parser: BarcodeCheckAnnotationParser, cache: BarcodeCheckAugmentationsCache) {
        self.emitter = emitter
        self.parser = parser
        self.cache = cache
    }

    private let annotationForBarcode = Event(
        name: BarcodeCheckAnnotationProviderEvents.annotationForBarcode.rawValue
    )

    public func annotation(
        for barcode: Barcode, completionHandler: @escaping ((any UIView & BarcodeCheckAnnotation)?) -> Void
    ) {
        self.cache.addAnnotationProviderCallback(
            barcodeId: barcode.uniqueId,
            callback: AnnotationCallbackData(barcode: barcode, callback: completionHandler)
        )

        annotationForBarcode.emit(on: emitter, payload: [
            "barcode": barcode.jsonString,
            "barcodeId": barcode.uniqueId
        ])
    }

    public func finishAnnotationForBarcode(annotationJson: String) {
        let json =  JSONValue(string: annotationJson)

        guard let barcodeId = json.optionalString(forKey: "barcodeId"),
              let callbackData = cache.getAnnotationProviderCallback(barcodeId: barcodeId) else {
            return
        }

        if json.containsKey("annotation") == false {
            callbackData.callback(nil)
            return
        }

        let annotationJson = json.object(forKey: "annotation")

        if let annotation = self.parser.get(json: annotationJson, barcode: callbackData.barcode) {
            cache.addAnnotation(barcodeId: barcodeId, annotation: annotation)
            callbackData.callback(annotation)
        }
    }

    public func updateAnnotation(annotationJson: String) {
        let json = JSONValue(string: annotationJson)

        guard let barcodeId = json.optionalString(forKey: "barcodeId"),
              let annotation = cache.getAnnotation(barcodeId: barcodeId) else {
            return
        }

        parser.updateAnnotation(annotation, json: json)
    }

    public func updateBarcodeCheckPopoverButtonAtIndex(updateJson: String) {
        let json = JSONValue(string: updateJson)

        guard let barcodeId = json.optionalString(forKey: "barcodeId"),
              let annotation = cache.getAnnotation(barcodeId: barcodeId) as? BarcodeCheckPopoverAnnotation else {
            return
        }

        let buttonJson = json.object(forKey: "button")
        parser.updateBarcodeCheckPopoverButton(annotation, json: buttonJson)
    }

}
