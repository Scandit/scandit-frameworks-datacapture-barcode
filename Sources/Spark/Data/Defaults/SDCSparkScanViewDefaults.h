/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2023- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SparkScanViewDefaults)
SDC_EXPORTED_SYMBOL
@interface SDCSparkScanViewDefaults : NSObject

@property (class, nonatomic, readonly) BOOL defaultBarcodeCountButtonVisibility;
@property (class, nonatomic, readonly) BOOL defaultBarcodeFindButtonVisibility;
@property (class, nonatomic, readonly) BOOL defaultTargetModeButtonVisibility;
@property (class, nonatomic, readonly) BOOL defaultScanningBehaviorButtonVisibility;
@property (class, nonatomic, readonly) BOOL defaultZoomSwitchControlVisibility;
@property (class, nonatomic, readonly) UIColor *defaultToolbarBackgroundColor;
@property (class, nonatomic, readonly) UIColor *defaultToolbarIconActiveTintColor;
@property (class, nonatomic, readonly) UIColor *defaultToolbarIconInactiveTintColor;
@property (class, nonatomic, readonly) BOOL defaultPreviewSizeControlVisibility;
@property (class, nonatomic, readonly) BOOL defaultCameraSwitchButtonVisibility;

// Toast
@property (class, nonatomic, assign, readonly) BOOL defaultToastEnabled;
@property (class, nonatomic, readonly) UIColor *defaultToastBackgroundColor;
@property (class, nonatomic, readonly) UIColor *defaultToastTextColor;
@property (class, nonatomic, readonly) NSString *defaultTargetModeEnabledMessage;
@property (class, nonatomic, readonly) NSString *defaultTargetModeDisabledMessage;
@property (class, nonatomic, readonly) NSString *defaultContinuousModeEnabledMessage;
@property (class, nonatomic, readonly) NSString *defaultContinuousModeDisabledMessage;

@property (class, nonatomic, readonly) BOOL defaultTorchControlVisible;
@property (class, nonatomic, readonly) UIImage *defaultTriggerButtonImage;
@property (class, nonatomic, readonly) UIColor *defaultTriggerButtonCollapsedColor;
@property (class, nonatomic, readonly) UIColor *defaultTriggerButtonExpandedColor;
@property (class, nonatomic, readonly) UIColor *defaultTriggerButtonAnimationColor;
@property (class, nonatomic, readonly) UIColor *defaultTriggerButtonTintColor;
@property (class, nonatomic, readonly) BOOL defaultTriggerButtonVisibility;
@property (class, nonatomic, readonly) BOOL defaultPreviewCloseControlVisible;

@end

NS_ASSUME_NONNULL_END
