/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeCaptureOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeCaptureOverlayStyle] {
        [.frame]
    }
}

extension EncodableBrush {
    public static let legacyBarcodeCaptureDefaultBrush = EncodableBrush(
        brush: Brush(
            fill: UIColor(
                sdcHexString: "00000000"
            )!,
            stroke: UIColor(
                sdcHexString: "2ec1ceff"
            )!,
            strokeWidth: 1
        )
    )
}

struct BarcodeCaptureOverlayDefaults: DefaultsEncodable {
    let defaultStyle: BarcodeCaptureOverlayStyle

    func toEncodable() -> [String: Any?] {
        var allBrushses = Dictionary(uniqueKeysWithValues: BarcodeCaptureOverlayStyle.allCases.map {
            ($0.jsonString, brushDefaultsFromOverlayStyle($0).toEncodable())
        })

        // Deprecated BarcodeCaptureOverlayStyle
        allBrushses["legacy"] = EncodableBrush.legacyBarcodeCaptureDefaultBrush.toEncodable()

        return [
            "defaultStyle": defaultStyle.jsonString,
            "DefaultBrush": brushDefaultsFromOverlayStyle(defaultStyle).toEncodable(),
            "Brushes": allBrushses
        ]
    }

    private func brushDefaultsFromOverlayStyle(_ style: BarcodeCaptureOverlayStyle) -> EncodableBrush {
        let settings = BarcodeCaptureSettings()
        let mode = BarcodeCapture(context: nil, settings: settings)
        let overlay = BarcodeCaptureOverlay(barcodeCapture: mode, with: style)
        return EncodableBrush(brush: overlay.brush)
    }
}
