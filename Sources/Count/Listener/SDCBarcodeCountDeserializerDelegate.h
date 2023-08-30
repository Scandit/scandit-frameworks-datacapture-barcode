/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

@class SDCBarcodeCountDeserializer;
@class SDCBarcodeCount;
@class SDCBarcodeCountSettings;
@class SDCJSONValue;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BarcodeCountDeserializerDelegate)
@protocol SDCBarcodeCountDeserializerDelegate <NSObject>

- (void)barcodeCountDeserializer:(SDCBarcodeCountDeserializer *)deserializer
       didStartDeserializingMode:(SDCBarcodeCount *)mode
                   fromJSONValue:(SDCJSONValue *)JSONValue;

- (void)barcodeCountDeserializer:(SDCBarcodeCountDeserializer *)deserializer
      didFinishDeserializingMode:(SDCBarcodeCount *)mode
                   fromJSONValue:(SDCJSONValue *)JSONValue;

- (void)barcodeCountDeserializer:(SDCBarcodeCountDeserializer *)deserializer
    didStartDeserializingSettings:(SDCBarcodeCountSettings *)settings
                    fromJSONValue:(SDCJSONValue *)JSONValue;

- (void)barcodeCountDeserializer:(SDCBarcodeCountDeserializer *)deserializer
    didFinishDeserializingSettings:(SDCBarcodeCountSettings *)settings
                     fromJSONValue:(SDCJSONValue *)JSONValue;

@end

NS_ASSUME_NONNULL_END
