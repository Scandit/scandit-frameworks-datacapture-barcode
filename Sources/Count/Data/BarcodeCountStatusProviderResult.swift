/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import Foundation

import ScanditBarcodeCapture

internal class BarcodeCountStatusProviderResult {
    private enum FieldNames {
        static let Status = "status"
        static let BarcodeId = "barcodeId"
        static let StatusList = "statusList"
        static let ErrorMessage = "errorMessage"
        static let EnabledMessage = "statusModeEnabledMessage"
        static let DisabledMessage = "statusModeDisabledMessage"
        static let ResultType = "type"
    }
    
    private let json: [String: Any]
    
    private init(json: [String: Any]) {
        self.json = json
    }
    
    var requestId: String {
        return json[BarcodeCountStatusProviderRequest.ID] as? String ?? ""
    }
    
    func get(barcodesFromEvent: [TrackedBarcode]) throws -> BarcodeCountStatusResult {
        guard let resultType = json[FieldNames.ResultType] as? String else {
            throw NSError(domain: "Invalid BarcodeCountStatusResult type", code: -1, userInfo: nil)
        }
        
        switch resultType {
        case "barcodeCountStatusResultSuccess":
            return getSuccess(barcodesFromEvent: barcodesFromEvent)
        case "barcodeCountStatusResultError":
            return getError(barcodesFromEvent: barcodesFromEvent)
        case "barcodeCountStatusResultAbort":
            return getAbort()
        default:
            throw NSError(domain: "Invalid BarcodeCountStatusResult type", code: -1, userInfo: nil)
        }
    }
    
    private func getSuccess(barcodesFromEvent: [TrackedBarcode]) -> BarcodeCountStatusResult {
        return BarcodeCountStatusSuccessResult(
            statusList:getStatusList(barcodesFromEvent: barcodesFromEvent),
            statusModeEnabledMessage: json[FieldNames.EnabledMessage] as? String,
            statusModeDisabledMessage: json[FieldNames.DisabledMessage] as? String
        )
    }
    
    private func getError(barcodesFromEvent: [TrackedBarcode]) -> BarcodeCountStatusResult {
        return BarcodeCountStatusErrorResult(
            statusList: getStatusList(barcodesFromEvent: barcodesFromEvent),
            errorMessage: json[FieldNames.ErrorMessage] as? String,
            statusModeDisabledMessage: json[FieldNames.DisabledMessage] as? String
        )
    }
    
    private func getAbort() -> BarcodeCountStatusResult {
        return BarcodeCountStatusAbortResult(errorMessage: json[FieldNames.ErrorMessage] as? String)
    }
    
    private func getStatusList(barcodesFromEvent: [TrackedBarcode]) -> [BarcodeCountStatusItem] {
        guard let jsonItems = json[FieldNames.StatusList] as? [[String: Any]] else { return [] }
        
        var items = [BarcodeCountStatusItem]()
        for item in jsonItems {
            if let trackedBarcodeId = item[FieldNames.BarcodeId] as? Int,
               let barcode = barcodesFromEvent.first(where: { $0.identifier == trackedBarcodeId }),
               let statusString = item[FieldNames.Status] as? String {
                let status = statusString.toBarcodeCountStatus()
                items.append(BarcodeCountStatusItem(barcode: barcode, status: status))
            }
        }
        return items
    }
    
    static func createFromJson(statusJson: String) -> BarcodeCountStatusProviderResult? {
        guard let data = statusJson.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        
        return BarcodeCountStatusProviderResult(json: json)
    }
}

private extension String {
    func toBarcodeCountStatus() -> BarcodeCountStatus {
        switch self {
        case "notAvailable":
            return .notAvailable
        case "expired":
            return .expired
        case "fragile":
            return .fragile
        case "qualityCheck":
            return .qualityCheck
        case "lowStock":
            return .lowStock
        case "wrong":
            return .wrong
        case "expiringSoon":
            return .expiringSoon
        default:
            return .none
        }
    }
}

