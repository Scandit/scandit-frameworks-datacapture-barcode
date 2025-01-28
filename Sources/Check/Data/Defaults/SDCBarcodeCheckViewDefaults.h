/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2024- Scandit AG. All rights reserved.
 */

#import <ScanditBarcodeCapture/ScanditBarcodeCapture.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BarcodeCheckViewDefaults)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeCheckViewDefaults : NSObject

// clang-format off
@property (class, nonatomic, assign, readonly) BOOL defaultHapticsEnabled;
@property (class, nonatomic, assign, readonly) BOOL defaultSoundEnabled;

@property (class, nonatomic, assign, readonly) BOOL defaultShouldShowTorchControl;
@property (class, nonatomic, assign, readonly) BOOL defaultShouldShowZoomControl;
@property (class, nonatomic, assign, readonly) BOOL defaultShouldShowCameraSwitchControl;
@property (class, nonatomic, assign, readonly) BOOL defaultShouldShowMacroModeControl;
@property (class, nonatomic, assign, readonly) SDCCameraPosition defaultCameraPosition;
@property (class, nonatomic, assign, readonly) SDCAnchor defaultTorchControlPosition;
@property (class, nonatomic, assign, readonly) SDCAnchor defaultZoomControlPosition;
@property (class, nonatomic, assign, readonly) SDCAnchor defaultCameraSwitchControlPosition;
@property (class, nonatomic, assign, readonly) SDCAnchor defaultMacroModeControlPosition;

@property (class, nonatomic, readonly) SDCBrush *defaultRectangleHighlightBrush;
@property (class, nonatomic, nullable, readonly) SDCScanditIcon *defaultRectangleHighlightIcon;

@property (class, nonatomic, readonly) SDCBarcodeCheckAnnotationTrigger defaultStatusIconAnnotationTrigger;
@property (class, nonatomic, readonly) BOOL defaultStatusIconAnnotationHasTip;
@property (class, nonatomic, readonly) SDCScanditIcon *defaultStatusIconAnnotationIcon;
@property (class, nonatomic, readonly, nullable) NSString *defaultStatusIconAnnotationText;
@property (class, nonatomic, readonly) UIColor *defaultStatusIconAnnotationBackgroundColor;
@property (class, nonatomic, readonly) UIColor *defaultStatusIconAnnotationIconTextColor;
@property (class, nonatomic, readonly) UIFont *defaultStatusIconAnnotationLabelFont;

@property (class, nonatomic, readonly) SDCBarcodeCheckAnnotationTrigger defaultPopoverAnnotationTrigger;
@property (class, nonatomic, readonly) BOOL defaultPopoverAnnotationIsEntirePopoverTappable;
@property (class, nonatomic, readonly) BOOL defaultPopoverAnnotationButtonEnabled;
@property (class, nonatomic, readonly) UIFont *defaultPopoverAnnotationButtonFont;
@property (class, nonatomic, readonly) UIColor *defaultPopoverAnnotationButtonTextColor;

@property (class, nonatomic, readonly) SDCBarcodeCheckAnnotationTrigger defaultInfoAnnotationTrigger;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationBackgroundColor;
@property (class, nonatomic, readonly) BOOL defaultInfoAnnotationHasTip;
@property (class, nonatomic, readonly) BOOL defaultInfoAnnotationIsEntireAnnotationTappable;
@property (class, nonatomic, readonly) SDCBarcodeCheckInfoAnnotationAnchor defaultInfoAnnotationAnchor;
@property (class, nonatomic, readonly) SDCBarcodeCheckInfoAnnotationWidthPreset defaultInfoAnnotationWidth;

@property (class, nonatomic, nullable, readonly) SDCScanditIcon *defaultInfoAnnotationHeaderIcon;
@property (class, nonatomic, nullable, readonly) NSString *defaultInfoAnnotationHeaderText;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationHeaderBackgroundColor;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationHeaderTextColor;
@property (class, nonatomic, readonly) UIFont *defaultInfoAnnotationHeaderFont;

@property (class, nonatomic, nullable, readonly) SDCScanditIcon *defaultInfoAnnotationFooterIcon;
@property (class, nonatomic, nullable, readonly) NSString *defaultInfoAnnotationFooterText;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationFooterBackgroundColor;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationFooterTextColor;
@property (class, nonatomic, readonly) UIFont *defaultInfoAnnotationFooterFont;

@property (class, nonatomic, readonly) BOOL defaultInfoAnnotationBodyComponentIsLeftIconTappable;
@property (class, nonatomic, readonly) BOOL defaultInfoAnnotationBodyComponentIsRightIconTappable;
@property (class, nonatomic, nullable, readonly) NSString *defaultInfoAnnotationBodyComponentText;
@property (class, nonatomic, nullable, readonly) NSAttributedString *defaultInfoAnnotationBodyComponentStyledText;
@property (class, nonatomic, readonly) NSTextAlignment defaultInfoAnnotationBodyComponentTextAlignment;
@property (class, nonatomic, nullable, readonly) SDCScanditIcon *defaultInfoAnnotationBodyComponentLeftIcon;
@property (class, nonatomic, nullable, readonly) SDCScanditIcon *defaultInfoAnnotationBodyComponentRightIcon;
@property (class, nonatomic, readonly) UIFont *defaultInfoAnnotationBodyComponentFont;
@property (class, nonatomic, readonly) UIColor *defaultInfoAnnotationBodyComponentTextColor;
//clang-format on

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (CGFloat)defaultCircleHighlightSizeForPreset:(SDCBarcodeCheckCircleHighlightPreset)preset;
+ (SDCBrush *)defaultCircleHighlightBrushForPreset:(SDCBarcodeCheckCircleHighlightPreset)preset;
+ (nullable SDCScanditIcon *)defaultCircleHighlightIconForPreset:
    (SDCBarcodeCheckCircleHighlightPreset)preset;

@end

NS_ASSUME_NONNULL_END
