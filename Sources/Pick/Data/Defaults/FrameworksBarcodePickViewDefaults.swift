/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct FrameworksBarcodePickViewDefaults: DefaultsEncodable {
    func toEncodable() -> [String: Any?] {
        [
            "HighlightStyle": BarcodePickViewSettingsDefaults.highlightStyle.jsonString,
            "initialGuidelineText": BarcodePickViewSettingsDefaults.initialGuidelineText,
            "moveCloserGuidelineText": BarcodePickViewSettingsDefaults.moveCloserGuidelineText,
            "loadingDialogText": BarcodePickViewSettingsDefaults.loadingDialogText,
            "showLoadingDialog": BarcodePickViewSettingsDefaults.showLoadingDialog,
            "onFirstItemPickCompletedHintText": BarcodePickViewSettingsDefaults.onFirstItemPickCompletedHintText,
            "onFirstItemToPickFoundHintText": BarcodePickViewSettingsDefaults.onFirstItemToPickFoundHintText,
            "onFirstItemUnpickCompletedHintText": BarcodePickViewSettingsDefaults.onFirstItemUnpickCompletedHintText,
            "onFirstUnmarkedItemPickCompletedHintText": BarcodePickViewSettingsDefaults.onFirstUnmarkedItemPickCompletedHintText,
            "showGuidelines": BarcodePickViewSettingsDefaults.showGuidelines,
            "showHints": BarcodePickViewSettingsDefaults.showHints,
            "showFinishButton": BarcodePickViewSettingsDefaults.showFinishButton,
            "showPauseButton": BarcodePickViewSettingsDefaults.showPauseButton,
            "showZoomButton": BarcodePickViewSettingsDefaults.showZoomButton
        ]
    }
}
