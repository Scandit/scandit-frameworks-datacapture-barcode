require "json"

package = JSON.parse(File.read(File.expand_path(File.join(__dir__, "..", "info.json"))))
name = "scandit-datacapture-frameworks-barcode"

Pod::Spec.new do |s|
  s.name                    = name
  s.version                 = package["version"]
  s.summary                 = package["descriptions"][name]
  s.homepage                = package["homepages"][name]
  s.license                 = package["license"]
  s.author                  = { "Scandit" => "support@scandit.com" }
  s.platforms               = { :ios => "13.0" }
  s.source                  = { :git => "git@github.com:Scandit/scandit-datacapture-frameworks-barcode.git", :tag => "#{package["version"]}" }
  s.swift_version           = "5.7"
  s.source_files            = "Sources/**/*.{h,m,swift}"
  s.requires_arc            = true
  s.module_name             = "ScanditFrameworksBarcode"
  s.header_dir              = "ScanditFrameworksBarcode"

  s.dependency 'ScanditBarcodeCapture', '= 6.19.0-beta.1'
    
  s.dependency "scandit-datacapture-frameworks-core", "= #{package['version']}"
end
