/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditBarcodeCapture
import ScanditFrameworksCore
import UIKit

class AdvancedOverlayViewPool {
    private var views: [Int: UIImageView] = [:]

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
                imageView = UIImageView(image: image)
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

    private func parse(data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}
