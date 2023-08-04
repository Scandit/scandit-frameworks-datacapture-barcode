/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeCaptureOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeCaptureOverlayStyle] {
        [.frame, .legacy]
    }
}

struct BarcodeCaptureOverlayDefaults: DefaultsEncodable {
    let defaultStyle: BarcodeCaptureOverlayStyle

    func toEncodable() -> [String: Any?] {
        [
            "defaultStyle": defaultStyle.jsonString,
            "DefaultBrush": brushDefaultsFromOverlayStyle(defaultStyle).toEncodable(),
            "Brushes": Dictionary(uniqueKeysWithValues: BarcodeCaptureOverlayStyle.allCases.map {
                ($0.jsonString, brushDefaultsFromOverlayStyle($0).toEncodable())
            })
        ]
    }

    private func brushDefaultsFromOverlayStyle(_ style: BarcodeCaptureOverlayStyle) -> EncodableBrush {
        let settings = BarcodeCaptureSettings()
        let mode = BarcodeCapture(context: nil, settings: settings)
        let overlay = BarcodeCaptureOverlay(barcodeCapture: mode, with: style)
        return EncodableBrush(brush: overlay.brush)
    }
}
