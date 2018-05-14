//
//  LKPagerView.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPagerView.h"
#import "LKPagerViewLayout.h"
#import "LKPageCollectionView.h"

@interface LKPagerView()

@property (nonatomic, strong) LKPagerViewLayout *collectionViewLayout;
@property (nonatomic, strong) LKPageCollectionView *collectionView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, readwrite) NSInteger numberOfItems;
@property (nonatomic, assign, readwrite) NSInteger numberOfSections;

@property (nonatomic, assign) NSInteger dequeingSection;
@property (nonatomic, strong) NSIndexPath *centermostIndexPath;

@end

@implementation LKPagerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

- (NSIndexPath *)centermostIndexPath {
    if (self.numberOfItems == 0 || CGSizeEqualToSize(self.collectionView.contentSize, CGSizeZero)) {
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    NSMutableArray *sortedIndexPaths = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull l, NSIndexPath * _Nonnull r) {
//        CGRect leftFrame = [self.collectionViewLayout frame];
        
        return NSOrderedSame;
    }];
    
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

@end
