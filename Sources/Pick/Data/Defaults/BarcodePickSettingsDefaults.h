/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BarcodePickSettingsDefaults)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodePickSettingsDefaults : NSObject

@property (class, nonatomic, assign, readonly) BOOL soundEnabled;
@property (class, nonatomic, assign, readonly) BOOL hapticsEnabled;

@end

NS_ASSUME_NONNULL_END
