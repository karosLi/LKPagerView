//
//  LKPagerViewLayoutAttributes.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPagerViewLayoutAttributes.h"

@implementation LKPagerViewLayoutAttributes

- (BOOL)isEqual:(LKPagerViewLayoutAttributes *)object {
    if (![object isKindOfClass:[LKPagerViewLayoutAttributes class]]) {
        return NO;
    }
    
    BOOL isEqual = [super isEqual:object];
    isEqual = isEqual && (self.position == object.position);
    return isEqual;
}

- (id)copyWithZone:(NSZone *)zone {
    LKPagerViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.position = self.position;
    return copy;
}

@end
