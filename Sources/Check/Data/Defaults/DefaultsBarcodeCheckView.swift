/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditCaptureCore
import ScanditFrameworksCore

private typealias ViewDefaults = BarcodeCheckViewDefaults

struct DefaultsBarcodeCheckView: DefaultsEncodable {
    // swiftlint:disable function_body_length
    func toEncodable() -> [String: Any?] {
        [
            "defaultCameraPosition": ViewDefaults.defaultCameraPosition.jsonString,
            "defaultSoundEnabled": ViewDefaults.defaultSoundEnabled,
            "defaultHapticsEnabled": ViewDefaults.defaultHapticsEnabled,
            "defaultTorchControlPosition": ViewDefaults.defaultTorchControlPosition.jsonString,
            "defaultZoomControlPosition": ViewDefaults.defaultZoomControlPosition.jsonString,
            "defaultCameraSwitchControlPosition": ViewDefaults.defaultCameraSwitchControlPosition.jsonString,
            "defaultShouldShowTorchControl": ViewDefaults.defaultShouldShowTorchControl,
            "defaultShouldShowZoomControl": ViewDefaults.defaultShouldShowZoomControl,
            "defaultShouldShowCameraSwitchControl": ViewDefaults.defaultShouldShowCameraSwitchControl,
            "defaultRectangleHighlightBrush": ViewDefaults.defaultRectangleHighlightBrush.jsonString,
            "defaultPopoverAnnotationTrigger": ViewDefaults.defaultPopoverAnnotationTrigger.jsonString,
            "defaultBarcodeCheckPopoverAnnotationButtonTextSize":
                ViewDefaults.defaultPopoverAnnotationButtonFont.pointSize,
            "defaultBarcodeCheckPopoverAnnotationButtonTextColor":
                ViewDefaults.defaultPopoverAnnotationButtonTextColor.sdcHexString,
            "defaultStatusIconAnnotationTrigger": ViewDefaults.defaultStatusIconAnnotationTrigger.jsonString,
            "defaultStatusIconAnnotationHasTip": ViewDefaults.defaultStatusIconAnnotationHasTip,
            "defaultStatusIconAnnotationIcon": ViewDefaults.defaultStatusIconAnnotationIcon.jsonString,
            "defaultStatusIconAnnotationTextColor": ViewDefaults.defaultStatusIconAnnotationIconTextColor.sdcHexString,
            "defaultStatusIconAnnotationBackgroundColor":
                ViewDefaults.defaultStatusIconAnnotationBackgroundColor.sdcHexString,
            "defaultInfoAnnotationWidth": ViewDefaults.defaultInfoAnnotationWidth.jsonString,
            "defaultInfoAnnotationBackgroundColor": ViewDefaults.defaultInfoAnnotationBackgroundColor.sdcHexString,
            "defaultInfoAnnotationHasTip": ViewDefaults.defaultInfoAnnotationHasTip,
            "defaultInfoAnnotationAnchor": ViewDefaults.defaultInfoAnnotationAnchor.jsonString,
            "defaultInfoAnnotationTrigger": ViewDefaults.defaultInfoAnnotationTrigger.jsonString,
            "defaultInfoAnnotationHeaderBackgroundColor":
                ViewDefaults.defaultInfoAnnotationHeaderBackgroundColor.sdcHexString,
            "defaultInfoAnnotationHeaderTextSize": ViewDefaults.defaultInfoAnnotationHeaderFont.pointSize,
            "defaultInfoAnnotationHeaderTextColor": ViewDefaults.defaultInfoAnnotationHeaderTextColor.sdcHexString,
            "defaultInfoAnnotationFooterBackgroundColor":
                ViewDefaults.defaultInfoAnnotationFooterBackgroundColor.sdcHexString,
            "defaultInfoAnnotationFooterTextSize": ViewDefaults.defaultInfoAnnotationFooterFont.pointSize,
            "defaultInfoAnnotationFooterTextColor": ViewDefaults.defaultInfoAnnotationFooterTextColor.sdcHexString,
            "defaultInfoAnnotationBodyElementTextSize": ViewDefaults.defaultInfoAnnotationBodyComponentFont.pointSize,
            "defaultInfoAnnotationBodyElementTextColor":
                ViewDefaults.defaultInfoAnnotationBodyComponentTextColor.sdcHexString,
            "defaultInfoAnnotationBodyElementLeftIconTappable":
                ViewDefaults.defaultInfoAnnotationBodyComponentIsLeftIconTappable,
            "defaultInfoAnnotationBodyElementRightIconTappable":
                ViewDefaults.defaultInfoAnnotationBodyComponentIsRightIconTappable,
            "defaultHighlightIcon": ViewDefaults.defaultRectangleHighlightIcon?.jsonString,
            "defaultIsEntirePopoverTappable": ViewDefaults.defaultPopoverAnnotationIsEntirePopoverTappable,
            "defaultStatusIconAnnotationText": ViewDefaults.defaultStatusIconAnnotationText,
            "circleHighlightPresets": self.getDefaultCircleHighlightPresets(),
            "defaultInfoAnnotationEntireAnnotationTappable":
                ViewDefaults.defaultInfoAnnotationIsEntireAnnotationTappable,
            "defaultInfoAnnotationHeaderIcon": ViewDefaults.defaultInfoAnnotationHeaderIcon?.jsonString,
            "defaultInfoAnnotationHeaderText": ViewDefaults.defaultInfoAnnotationHeaderText,
            "defaultInfoAnnotationFooterIcon": ViewDefaults.defaultInfoAnnotationFooterIcon?.jsonString,
            "defaultInfoAnnotationFooterText": ViewDefaults.defaultInfoAnnotationFooterText,
            "defaultInfoAnnotationBodyElementText": ViewDefaults.defaultInfoAnnotationBodyComponentText,
            "defaultInfoAnnotationBodyElementStyledText": ViewDefaults.defaultInfoAnnotationBodyComponentStyledText,
            "defaultInfoAnnotationBodyElementLeftIcon":
                ViewDefaults.defaultInfoAnnotationBodyComponentLeftIcon?.jsonString,
            "defaultInfoAnnotationBodyElementRightIcon":
                ViewDefaults.defaultInfoAnnotationBodyComponentRightIcon?.jsonString,
            "defaultBarcodeCheckPopoverAnnotationButtonEnabled": ViewDefaults.defaultPopoverAnnotationButtonEnabled
        ]
    }
    // swiftlint:enable function_body_length

    private func getDefaultCircleHighlightFromPreset(preset: BarcodeCheckCircleHighlightPreset) -> [String: Any] {
        return [
            "brush": ViewDefaults.defaultCircleHighlightBrush(for: preset).jsonString,
            "size": ViewDefaults.defaultCircleHighlightSize(for: preset)
        ]
    }

    private func getDefaultCircleHighlightPresets() -> [String: Any] {
        var presets: [String: Any] = [:]
        let allPresets: [BarcodeCheckCircleHighlightPreset] = [.dot, .icon]

        for preset in allPresets {
            presets[ preset.jsonString] = getDefaultCircleHighlightFromPreset(preset: preset)
        }
        return presets
    }
}
