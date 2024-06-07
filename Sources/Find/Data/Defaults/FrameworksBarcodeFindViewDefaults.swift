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
            "shouldShowUserGuidanceView": BarcodeFindViewDefaults.defaultShouldShowUserGuidanceView,
            "shouldShowHints": BarcodeFindViewDefaults.defaultShouldShowHints,
            "shouldShowCarousel": BarcodeFindViewDefaults.defaultShouldShowCarousel,
            "shouldShowPauseButton": BarcodeFindViewDefaults.defaultShouldShowPauseButton,
            "shouldShowFinishButton": BarcodeFindViewDefaults.defaultShouldShowFinishButton,
            "shouldShowProgressBar": BarcodeFindViewDefaults.defaultShouldShowProgressBar,
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
