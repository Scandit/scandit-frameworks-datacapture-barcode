/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore

private typealias BarcodeId = String
private typealias TrackedBarcodeId = Int

public class BarcodeCheckAugmentationsCache {
    private var annotationsCache = ConcurrentDictionary<BarcodeId, BarcodeCheckAnnotation>()
    private var highlightsCache = ConcurrentDictionary<BarcodeId, BarcodeCheckHighlight>()
    private var trackedBarcodeCache = ConcurrentDictionary<TrackedBarcodeId, BarcodeId>()
    private var barcodeCheckHighlightProviderCallback = ConcurrentDictionary<BarcodeId, HighlightCallbackData>()
    private var barcodeCheckAnnotationProviderCallback = ConcurrentDictionary<BarcodeId, AnnotationCallbackData>()
    private var infoAnnotationDelegates = ConcurrentDictionary<BarcodeId, FrameworksInfoAnnotationDelegate>()
    private var popoverDelegates = ConcurrentDictionary<BarcodeId, FrameworksPopoverAnnotationDelegate>()

    func updateFromSession(_ session: BarcodeCheckSession) {
        for trackedBarcode in session.addedTrackedBarcodes {
            trackedBarcodeCache.setValue(trackedBarcode.barcode.uniqueId, for: trackedBarcode.identifier)
        }

        for trackedBarcodeId in session.removedTrackedBarcodes {
            if let barcodeId = trackedBarcodeCache.removeValue(for: trackedBarcodeId) {
                _ = annotationsCache.removeValue(for: barcodeId)
                _ = highlightsCache.removeValue(for: barcodeId)
                _ = barcodeCheckHighlightProviderCallback.removeValue(for: barcodeId)
                _ = barcodeCheckAnnotationProviderCallback.removeValue(for: barcodeId)
                _ = infoAnnotationDelegates.removeValue(for: barcodeId)
                _ = popoverDelegates.removeValue(for: barcodeId)
            }
        }
    }

    func addHighlightProviderCallback(barcodeId: String, callback: HighlightCallbackData) {
        barcodeCheckHighlightProviderCallback.setValue(callback, for: barcodeId)
    }

    func getHighlightProviderCallback(barcodeId: String) -> HighlightCallbackData? {
        return barcodeCheckHighlightProviderCallback.getValue(for: barcodeId)
    }

    func addHighlight(barcodeId: String, highlight: BarcodeCheckHighlight) {
        highlightsCache.setValue(highlight, for: barcodeId)
    }

    func getHighlight(barcodeId: String) -> BarcodeCheckHighlight? {
        return highlightsCache.getValue(for: barcodeId)
    }

    func addAnnotationProviderCallback(barcodeId: String, callback: AnnotationCallbackData) {
        barcodeCheckAnnotationProviderCallback.setValue(callback, for: barcodeId)
    }

    func getAnnotationProviderCallback(barcodeId: String) -> AnnotationCallbackData? {
        return barcodeCheckAnnotationProviderCallback.getValue(for: barcodeId)
    }

    func addAnnotation(barcodeId: String, annotation: BarcodeCheckAnnotation) {
        annotationsCache.setValue(annotation, for: barcodeId)
    }

    func getAnnotation(barcodeId: String) -> BarcodeCheckAnnotation? {
        return annotationsCache.getValue(for: barcodeId)
    }
    
    func addInfoAnnotationDelegate(barcodeId: String, delegate: FrameworksInfoAnnotationDelegate) {
        infoAnnotationDelegates.setValue(delegate, for: barcodeId)
    }
    
    func addPopoverDelegate(barcodeId: String, delegate: FrameworksPopoverAnnotationDelegate) {
        popoverDelegates.setValue(delegate, for: barcodeId)
    }

    func clear() {
        trackedBarcodeCache.removeAllValues()
        annotationsCache.removeAllValues()
        highlightsCache.removeAllValues()
        barcodeCheckHighlightProviderCallback.removeAllValues()
        barcodeCheckAnnotationProviderCallback.removeAllValues()
        infoAnnotationDelegates.removeAllValues()
        popoverDelegates.removeAllValues()
    }
}
