//
//  LKPagerViewTransformer.h
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKPagerViewLayoutAttributes.h"

@class LKPagerView;

typedef NS_ENUM(NSInteger, LKPagerViewTransformerType) {
    LKPagerViewTransformerTypeCrossFading,
    LKPagerViewTransformerTypeZoomOut,
    LKPagerViewTransformerTypeDepth,
    LKPagerViewTransformerTypeOverlap,
    LKPagerViewTransformerTypeLinear,
    LKPagerViewTransformerTypeCoverFlow,
    LKPagerViewTransformerTypeFerrisWheel,
    LKPagerViewTransformerTypeInvertedFerrisWheel,
    LKPagerViewTransformerTypeCubic,
};

@interface LKPagerViewTransformer : NSObject

@property (nonatomic, weak) LKPagerView *pagerView;
@property (nonatomic, assign, readonly) LKPagerViewTransformerType type;

@property (nonatomic, assign) CGFloat minimumScale;
@property (nonatomic, assign) CGFloat minimumAlpha;

- (instancetype)initWithType:(LKPagerViewTransformerType)type;

- (void)applyTransformToAttributes:(LKPagerViewLayoutAttributes *)attributes;

// An interitem spacing proposed by transformer class. This will override the default interitemSpacing provided by the pager view.
- (CGFloat)proposedInteritemSpacing;

@end
