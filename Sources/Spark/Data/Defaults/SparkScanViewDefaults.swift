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
            "shouldShowScanAreaGuides": false,
            "brush": EncodableBrush(brush: SparkScanView.defaultBrush).toEncodable(),
            "torchButtonVisible": ViewDefaults.defaultTorchButtonVisibility,
            "scanningBehaviorButtonVisible": ViewDefaults.defaultScanningBehaviorButtonVisibility,
            "handModeButtonVisible": ViewDefaults.defaultHandModeButtonVisibility,
            "barcodeCountButtonVisible": ViewDefaults.defaultBarcodeCountButtonVisibility,
            "barcodeFindButtonVisible": ViewDefaults.defaultBarcodeFindButtonVisibility,
            "targetModeButtonVisible": ViewDefaults.defaultTargetModeButtonVisibility,
            "stopCapturingText": ViewDefaults.defaultStopCapturingText,
            "startCapturingText": ViewDefaults.defaultStartCapturingText,
            "startCapturingByHoldingText": ViewDefaults.defaultStartCapturingByHoldingText,
            "resumeCapturingText": ViewDefaults.defaultResumeCapturingText,
            "scanningCapturingText": ViewDefaults.defaultScanningCapturingText,
            "captureButtonActiveBackgroundColor": ViewDefaults.defaultCaptureButtonActiveBackgroundColor.sdcHexString,
            "captureButtonBackgroundColor": ViewDefaults.defaultCaptureButtonBackgroundColor.sdcHexString,
            "captureButtonTintColor": ViewDefaults.defaultCaptureButtonTintColor.sdcHexString,
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
        ]
    }
}
