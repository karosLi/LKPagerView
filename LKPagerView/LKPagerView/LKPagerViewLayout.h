//
//  LKPagerViewLayout.h
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKPagerView.h"

@interface LKPagerViewLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGFloat leadingSpacing;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) BOOL needsReprepare;

@property (nonatomic, assign) LKPagerViewScrollDirection scrollDirection;

- (void)forceInvalidate;
- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath;
- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath;

@end
