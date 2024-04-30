/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

extension JSONValue {
    func optionalString(forKey: String) -> String? {
        return containsKey(forKey) ? string(forKey: forKey) : nil
    }
    
    func optionalInt(forKey: String) -> Int? {
        return containsKey(forKey) ? integer(forKey: forKey) : nil
    }
}

struct BarcodePickProductProviderCallbackItemData {
    private let backingJson: JSONValue

    init(jsonString: String) {
        self.backingJson = JSONValue(string: jsonString).asArray()
    }

    var items: [BarcodePickProductProviderCallbackItem] {
        (0...backingJson.count() - 1).map {
            barcodeFindItemFromJsonValue(backingJson.atIndex($0))
        }
    }

    private func barcodeFindItemFromJsonValue(_ jsonValue: JSONValue) -> BarcodePickProductProviderCallbackItem {
        let itemData = jsonValue.string(forKey: "itemData")
        let productIdentifier = jsonValue.optionalString(forKey: "productIdentifier")
        return BarcodePickProductProviderCallbackItem(itemData: itemData,
                                                      productIdentifier: productIdentifier)
    }
}
