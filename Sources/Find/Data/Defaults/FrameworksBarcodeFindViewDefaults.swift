/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct FrameworksBarcodeFindViewDefaults: DefaultsEncodable {
    func toEncodable() -> [String: Any?] {
        [
            "hardwareTriggerSupported": true,
            "shouldShowCarousel": BarcodeFindViewDefaults.defaultShouldShowCarousel,
            "shouldShowFinishButton": BarcodeFindViewDefaults.defaultShouldShowFinishButton,
            "shouldShowHints": BarcodeFindViewDefaults.defaultShouldShowHints,
            "shouldShowPauseButton": BarcodeFindViewDefaults.defaultShouldShowPauseButton,
            "shouldShowProgressBar": BarcodeFindViewDefaults.defaultShouldShowProgressBar,
            "shouldShowUserGuidanceView": BarcodeFindViewDefaults.defaultShouldShowUserGuidanceView,
            "shouldShowTorchControl": BarcodeFindViewDefaults.defaultShouldShowTorchControl,
            "shouldShowZoomControl": BarcodeFindViewDefaults.defaultShouldShowZoomControl,
            "textForCollapseCardsButton": BarcodeFindViewDefaults.defaultTextForCollapseCardsButton,
            "textForAllItemsFoundSuccessfullyHint": BarcodeFindViewDefaults.defaultTextForAllItemsFoundSuccessfullyHint,
            "textForPointAtBarcodesToSearchHint": BarcodeFindViewDefaults.defaultTextForPointAtBarcodesToSearchHint,
            "textForMoveCloserToBarcodesHint": BarcodeFindViewDefaults.defaultTextForMoveCloserToBarcodesHint,
            "textForTapShutterToPauseScreenHint": BarcodeFindViewDefaults.defaultTextForTapShutterToPauseScreenHint,
            "textForTapShutterToResumeSearchHint": BarcodeFindViewDefaults.defaultTextForTapShutterToResumeSearchHint,
            "textForItemListUpdatedHint": BarcodeFindViewDefaults.defaultTextForItemListUpdatedHint,
            "textForItemListUpdatedWhenPausedHint": BarcodeFindViewDefaults.defaultTextForItemListUpdatedWhenPausedHint
        ]
    }
}
