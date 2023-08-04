/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeTrackingBasicOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeTrackingBasicOverlayStyle] = [.dot, .frame, .legacy]
}

struct BarcodeTrackingBasicOverlayDefaults: DefaultsEncodable {
    let defaultStyle: BarcodeTrackingBasicOverlayStyle

    func toEncodable() -> [String: Any?] {
        [
            "defaultStyle": defaultStyle.jsonString,
            "Brushes": Dictionary(uniqueKeysWithValues: BarcodeTrackingBasicOverlayStyle.allCases.map {
                ($0.jsonString, brushDefaults(of: $0).toEncodable())
            })
        ]
    }

    private func brushDefaults(of style: BarcodeTrackingBasicOverlayStyle) -> DefaultsEncodable {
        let tracking = BarcodeTracking(context: nil, settings: BarcodeTrackingSettings())
        let overlay = BarcodeTrackingBasicOverlay(barcodeTracking: tracking, with: style)
        let brush = overlay.brush ?? .transparent
        return EncodableBrush(brush: brush)
    }
}
