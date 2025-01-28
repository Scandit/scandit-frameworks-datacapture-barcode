/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

private typealias ViewDefaults = BarcodeCountViewDefaults

struct DefaultsBarcodeCountView: DefaultsEncodable {
    let barcodeCountToolbarSettingsDefaults: BarcodeCountToolbarSettingsDefaults

    func toEncodable() -> [String: Any?] {
        [
            "style": ViewDefaults.defaultStyle.jsonString,
            "shouldShowUserGuidanceView": ViewDefaults.defaultShouldShowUserGuidanceView,
            "shouldShowListButton": ViewDefaults.defaultShouldShowListButton,
            "shouldShowExitButton": ViewDefaults.defaultShouldShowExitButton,
            "shouldShowShutterButton": ViewDefaults.defaultShouldShowShutterButton,
            "shouldShowHints": ViewDefaults.defaultShouldShowHints,
            "shouldShowClearHighlightsButton": ViewDefaults.defaultShouldShowClearHighlightsButton,
            "shouldShowSingleScanButton": ViewDefaults.defaultShouldShowSingleScanButton,
            "shouldShowFloatingShutterButton": ViewDefaults.defaultShouldShowFloatingShutterButton,
            "shouldShowToolbar": ViewDefaults.defaultShouldShowToolbar,
            "shouldShowScanAreaGuides": ViewDefaults.defaultShouldShowScanAreaGuides,
            "toolbarSettings": barcodeCountToolbarSettingsDefaults.toEncodable(),
            "recognizedBrush": EncodableBrush(brush: BarcodeCountView.defaultRecognizedBrush).toEncodable(),
            "notInListBrush": EncodableBrush(brush: BarcodeCountView.defaultNotInListBrush).toEncodable(),
            "acceptedBrush": EncodableBrush(brush: BarcodeCountView.defaultAcceptedBrush).toEncodable(),
            "rejectedBrush": EncodableBrush(brush: BarcodeCountView.defaultRejectedBrush).toEncodable(),
            "listButtonAccessibilityHint": ViewDefaults.defaultListButtonAccessibilityHint,
            "listButtonAccessibilityLabel": ViewDefaults.defaultListButtonAccessibilityLabel,
            "exitButtonAccessibilityHint": ViewDefaults.defaultExitButtonAccessibilityHint,
            "exitButtonAccessibilityLabel": ViewDefaults.defaultExitButtonAccessibilityLabel,
            "shutterButtonAccessibilityHint": ViewDefaults.defaultShutterButtonAccessibilityHint,
            "shutterButtonAccessibilityLabel": ViewDefaults.defaultShutterButtonAccessibilityLabel,
            "floatingShutterButtonAccessibilityHint": ViewDefaults.defaultFloatingShutterButtonAccessibilityHint,
            "floatingShutterButtonAccessibilityLabel": ViewDefaults.defaultFloatingShutterButtonAccessibilityLabel,
            "clearHighlightsButtonAccessibilityHint": ViewDefaults.defaultClearHighlightsButtonAccessibilityHint,
            "clearHighlightsButtonAccessibilityLabel": ViewDefaults.defaultClearHighlightsButtonAccessibilityLabel,
            "singleScanButtonAccessibilityHint": ViewDefaults.defaultSingleScanButtonAccessibilityHint,
            "singleScanButtonAccessibilityLabel": ViewDefaults.defaultSingleScanButtonAccessibilityLabel,
            "clearHighlightsButtonText": ViewDefaults.defaultClearHighlightsButtonText,
            "exitButtonText": ViewDefaults.defaultExitButtonText,
            "textForTapShutterToScanHint": ViewDefaults.defaultTextForTapShutterToScanHint,
            "textForScanningHint": ViewDefaults.defaultTextForScanningHint,
            "textForMoveCloserAndRescanHint": ViewDefaults.defaultTextForMoveCloserAndRescanHint,
            "textForMoveFurtherAndRescanHint": ViewDefaults.defaultTextForMoveFurtherAndRescanHint,
            "shouldShowListProgressBar": ViewDefaults.defaultShouldShowListProgressBar,
            "shouldShowTorchControl": ViewDefaults.defaultShouldShowTorchControl,
            "torchControlPosition": ViewDefaults.defaultTorchControlPosition.jsonString,
            "tapToUncountEnabled": ViewDefaults.defaultTapToUncountEnabled,
            "textForTapToUncountHint": ViewDefaults.defaultTextForTapToUncountHint,
            "shouldShowStatusModeButton": ViewDefaults.defaultShouldShowStatusModeButton,
        ]
    }
}
