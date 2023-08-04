/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

extension BarcodeSelectionBasicOverlayStyle: CaseIterable {
    public static var allCases: [BarcodeSelectionBasicOverlayStyle] = [.dot, .frame]
}

struct BarcodeSelectionBasicOverlayDefaults: DefaultsEncodable {
    let overlay: BarcodeSelectionBasicOverlay

    func toEncodable() -> [String: Any?] {
        [
            "defaultStyle": overlay.style.jsonString,
            "shouldShowHints": overlay.shouldShowHints,
            "frozenBackgroundColor": overlay.frozenBackgroundColor.sdcHexString,
            "styles": Dictionary(uniqueKeysWithValues: BarcodeSelectionBasicOverlayStyle.allCases.map {
                ($0.jsonString, brushDefaults(for: $0))
            })
        ]
    }

    private func brushDefaults(for style: BarcodeSelectionBasicOverlayStyle) -> [String: Any] {
        let selection = BarcodeSelection(context: nil, settings: BarcodeSelectionSettings())
        let overlay = BarcodeSelectionBasicOverlay(barcodeSelection: selection, view: nil, style: style)
        return [
            "DefaultAimedBrush": EncodableBrush(brush: overlay.aimedBrush).toEncodable(),
            "DefaultSelectedBrush": EncodableBrush(brush: overlay.selectedBrush).toEncodable(),
            "DefaultSelectingBrush": EncodableBrush(brush: overlay.selectingBrush).toEncodable(),
            "DefaultTrackedBrush": EncodableBrush(brush: overlay.trackedBrush).toEncodable()
        ]
    }
}
