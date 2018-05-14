//
//  LKPageCollectionView.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPageCollectionView.h"

@implementation LKPageCollectionView

- (BOOL)scrollsToTop {
    return NO;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    [super setScrollsToTop:NO];
}

- (UIEdgeInsets)contentInset {
    return [super contentInset];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:UIEdgeInsetsZero];
    if (contentInset.top > 0) {
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y+contentInset.top);
    }
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (void)commonInit {
    self.contentInset = UIEdgeInsetsZero;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if(@available(ios 10.0, *)) {
        self.prefetchingEnabled = NO;
    }
    if(@available(ios 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
   
    self.scrollsToTop = NO;
}

@end
