/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

extension BarcodePickState: CaseIterable {
    static public var allCases: [BarcodePickState] {
        [.ignore, .picked, .toPick, .unknown]
    }
}

struct BarcodePickViewRectangularHighlightStyleDefaults: DefaultsEncodable {
    let rectangularHighlightStyle: BarcodePickViewHighlightStyleRectangular

    func toEncodable() -> [String: Any?] {
        Dictionary(uniqueKeysWithValues: BarcodePickState.allCases.map {
            ($0.jsonString, brushDefaults(for: $0).toEncodable())
        })
    }

    private func brushDefaults(for state: BarcodePickState) -> EncodableBrush {
        EncodableBrush(brush: rectangularHighlightStyle.brush(for: state))
    }

    static let shared: BarcodePickViewRectangularHighlightStyleDefaults = {
        BarcodePickViewRectangularHighlightStyleDefaults(rectangularHighlightStyle: BarcodePickViewHighlightStyleRectangular())
    }()
}

struct BarcodePickViewRectangularWithIconsHighlightStyleDefaults: DefaultsEncodable {
    let rectangularWithIconsHightlightStyle: BarcodePickViewHighlightStyleRectangularWithIcons

    func toEncodable() -> [String: Any?] {
        var dict: [String: Any] = [
            "iconStyle": rectangularWithIconsHightlightStyle.iconStyle.jsonString
        ]
        BarcodePickState.allCases.forEach {
            dict[$0.jsonString] = EncodableBrush(brush: rectangularWithIconsHightlightStyle.brush(for: $0)).toEncodable()
        }
        return dict
    }

    static let shared: BarcodePickViewRectangularWithIconsHighlightStyleDefaults = {
        BarcodePickViewRectangularWithIconsHighlightStyleDefaults(rectangularWithIconsHightlightStyle: BarcodePickViewHighlightStyleRectangularWithIcons()
        )
    }()
}

struct BarcodePickViewHighlightStyleDefaults: DefaultsEncodable {
    private let rectangularHighlightStyleDefaults: BarcodePickViewRectangularHighlightStyleDefaults
    private let rectangularWithIconsHighlightStyleDefaults: BarcodePickViewRectangularWithIconsHighlightStyleDefaults

    func toEncodable() -> [String: Any?] {
        [
            "Rectangular": rectangularHighlightStyleDefaults.toEncodable(),
            "RectangularWithIcon": rectangularWithIconsHighlightStyleDefaults.toEncodable()
        ]
    }

    static let shared: BarcodePickViewHighlightStyleDefaults = {
        return BarcodePickViewHighlightStyleDefaults(
            rectangularHighlightStyleDefaults: .shared,
            rectangularWithIconsHighlightStyleDefaults: .shared
        )
    }()
}
