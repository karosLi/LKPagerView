//
//  LKPageControl.h
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKPageControl : UIControl

/// The number of page indicators of the page control. Default is 0.
@property (nonatomic, assign) NSInteger numberOfPages;

/// The current page, highlighted by the page control. Default is 0.
@property (nonatomic, assign) NSInteger currentPage;

/// The spacing to use of page indicators in the page control.
@property (nonatomic, assign) NSInteger itemSpacing;

/// The spacing to use between page indicators in the page control.
@property (nonatomic, assign) NSInteger interitemSpacing;

/// The distance that the page indicators is inset from the enclosing page control.
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// The horizontal alignment of content within the control’s bounds. Default is center.
//@property (nonatomic, assign) UIControlContentHorizontalAlignment contentHorizontalAlignment;

/// Hide the indicator if there is only one page. default is NO
@property (nonatomic, assign) BOOL hidesForSinglePage;


/// Sets the stroke color for page indicators to use for the specified state. (selected/normal).
///
/// - Parameters:
///   - strokeColor: The stroke color to use for the specified state.
///   - state: The state that uses the specified stroke color.
- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state;

/// Sets the fill color for page indicators to use for the specified state. (selected/normal).
///
/// - Parameters:
///   - fillColor: The fill color to use for the specified state.
///   - state: The state that uses the specified fill color.
- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state;

/// Sets the image for page indicators to use for the specified state. (selected/normal).
///
/// - Parameters:
///   - image: The image to use for the specified state.
///   - state: The state that uses the specified image.
- (void)setImage:(UIImage *)image forState:(UIControlState)state;

/// Sets the alpha value for page indicators to use for the specified state. (selected/normal).
///
/// - Parameters:
///   - alpha: The alpha value to use for the specified state.
///   - state: The state that uses the specified alpha.
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;

/// Sets the path for page indicators to use for the specified state. (selected/normal).
///
/// - Parameters:
///   - path: The path to use for the specified state.
///   - state: The state that uses the specified path.
- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state;

@end
