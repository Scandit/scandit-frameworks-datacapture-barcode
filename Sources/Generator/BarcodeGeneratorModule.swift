/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

import ScanditFrameworksCore
import ScanditBarcodeCapture

public enum BarcodeGeneratorError: Error {
    case componentNotFound
    case invalidBase64Data
    case dataCaptureNotInitialized
    case wrongBuilderType
    case generatorFailure(error: Error?)
    case builderInitializationFailed(type: String)
    case builderGenerationFailed(error: Error?)
}

open class BarcodeGeneratorModule : NSObject, FrameworkModule, DeserializationLifeCycleObserver {
    
    private var generators: [String: BarcodeGenerator] = [:]
    
    private var context: DataCaptureContext?
    
    public func didStart() {
        DeserializationLifeCycleDispatcher.shared.attach(observer: self)
    }
    
    public func didStop() {
        DeserializationLifeCycleDispatcher.shared.detach(observer: self)
    }
    
    public func createGenerator(generatorJson: String, result: FrameworksResult) {
        guard let dcContext = context else {
            result.reject(error: BarcodeGeneratorError.dataCaptureNotInitialized)
            return
        }
        
        let data = BarcodeGeneratorDataParser(jsonString: generatorJson)

        guard let builder = buildGenerator(for: data, with: dcContext) else {
            result.reject(error: BarcodeGeneratorError.builderInitializationFailed(type: data.type))
            return
        }
        
        configureBuilder(builder: builder, with: data)
        
        buildBarcodeGenerator(using: builder, with: data, result: result)
    }
    
    private func buildGenerator(for data: BarcodeGeneratorDataParser, with context: DataCaptureContext) -> BarcodeGeneratorBuilder? {
        switch data.type {
        case "code39Generator":
            return BarcodeGenerator.code39BarcodeGeneratorBuilder(with: context)
        case "code128Generator":
            return BarcodeGenerator.code128BarcodeGeneratorBuilder(with: context)
        case "dataMatrixGenerator":
            return BarcodeGenerator.dataMatrixBarcodeGeneratorBuilder(with: context)
        case "ean13Generator":
            return BarcodeGenerator.ean13BarcodeGeneratorBuilder(with: context)
        case "interleavedTwoOfFiveGenerator":
            return BarcodeGenerator.interleavedTwoOfFiveBarcodeGeneratorBuilder(with: context)
        case "upcaGenerator":
            return BarcodeGenerator.upcaBarcodeGeneratorBuilder(with: context)
        case "qrCodeGenerator":
            let builder = BarcodeGenerator.qrCodeBarcodeGeneratorBuilder(with: context)
            configureQRCodeBuilder(builder: builder, data: data)
            return builder
        case "aztecGenerator":
            let builder = BarcodeGenerator.aztecBarcodeGeneratorBuilder(with: context)
            configureAztecBuilder(builder: builder, data: data)
            return builder
        default:
            return nil
        }
    }
    
    private func configureQRCodeBuilder(builder: QRCodeBarcodeGeneratorBuilder, data: BarcodeGeneratorDataParser) {
        if let errorCorrectionLevel = data.errorCorrectionLevel {
            builder.errorCorrectionLevel = errorCorrectionLevel
        }
        if let versionNumber = data.versionNumber {
            builder.versionNumber = versionNumber
        }
    }
    
    private func configureAztecBuilder(builder: AztecBarcodeGeneratorBuilder, data: BarcodeGeneratorDataParser) {
        if let minimumErrorCorrectionPercent = data.minimumErrorCorrectionPercent {
            builder.minimumErrorCorrectionPercent = minimumErrorCorrectionPercent
        }
        
        if let layers = data.layers {
            builder.layers = layers
        }
    }
    
    private func configureBuilder(builder: BarcodeGeneratorBuilder, with data: BarcodeGeneratorDataParser) {
        if let backgroundColor = data.backgroundColor {
            builder.backgroundColor = backgroundColor
        }
        if let foregroundColor = data.foregroundColor {
            builder.foregroundColor = foregroundColor
        }
    }

    private func buildBarcodeGenerator(using builder: BarcodeGeneratorBuilder, with data: BarcodeGeneratorDataParser, result: FrameworksResult) {
        dispatchMain { [weak self] in
            do {
                guard let self = self else {
                    result.reject(error: ScanditFrameworksCoreError.nilSelf)
                    return
                }
                
                let generator = try builder.build()
                self.generators[data.id] = generator
                
                result.success()
            } catch {
                result.reject(error: BarcodeGeneratorError.builderGenerationFailed(error: error))
            }
        }
    }
    
    public func generate(generatorId: String, text: String, imageWidth: Int, result: FrameworksResult) {
        guard let generator = generators[generatorId] else {
            result.reject(error: BarcodeGeneratorError.componentNotFound)
            return
        }
        
        do {
            let generatorResult = try generator.generate(with: text, imageWidth: CGFloat(imageWidth))
            result.success(result: convertImageToBase64String(img: generatorResult))
        } catch {
            result.reject(error: BarcodeGeneratorError.generatorFailure(error: error))
        }
    }

    public func generateFromBase64EncodedData(generatorId: String, data: String, imageWidth: Int, result: FrameworksResult) {
        guard let generator = generators[generatorId] else {
            result.reject(error: BarcodeGeneratorError.componentNotFound)
            return
        }

        guard let base64Bytes = Data(base64Encoded: data) else {
            result.reject(error: BarcodeGeneratorError.invalidBase64Data)
            return
        }

        do {
            let generatorResult = try generator.generate(with: base64Bytes, imageWidth: CGFloat(imageWidth))
            result.success(result: convertImageToBase64String(img: generatorResult))
        } catch {
            result.reject(error: BarcodeGeneratorError.generatorFailure(error: error))
        }
    }

    public func disposeGenerator(generatorId: String, result: FrameworksResult) {
        generators.removeValue(forKey: generatorId)
        result.success()
    }
    
    
    public func dataCaptureContext(deserialized context: DataCaptureContext?) {
        self.context = context
    }
    
    public func didDisposeDataCaptureContext() {
        self.generators.removeAll()
    }
    
    private func convertImageToBase64String(img: UIImage) -> String? {
        guard let imageData = img.pngData() else { return nil }
        return imageData.base64EncodedString()
    }
}
