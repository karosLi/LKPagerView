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
@property (nonatomic, assign) NSUInteger numberOfPages;

/// The current page, highlighted by the page control. Default is 0.
@property (nonatomic, assign) NSUInteger currentPage;

/// The spacing to use of page indicators in the page control.
@property (nonatomic, assign) NSUInteger itemSpacing;

/// The spacing to use between page indicators in the page control.
@property (nonatomic, assign) NSUInteger interitemSpacing;

/// The distance that the page indicators is inset from the enclosing page control.
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// Hide the indicator if there is only one page. default is YES
@property (nonatomic, assign) BOOL hidesForSinglePage;

@end
