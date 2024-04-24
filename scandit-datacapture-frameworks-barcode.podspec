Pod::Spec.new do |s|
    s.name                    = 'scandit-datacapture-frameworks-barcode'
    s.version                 = '6.23.1'
    s.summary                 = 'Scandit Frameworks Shared Barcode module'
    s.homepage                = 'https://github.com/Scandit/scandit-datacapture-frameworks-barcode'
    s.license                 = { :type => 'Apache-2.0' , :text => 'Licensed under the Apache License, Version 2.0 (the "License");' }
    s.author                  = { 'Scandit' => 'support@scandit.com' }
    s.platforms               = { :ios => '13.0' }
    s.source                  = { :git => 'https://github.com/Scandit/scandit-datacapture-frameworks-barcode.git', :tag => '6.23.1' }
    s.swift_version           = '5.7'
    s.source_files            = 'Sources/**/*.{h,m,swift}'
    s.requires_arc            = true
    s.module_name             = 'ScanditFrameworksBarcode'
    s.header_dir              = 'ScanditFrameworksBarcode'

    s.dependency 'ScanditBarcodeCapture', '= 6.23.1'
    s.dependency 'scandit-datacapture-frameworks-core', '= 6.23.1'
end
