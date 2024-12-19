/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

private typealias ViewDefaults = SparkScanViewDefaults

struct DefaultsSparkScanView: DefaultsEncodable {
    let viewSettings: SparkScanViewSettings

    func toEncodable() -> [String: Any?] {
        [
            "brush": EncodableBrush(brush: SparkScanView.defaultBrush).toEncodable(),
            "scanningBehaviorButtonVisible": ViewDefaults.defaultScanningBehaviorButtonVisibility,
            "barcodeCountButtonVisible": ViewDefaults.defaultBarcodeCountButtonVisibility,
            "barcodeFindButtonVisible": ViewDefaults.defaultBarcodeFindButtonVisibility,
            "targetModeButtonVisible": ViewDefaults.defaultTargetModeButtonVisibility,
            "toolbarBackgroundColor": ViewDefaults.defaultToolbarBackgroundColor.sdcHexString,
            "toolbarIconActiveTintColor": ViewDefaults.defaultToolbarIconActiveTintColor.sdcHexString,
            "toolbarIconInactiveTintColor": ViewDefaults.defaultToolbarIconInactiveTintColor.sdcHexString,
            "SparkScanViewSettings": viewSettings.jsonString,
            "zoomSwitchControlVisible": ViewDefaults.defaultZoomSwitchControlVisibility,
            "hardwareTriggerSupported": false,
            "toastEnabled": ViewDefaults.defaultToastEnabled,
            "toastBackgroundColor": ViewDefaults.defaultToastBackgroundColor.sdcHexString,
            "toastTextColor": ViewDefaults.defaultToastTextColor.sdcHexString,
            "targetModeEnabledMessage": ViewDefaults.defaultTargetModeEnabledMessage,
            "targetModeDisabledMessage": ViewDefaults.defaultTargetModeDisabledMessage,
            "continuousModeEnabledMessage": ViewDefaults.defaultContinuousModeEnabledMessage,
            "continuousModeDisabledMessage": ViewDefaults.defaultContinuousModeDisabledMessage,
            "previewSizeControlVisible": ViewDefaults.defaultPreviewSizeControlVisibility,
            "cameraSwitchButtonVisible": ViewDefaults.defaultCameraSwitchButtonVisibility,
            "torchControlVisible": ViewDefaults.defaultTorchControlVisible,
            "triggerButtonImage": convertImageToBase64String(img: ViewDefaults.defaultTriggerButtonImage),
            "triggerButtonCollapsedColor": ViewDefaults.defaultTriggerButtonCollapsedColor.sdcHexString,
            "triggerButtonExpandedColor": ViewDefaults.defaultTriggerButtonExpandedColor.sdcHexString,
            "triggerButtonAnimationColor": ViewDefaults.defaultTriggerButtonAnimationColor.sdcHexString,
            "triggerButtonTintColor": ViewDefaults.defaultTriggerButtonTintColor.sdcHexString,
            "triggerButtonVisible": ViewDefaults.defaultTriggerButtonVisibility,
            "previewCloseControlVisible": ViewDefaults.defaultPreviewCloseControlVisible,
        ]
    }

    private func convertImageToBase64String(img: UIImage?) -> String? {
        guard let imageData = img?.pngData() else { return nil }
        return imageData.base64EncodedString()
    }
}
