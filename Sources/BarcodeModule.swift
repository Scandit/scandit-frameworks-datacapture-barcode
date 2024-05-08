/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore

open class BarcodeModule: NSObject, FrameworkModule {
    public func didStart() {}

    public func didStop() {}

    public let defaults: DefaultsEncodable = BarcodeDefaults.shared
}
