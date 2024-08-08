/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeTrackingBasicOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeTrackingBasicOverlayStyle] = [.dot, .frame]
}

extension EncodableBrush {
    public static let legacyBarcodeTrackingDefaultBrush = EncodableBrush(
        brush: Brush(
            fill: UIColor(
                sdcHexString: "2ec1ce4c"
            )!,
            stroke: UIColor(
                sdcHexString: "2ec1ceff"
            )!,
            strokeWidth: 1
        )
    )
}

struct BarcodeTrackingBasicOverlayDefaults: DefaultsEncodable {
    let defaultStyle: BarcodeTrackingBasicOverlayStyle

    func toEncodable() -> [String: Any?] {
        var allBrushses = Dictionary(uniqueKeysWithValues: BarcodeTrackingBasicOverlayStyle.allCases.map {
            ($0.jsonString, brushDefaults(of: $0).toEncodable())
        })
        
        allBrushses["legacy"] = EncodableBrush.legacyBarcodeTrackingDefaultBrush.toEncodable()

        return [
            "defaultStyle": defaultStyle.jsonString,
            "Brushes": allBrushses
        ]
    }

    private func brushDefaults(of style: BarcodeTrackingBasicOverlayStyle) -> DefaultsEncodable {
        let tracking = BarcodeTracking(context: nil, settings: BarcodeTrackingSettings())
        let overlay = BarcodeTrackingBasicOverlay(barcodeTracking: tracking, with: style)
        let brush = overlay.brush ?? .transparent
        return EncodableBrush(brush: brush)
    }
}
