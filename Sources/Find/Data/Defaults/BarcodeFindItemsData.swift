/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore

struct BarcodeFindItemsData {
    private let backingJson: JSONValue

    init(jsonString: String) {
        backingJson = JSONValue(string: jsonString).asArray()
    }

    var items: Set<BarcodeFindItem> {
        let findItems = (0...backingJson.count() - 1).compactMap {
            barcodeFindItem(from: backingJson.atIndex($0))
        }
        return Set(findItems)
    }

    private func barcodeFindItem(from json: JSONValue) -> BarcodeFindItem? {
        guard json.containsObject(withKey: "searchOptions") else { return nil }
        let searchOptions = json.object(forKey: "searchOptions")
        
        let barcodeData = searchOptions.string(forKey: "barcodeData")
        var findItemContent: BarcodeFindItemContent? = nil
        
        if json.containsKey("content") {
            let content = json.object(forKey: "content")
            let info = content.optionalString(forKey: "info")
            let additionalInfo = content.optionalString(forKey: "additionalInfo")
            let imageBase64Encoded = content.optionalString(forKey: "image")

            if info != nil || additionalInfo != nil || imageBase64Encoded != nil {
                findItemContent = BarcodeFindItemContent(
                    info: info,
                    additionalInfo: additionalInfo,
                    image: imageFromBase64(string: imageBase64Encoded)
                )
            }
        }

        return BarcodeFindItem(
            searchOptions: BarcodeFindItemSearchOptions(barcodeData: barcodeData),
            content: findItemContent
        )
    }

    private func imageFromBase64(string: String?) -> UIImage? {
        guard var string = string else { return nil }
        if let index = string.firstIndex(of: ",") {
            string = String(string[string.startIndex...index])
        }
        guard let data = string.data(using: .utf8),
              let image = UIImage(data: data) else { return nil }
        return image
    }
}
