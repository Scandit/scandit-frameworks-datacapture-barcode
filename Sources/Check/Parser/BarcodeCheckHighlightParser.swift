/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import Foundation

import ScanditFrameworksCore

public class BarcodeCheckHighlightParser {
    private let emitter: Emitter

    init(emitter: Emitter) {
        self.emitter = emitter
    }

    func get(json: JSONValue, barcode: Barcode) -> (UIView & BarcodeCheckHighlight)? {
        guard let type = json.optionalString(forKey: "type") else {
            Log.error("Invalid JSON type.")
            return nil
        }

        switch type {
        case "barcodeCheckCircleHighlight":
            return getBarcodeCheckCircleHighlight(barcode: barcode, json: json)
        case "barcodeCheckRectangleHighlight":
            return getBarcodeCheckRectangleHighlight(barcode: barcode, json: json)
        default:
            Log.error("Not supported highlight type.", error: NSError(domain: "Type \(type)", code: -1))
            return nil
        }
    }

    func updateHighlight(_ highlight: BarcodeCheckHighlight, json: JSONValue) {
        switch highlight {
        case let circleHighlight as BarcodeCheckCircleHighlight:
            updateCircleHighlight(circleHighlight, json: json)
        case let rectangleHighlight as BarcodeCheckRectangleHighlight:
            updateRectangleHighlight(rectangleHighlight, json: json)
        default:
            break
        }
    }

    private func getBarcodeCheckCircleHighlight(barcode: Barcode, json: JSONValue) -> BarcodeCheckCircleHighlight? {
        guard let presetString = json.optionalString(forKey: "preset") else {
            Log.error("Invalid data for BarcodeCheckCircleHighlight.")
            return nil
        }

        var preset = BarcodeCheckCircleHighlightPreset.dot
        SDCBarcodeCheckCircleHighlightPresetFromJSONString(presetString, &preset)

        let highlight = BarcodeCheckCircleHighlight(barcode: barcode, preset: preset)
        updateCircleHighlight(highlight, json: json)
        return highlight
    }

    private func getBarcodeCheckRectangleHighlight(
        barcode: Barcode, json: JSONValue
    ) -> BarcodeCheckRectangleHighlight? {

        let highlight = BarcodeCheckRectangleHighlight(barcode: barcode)
        updateRectangleHighlight(highlight, json: json)
        return highlight
    }

    private func updateCircleHighlight(_ highlight: BarcodeCheckCircleHighlight, json: JSONValue) {
        do {
            let sizeValue = json.cgFloat(forKey: "size")

            if json.containsKey("icon") {
                let iconJson = json.getObjectAsString(forKey: "icon")
                highlight.icon = try ScanditIcon(fromJSONString: iconJson)
            }
            highlight.size =  sizeValue
            if json.containsKey("brush") {
                let brushString = json.getObjectAsString(forKey: "brush")
                if let brush = Brush(jsonString: brushString) {
                    highlight.brush = brush
                }
            }
        } catch {
            Log.error("Unable to parse the BarcodeCheckCircleHighlight from the provided json.", error: error)
        }
    }

    private func updateRectangleHighlight(_ highlight: BarcodeCheckRectangleHighlight, json: JSONValue) {

        do {
            if json.containsKey("icon") {
                let iconJson = json.getObjectAsString(forKey: "icon")
                highlight.icon = try ScanditIcon(fromJSONString: iconJson)
            }

            if json.containsKey("brush") {
                let brushString = json.getObjectAsString(forKey: "brush")
                if let brush = Brush(jsonString: brushString) {
                    highlight.brush = brush
                }
            }
        } catch {
            Log.error("Unable to parse the BarcodeCheckRectangleHighlight from the provided json.", error: error)
        }

    }
}
