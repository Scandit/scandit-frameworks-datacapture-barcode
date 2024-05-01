/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore
import UIKit

class AdvancedOverlayViewPool {
    private let emitter: Emitter
    private let didTapViewForTrackedBarcodeEvent: Event
    private var views: [Int: UIImageView] = [:]

    init(emitter: Emitter, didTapViewForTrackedBarcodeEvent: Event) {
        self.emitter = emitter
        self.didTapViewForTrackedBarcodeEvent = didTapViewForTrackedBarcodeEvent
    }

    func getOrCreateView(barcode: TrackedBarcode, widgetData: Data) -> UIImageView? {
        let block: () -> UIImageView? = {
            guard let image = self.parse(data: widgetData) else {
                return nil
            }
            var imageView: UIImageView
            if self.views.keys.contains(barcode.identifier) {
                imageView = self.views[barcode.identifier]!
                imageView.image = image
            } else {
                imageView = self.createImageView(with: image, trackedBarcode: barcode)
            }
            return imageView
        }
        return dispatchMainSync(block)
    }

    func removeView(for barcode: TrackedBarcode) {
        dispatchMainSync {
            views.removeValue(forKey: barcode.identifier)
        }
    }

    func clear() {
        dispatchMainSync {
            views.removeAll()
        }
    }

    private func createImageView(with image: UIImage, trackedBarcode: TrackedBarcode) -> UIImageView {
        let imageView = UIImageView(image: image)
        let scale = UIScreen.main.scale
        imageView.frame.size = CGSize(width: imageView.frame.size.width / scale,
                                      height: imageView.frame.size.height / scale)
        self.views[trackedBarcode.identifier] = imageView
        
        let tapRecognizer = TapGestureRecognizerWithClosure { [weak self] in
            guard let self = self else { return }
            self.didTapViewForTrackedBarcodeEvent.emit(on: self.emitter,
                                                   payload: ["trackedBarcode": trackedBarcode.jsonString])
        }
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapRecognizer)

        return imageView
    }

    private func parse(data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}
