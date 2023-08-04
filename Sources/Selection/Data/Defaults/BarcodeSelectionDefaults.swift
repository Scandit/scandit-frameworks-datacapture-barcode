/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

struct BarcodeSelectionDefaults: DefaultsEncodable {
    let feedback: BarcodeSelectionFeedback
    let recommendedCameraSettings: CameraSettingsDefaults
    let settings: BarcodeSelectionSettingsDefaults
    let tapSelection: BarcodeSelectionTapSelectionDefaults
    let aimerSelection: BarcodeSelectionAimerSelectionDefaults
    let overlay: BarcodeSelectionBasicOverlayDefaults

    public static let shared: BarcodeSelectionDefaults = {
        let settings = BarcodeSelectionSettings()
        let overlay = {
            let mode = BarcodeSelection(context: nil, settings: settings)
            return BarcodeSelectionBasicOverlay(barcodeSelection: mode, view: nil)
        }()
        return BarcodeSelectionDefaults(feedback: .default,
                                        recommendedCameraSettings: CameraSettingsDefaults(cameraSettings: BarcodeSelection.recommendedCameraSettings),
                                        settings: BarcodeSelectionSettingsDefaults(settings: settings),
                                        tapSelection: BarcodeSelectionTapSelectionDefaults(tapSelection: BarcodeSelectionTapSelection()),
                                        aimerSelection: BarcodeSelectionAimerSelectionDefaults(aimerSelection: BarcodeSelectionAimerSelection()),
                                        overlay: BarcodeSelectionBasicOverlayDefaults(overlay: overlay)
        )
    }()

    func toEncodable() -> [String: Any?] {
        [
            "BarcodeSelectionBasicOverlay": overlay.toEncodable(),
            "BarcodeSelectionSettings": settings.toEncodable(),
            "Feedback": feedback.jsonString,
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeSelectionTapSelection": tapSelection.toEncodable(),
            "BarcodeSelectionAimerSelection": aimerSelection.toEncodable()
        ]
    }
}
