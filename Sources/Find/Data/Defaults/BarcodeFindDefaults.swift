/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

struct BarcodeFindDefaults: DefaultsEncodable {
    private let feedback: BarcodeFindFeedback
    private let viewDefaults: FrameworksBarcodeFindViewDefaults
    private let recommendedCameraSettings: CameraSettingsDefaults

    init(feedback: BarcodeFindFeedback,
         viewDefaults: FrameworksBarcodeFindViewDefaults,
         recommendedCameraSettings: CameraSettingsDefaults) {
        self.feedback = feedback
        self.viewDefaults = viewDefaults
        self.recommendedCameraSettings = recommendedCameraSettings
    }

    static let shared = {
        BarcodeFindDefaults(
            feedback: .default,
            viewDefaults: FrameworksBarcodeFindViewDefaults(),
            recommendedCameraSettings: CameraSettingsDefaults(
                cameraSettings: BarcodeFind.recommendedCameraSettings
            )
        )
    }()

    func toEncodable() -> [String: Any?] {
        [
            "RecommendedCameraSettings": recommendedCameraSettings.toEncodable(),
            "BarcodeFindFeedback": feedback.jsonString,
            "BarcodeFindView": viewDefaults.toEncodable()
        ]
    }
}
