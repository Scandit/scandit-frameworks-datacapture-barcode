/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture

struct BarcodeGeneratorDataParser {
    let id: String
    let type: String
    let backgroundColor: UIColor?
    let foregroundColor: UIColor?
    let errorCorrectionLevel: QRCodeErrorCorrectionLevel?
    let versionNumber: Int?
    
    init(jsonString: String) {
        let jsonValue = JSONValue(string: jsonString)
        
        self.id = jsonValue.string(forKey: "id")
        self.type = jsonValue.string(forKey: "type")
        
        let backgroundColorHex = jsonValue.optionalString(forKey: "backgroundColor")
        self.backgroundColor = backgroundColorHex.flatMap{  hexString in
            UIColor(sdcHexString: hexString)
        }
        let foregroundColorHex = jsonValue.optionalString(forKey: "foregroundColor")
        self.foregroundColor = foregroundColorHex.flatMap{  hexString in
            UIColor(sdcHexString: hexString)
        }
        
        let errorCorrectionLevel: QRCodeErrorCorrectionLevel?

        if let levelString = jsonValue.optionalString(forKey: "errorCorrectionLevel"){
            switch levelString {
            case "low":
                errorCorrectionLevel = .low
            case "medium":
                errorCorrectionLevel = .medium
            case "quartile":
                errorCorrectionLevel = .quartile
            case "high":
                errorCorrectionLevel = .high
            default:
                errorCorrectionLevel = nil
            }
        } else {
            errorCorrectionLevel = nil
        }
        self.errorCorrectionLevel = errorCorrectionLevel
        self.versionNumber = jsonValue.optionalInt(forKey: "versionNumber")
    }
}
