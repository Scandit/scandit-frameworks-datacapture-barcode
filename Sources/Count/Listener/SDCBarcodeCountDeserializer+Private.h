/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

#import <ScanditBarcodeCapture/SDCBarcodeCountDeserializer.h>

@protocol SDCBarcodeCountDeserializerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SDCBarcodeCountDeserializer (Private)

- (void)setDelegate:(id<SDCBarcodeCountDeserializerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END