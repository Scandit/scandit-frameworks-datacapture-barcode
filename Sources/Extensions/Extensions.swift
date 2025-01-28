/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */
import Foundation

import ScanditBarcodeCapture

public extension ScanIntention {
    var jsonString : String {
        switch self {
        case .manual:
            return "manual"
        case .smart:
            return "smart"
        }
    }
}


extension JSONValue {
    func getObjectAsString(forKey: String) -> String {
        if self.containsObject(withKey: forKey) {
            return self.object(forKey: forKey).jsonString()
        }

        return self.string(forKey: forKey)
    }

    func getObjectAsBool(forKey: String) -> Bool {
        return self.bool(forKey: forKey, default: false)
    }
    
    func getTextAlignment(forKey: String) -> NSTextAlignment {
        let textAligment = self.optionalString(forKey: forKey)
        
        if textAligment == nil {
            return NSTextAlignment.center
        }
        
        switch textAligment {
        case "left":
            return NSTextAlignment.left
        case "start":
            return NSTextAlignment.left
        case "right":
            return NSTextAlignment.right
        case "end":
            return NSTextAlignment.right
        default:
            return NSTextAlignment.center
        }
    }
    
    func getFont(forSizeKey: String, andFamilyKey: String ) -> UIFont {
        guard let fontFamily = self.optionalString(forKey: andFamilyKey), self.containsKey(forSizeKey) else {
            return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        
        let fontSize = self.cgFloat(forKey: forSizeKey)
        
        switch fontFamily {
        case "modernMono":
            return UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            
        case "systemSans":
            return UIFont(name: "Helvetica", size: fontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
            
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }
}

extension Barcode {
    var uniqueId: String {
        // TODO: Switch using native extension
        return String(self.data.hashValue ^ self.symbology.hashValue)
    }
}
