/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeBatchBasicOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeBatchBasicOverlayStyle] = [.dot, .frame]
}

struct BarcodeBatchBasicOverlayDefaults: DefaultsEncodable {
    let defaultStyle: BarcodeBatchBasicOverlayStyle

    func toEncodable() -> [String: Any?] {
        let allBrushses = Dictionary(uniqueKeysWithValues: BarcodeBatchBasicOverlayStyle.allCases.map {
            ($0.jsonString, brushDefaults(of: $0).toEncodable())
        })

        return [
            "defaultStyle": defaultStyle.jsonString,
            "Brushes": allBrushses
        ]
    }

    private func brushDefaults(of style: BarcodeBatchBasicOverlayStyle) -> DefaultsEncodable {
        let batch = BarcodeBatch(context: nil, settings: BarcodeBatchSettings())
        let overlay = BarcodeBatchBasicOverlay(barcodeBatch: batch, with: style)
        let brush = overlay.brush ?? .transparent
        return EncodableBrush(brush: brush)
    }
}
