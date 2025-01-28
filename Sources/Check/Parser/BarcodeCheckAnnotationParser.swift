/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import Foundation
import UIKit

import ScanditFrameworksCore

public enum FrameworksBarcodeCheckAnnotationEvents: String, CaseIterable {
    case didTapPopover = "BarcodeCheckPopoverAnnotationListener.didTapPopover"
    case didTapPopoverButton = "BarcodeCheckPopoverAnnotationListener.didTapPopoverButton"
    case didTapInfoAnnotationFooter = "BarcodeCheckInfoAnnotationListener.didTapInfoAnnotationFooter"
    case didTapInfoAnnotationHeader = "BarcodeCheckInfoAnnotationListener.didTapInfoAnnotationHeader"
    case didTapInfoAnnotation = "BarcodeCheckInfoAnnotationListener.didTapInfoAnnotation"
    case didTapInfoAnnotationLeftIcon = "BarcodeCheckInfoAnnotationListener.didTapInfoAnnotationLeftIcon"
    case didTapInfoAnnotationRightIcon = "BarcodeCheckInfoAnnotationListener.didTapInfoAnnotationRightIcon"
}

public class BarcodeCheckAnnotationParser {
    private let emitter: Emitter
    private let cache: BarcodeCheckAugmentationsCache

    init(emitter: Emitter, cache: BarcodeCheckAugmentationsCache) {
        self.emitter = emitter
        self.cache = BarcodeCheckAugmentationsCache()
    }

    func get(json: JSONValue, barcode: Barcode) -> (UIView & BarcodeCheckAnnotation)? {
        guard let type = json.optionalString(forKey: "type") else {
            Log.error("Missing type in JSON.")
            return nil
        }

        switch type {
        case "barcodeCheckInfoAnnotation":
            return getInfoAnnotation(barcode: barcode, json: json)
        case "barcodeCheckPopoverAnnotation":
            return getPopoverAnnotation(barcode: barcode, json: json)
        case "barcodeCheckStatusIconAnnotation":
            return getStatusIconAnnotation(barcode: barcode, json: json)
        default:
            Log.error("Not supported annotation type.", error: NSError(domain: "Type \(type)", code: -1))
            return nil
        }
    }

    func updateAnnotation(_ annotation: BarcodeCheckAnnotation, json: JSONValue) {
        switch annotation {
        case let infoAnnotation as BarcodeCheckInfoAnnotation:
            guard let barcodeId = json.optionalString(forKey: "barcodeId") else {
                Log.error("Missing barcodeId in JSON.")
                return
            }
            updateInfoAnnotation(infoAnnotation, json, barcodeId)
        case let statusIconAnnotation as BarcodeCheckStatusIconAnnotation:
            let iconJson = json.getObjectAsString(forKey: "icon")
            updateStatusIconAnnotation(statusIconAnnotation, iconJson, json)
        case let popoverAnnotation as BarcodeCheckPopoverAnnotation:
            updatePopoverAnnotation(popoverAnnotation, json, popoverAnnotation.barcode)
        default:
            Log.error("Unsupported annotation type")
        }
    }

    func updateBarcodeCheckPopoverButton(_ annotation: BarcodeCheckPopoverAnnotation, json: JSONValue) {
        guard let index = json.optionalInt(forKey: "index") else {
            Log.error("Invalid index received when trying to update the updateBarcodeCheckPopoverButton.")
            return
        }

        if  index < 0 {
            Log.error(
                "Invalid index received when trying to update the updateBarcodeCheckPopoverButton.",
                error: NSError(domain: "Index \(index)", code: -1)
            )
            return
        }
        
        if index > annotation.buttons.count - 1 {
            Log.error(
                "Invalid index received when trying to update the updateBarcodeCheckPopoverButton",
                error: NSError(domain: "Buttons Size \(annotation.buttons.count), Index \(index)", code: -1)
            )
            return
        }
        
        let button = annotation.buttons[index]
        if let textColorHex = json.optionalString(forKey: "textColor"),
           let textColor = UIColor(sdcHexString: textColorHex) {
            button.textColor = textColor
        }
        button.font = json.getFont(forSizeKey: "textSize", andFamilyKey: "fontFamily")
        button.isEnabled = json.bool(forKey: "enabled", default: false)
    }
}

// MARK: - Barcode Check Info Annotation

private extension BarcodeCheckAnnotationParser {

    private func getInfoAnnotation(barcode: Barcode, json: JSONValue) -> BarcodeCheckInfoAnnotation? {
        let annotation = BarcodeCheckInfoAnnotation(barcode: barcode)

        updateInfoAnnotation(annotation, json, barcode.uniqueId)

        return annotation
    }

    private func updateInfoAnnotation(
        _ annotation: BarcodeCheckInfoAnnotation,
        _ json: JSONValue,
        _ barcodeId: String
    ) {
        annotation.hasTip = json.bool(forKey: "hasTip", default: false)
        annotation.isEntireAnnotationTappable = json.bool(forKey: "isEntireAnnotationTappable", default: false)
        if let anchorJson = json.optionalString(forKey: "anchor") {
            var anchor = BarcodeCheckInfoAnnotationAnchor.bottom
            SDCBarcodeCheckInfoAnnotationAnchorFromJSONString(anchorJson, &anchor)
            annotation.anchor = anchor
        }

        if let widthJson = json.optionalString(forKey: "width") {
            var width = BarcodeCheckInfoAnnotationWidthPreset.small
            SDCBarcodeCheckInfoAnnotationWidthPresetFromJSONString(widthJson, &width)
            annotation.width = width
        }

        if json.containsKey("header") {
            annotation.header = parseInfoAnnotationHeader(json.object(forKey: "header"))
        }

        if json.containsKey("footer") {
            annotation.footer = parseInfoAnnotationFooter(json.object(forKey: "footer"))
        }

        let bodyComponentsJson = json.array(forKey: "body")
        var bodyComponents = [BarcodeCheckInfoAnnotationBodyComponent]()
        for index in 0..<bodyComponentsJson.count() {
            let bodyJson = bodyComponentsJson.atIndex(index)
            if let component = getBarcodeCheckInfoAnnotationBodyComponent(json: bodyJson) {
                bodyComponents.append(component)
            }
        }
        annotation.body = bodyComponents

        if json.bool(forKey: "hasListener", default: false) {
            let annotationDelegate = FrameworksInfoAnnotationDelegate(emitter: emitter, barcodeId: barcodeId)
            // Need to keep a reference of the delegate in the cache because it's garbage collected on native side
            self.cache.addInfoAnnotationDelegate(barcodeId: barcodeId, delegate: annotationDelegate)
            annotation.delegate = annotationDelegate
        } else {
            annotation.delegate = nil
        }

        var trigger = BarcodeCheckAnnotationTrigger.highlightTap
        SDCBarcodeCheckAnnotationTriggerFromJSONString(json.string(forKey: "annotationTrigger"), &trigger)
        annotation.annotationTrigger = trigger
    }

    private func parseInfoAnnotationHeader(_ json: JSONValue) -> BarcodeCheckInfoAnnotationHeader {
        let annotationHeader = BarcodeCheckInfoAnnotationHeader()
        do {

            if json.containsKey("icon") {
                let headerIconJson = json.getObjectAsString(forKey: "icon")
                annotationHeader.icon = try ScanditIcon(fromJSONString: headerIconJson)
            }
            annotationHeader.text = json.optionalString(forKey: "text")
            if let headerBackgroundColorHex = json.optionalString(forKey: "backgroundColor"),
               let headerBackgroundColor = UIColor(sdcHexString: headerBackgroundColorHex) {
                annotationHeader.backgroundColor = headerBackgroundColor
            }
            if let headerTextColorHex = json.optionalString(forKey: "textColor"),
               let headerTextColor = UIColor(sdcHexString: headerTextColorHex) {
                annotationHeader.textColor = headerTextColor
            }
            annotationHeader.font = json.getFont(forSizeKey: "textSize", andFamilyKey: "fontFamily")
        } catch {
            Log.error("Unable to parse the BarcodeCheckInfoAnnotation header from the given json.", error: error)
        }
        return annotationHeader
    }

    private func parseInfoAnnotationFooter(_ json: JSONValue) -> BarcodeCheckInfoAnnotationFooter {
        let annotationFooter = BarcodeCheckInfoAnnotationFooter()
        do {

            if json.containsKey("icon") {
                let footerIconJson = json.getObjectAsString(forKey: "icon")
                annotationFooter.icon = try ScanditIcon(fromJSONString: footerIconJson)
            }
            annotationFooter.text = json.optionalString(forKey: "text")
            if let footerBackgroundColorHex = json.optionalString(forKey: "backgroundColor"),
               let footerBackgroundColor = UIColor(sdcHexString: footerBackgroundColorHex) {
                annotationFooter.backgroundColor = footerBackgroundColor
            }
            if let footerTextColorHex = json.optionalString(forKey: "textColor"),
               let footerTextColor = UIColor(sdcHexString: footerTextColorHex) {
                annotationFooter.textColor = footerTextColor
            }
            annotationFooter.font = json.getFont(forSizeKey: "textSize", andFamilyKey: "fontFamily")
        } catch {
            Log.error("Unable to parse the BarcodeCheckInfoAnnotation footer from the given json.", error: error)
        }
        return annotationFooter
    }

    private func getBarcodeCheckInfoAnnotationBodyComponent(
        json: JSONValue
    ) -> BarcodeCheckInfoAnnotationBodyComponent? {
        do {
            let bodyComponent = BarcodeCheckInfoAnnotationBodyComponent()
            bodyComponent.text = json.optionalString(forKey: "text")
            if let textColorHex = json.optionalString(forKey: "textColor"),
               let textColor = UIColor(sdcHexString: textColorHex) {
                bodyComponent.textColor = textColor
            }
            bodyComponent.textAlignment = json.getTextAlignment(forKey: "textAlign")
            bodyComponent.isLeftIconTappable = json.bool(forKey: "isLeftIconTappable", default: false)
            if json.containsKey("leftIcon") {
                let leftIconJson = json.getObjectAsString(forKey: "leftIcon")
                bodyComponent.leftIcon = try ScanditIcon(fromJSONString: leftIconJson)
            }
            bodyComponent.isRightIconTappable = json.bool(forKey: "isRightIconTappable", default: false)
            if json.containsKey("rightIcon") {
                let rightIconJson = json.getObjectAsString(forKey: "rightIcon")
                bodyComponent.rightIcon =  try ScanditIcon(fromJSONString: rightIconJson)
            }
            return bodyComponent
        } catch {
            Log.error("Unable to parse the BarcodeCheckInfoAnnotationBodyElement from the provided json.", error: error)
            return nil
        }
    }
}

// MARK: - Barcode Check Popover Annotation

private extension BarcodeCheckAnnotationParser {

    private func getPopoverAnnotation(barcode: Barcode, json: JSONValue) -> BarcodeCheckPopoverAnnotation? {
        do {
            let annotationButtons = json.array(forKey: "buttons")

            var buttons: [BarcodeCheckPopoverAnnotationButton] = []

            for index in 0..<annotationButtons.count() {
                let buttonJson = annotationButtons.atIndex(index)

                let iconJson = buttonJson.getObjectAsString(forKey: "icon")
                let text = buttonJson.string(forKey: "text")

                let button = BarcodeCheckPopoverAnnotationButton(
                    icon: try ScanditIcon(fromJSONString: iconJson),
                    text: text
                )
                updatePopoverButton(json, button)
                buttons.append(button)
            }

            let annotation = BarcodeCheckPopoverAnnotation(barcode: barcode, buttons: buttons)
            updatePopoverAnnotation(annotation, json, barcode)

            return annotation
        } catch {
            Log.error("Unable to parse the BarcodeCheckPopoverAnnotation from the provided json.", error: error)
            return nil
        }
    }

    private func updatePopoverAnnotation(
        _ annotation: BarcodeCheckPopoverAnnotation,
        _ json: JSONValue,
        _ barcode: Barcode
    ) {
        annotation.isEntirePopoverTappable = json.bool(forKey: "isEntirePopoverTappable", default: false)
        if json.bool(forKey: "hasListener", default: false) && annotation.delegate == nil {
            let popoverDelegate = FrameworksPopoverAnnotationDelegate(
                emitter: self.emitter,
                barcodeId: barcode.uniqueId
            )
            // Need to keep a reference of the delegate in the cache because it's garbage collected on native side
            self.cache.addPopoverDelegate(barcodeId: barcode.uniqueId, delegate: popoverDelegate)
            annotation.delegate = popoverDelegate
        } else {
            annotation.delegate = nil
        }
        var trigger = BarcodeCheckAnnotationTrigger.highlightTap
        SDCBarcodeCheckAnnotationTriggerFromJSONString(json.string(forKey: "annotationTrigger"), &trigger)
        annotation.annotationTrigger = trigger
    }

    private func updatePopoverButton(_ json: JSONValue, _ button: BarcodeCheckPopoverAnnotationButton) {
        if let textColorHex = json.optionalString(forKey: "textColor"),
           let textColor = UIColor(sdcHexString: textColorHex) {
            button.textColor = textColor
        }

        button.font = json.getFont(forSizeKey: "textSize", andFamilyKey: "fontFamily")
        button.isEnabled = json.bool(forKey: "enabled", default: false)
    }
}

// MARK: - Barcode Check Status Icon Annotation

private extension BarcodeCheckAnnotationParser {

    private func getStatusIconAnnotation(barcode: Barcode, json: JSONValue) -> BarcodeCheckStatusIconAnnotation? {
        if json.containsKey("icon") == false {
            Log.error("Missing icon in status icon annotation JSON.")
            return nil
        }
        let annotation = BarcodeCheckStatusIconAnnotation(barcode: barcode)
        updateStatusIconAnnotation(annotation, json.getObjectAsString(forKey: "icon"), json)
        return annotation
    }

    private func updateStatusIconAnnotation(
        _ annotation: BarcodeCheckStatusIconAnnotation,
        _ iconJson: String,
        _ json: JSONValue
    ) {
        do {
            annotation.icon = try ScanditIcon(fromJSONString: iconJson)
            annotation.hasTip = json.bool(forKey: "hasTip", default: false)
            annotation.text = json.optionalString(forKey: "text")
            if let textColorHex = json.optionalString(forKey: "textColor"),
               let textColor = UIColor(sdcHexString: textColorHex) {
                annotation.textColor = textColor
            }
            if let backgroundColorHex = json.optionalString(forKey: "backgroundColor"),
               let backgroundColor = UIColor(sdcHexString: backgroundColorHex) {
                annotation.backgroundColor = backgroundColor
            }

            var trigger = BarcodeCheckAnnotationTrigger.highlightTap
            SDCBarcodeCheckAnnotationTriggerFromJSONString(json.string(forKey: "annotationTrigger"), &trigger)
            annotation.annotationTrigger = trigger
        } catch {
            Log.error("Unable to parse the BarcodeCheckStatusIconAnnotation from the provided json.", error: error)
        }
    }
}
