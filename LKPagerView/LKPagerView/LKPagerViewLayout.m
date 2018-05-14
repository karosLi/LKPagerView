//
//  LKPagerViewLayout.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPagerViewLayout.h"
#import "LKPagerViewLayoutAttributes.h"
#import "LKPagerViewTransformer.h"

@interface LKPagerViewLayout()

@property (nonatomic, assign) BOOL isInfinite;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) CGFloat actualInteritemSpacing;
@property (nonatomic, assign) CGSize actualItemSize;

@end

@implementation LKPagerViewLayout

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (LKPagerView *)pagerView {
    if ([self.collectionView.superview.superview isKindOfClass:[LKPagerView class]]) {
        return (LKPagerView *)self.collectionView.superview.superview;
    }
    
    return nil;
}

- (Class)layoutAttributesClass {
    return LKPagerViewLayoutAttributes.class;
}

- (instancetype)init {
    self = [super init];
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.needsReprepare = YES;
    self.isInfinite = YES;
    self.numberOfSections = 1;
}

- (void)prepareLayout {
    UICollectionView *collectionView = self.collectionView;
    LKPagerView *pagerView = [self pagerView];
    
    if (!collectionView || !pagerView) {
        return;
    }
    
    if (!self.needsReprepare || !CGSizeEqualToSize(self.collectionViewSize, collectionView.frame.size)) {
        return;
    }
    
    self.needsReprepare = NO;
    self.collectionViewSize = collectionView.frame.size;
    
    self.numberOfSections = [pagerView numberOfSectionsInCollectionView:collectionView];
    self.numberOfItems = [pagerView collectionView:collectionView numberOfItemsInSection:0];
    self.actualItemSize = CGSizeEqualToSize(pagerView.itemSize, CGSizeZero) ? collectionView.frame.size : pagerView.itemSize;
    self.actualInteritemSpacing = pagerView.transformer ? [pagerView.transformer proposedInteritemSpacing] : pagerView.interitemSpacing;
    self.scrollDirection = pagerView.scrollDirection;
    self.leadingSpacing = self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? (collectionView.frame.size.width-self.actualItemSize.width)*0.5 : (collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    self.itemSpacing = (self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing;
    
    NSInteger numberOfItems = self.numberOfItems*self.numberOfSections;
    if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
        CGFloat contentSizeWidth = self.leadingSpacing*2; // Leading & trailing spacing
        contentSizeWidth += (numberOfItems-1)*self.actualInteritemSpacing; // Interitem spacing
        contentSizeWidth += (numberOfItems)*self.actualItemSize.width; // Item sizes
        self.contentSize = CGSizeMake(contentSizeWidth, collectionView.frame.size.height);
    } else {
        CGFloat contentSizeHeight = self.leadingSpacing*2; // Leading & trailing spacing
        contentSizeHeight += (numberOfItems-1)*self.actualInteritemSpacing; // Interitem spacing
        contentSizeHeight += (numberOfItems)*self.actualItemSize.height; // Item sizes
        self.contentSize = CGSizeMake(collectionView.frame.size.width, contentSizeHeight);
    }
    
    [self adjustCollectionViewBounds];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray array];
    if (self.itemSpacing <= 0 || CGRectIsEmpty(rect)) {
        return layoutAttributes;
    }
    
    CGRect rect1 = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectIsEmpty(rect1)) {
        return layoutAttributes;
    }
    
    // Calculate start position and index of certain rects
    NSInteger numberOfItemsBefore = self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? MAX((int)((CGRectGetMinX(rect1)-self.leadingSpacing)/self.itemSpacing),0) : MAX((int)((CGRectGetMinY(rect1)-self.leadingSpacing)/self.itemSpacing),0);
    CGFloat startPosition = self.leadingSpacing + (numberOfItemsBefore)*self.itemSpacing;
    NSInteger startIndex = numberOfItemsBefore;
    // Create layout attributes
    NSInteger itemIndex = startIndex;
    
    CGFloat origin = startPosition;
    CGFloat maxPosition = self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? MIN(CGRectGetMaxX(rect1),self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : MIN(CGRectGetMaxY(rect1),self.contentSize.height-self.actualItemSize.height-self.leadingSpacing);
    // https://stackoverflow.com/a/10335601/2398107
    CGFloat origin_maxPosition = 0;
    while (origin_maxPosition <= MAX(100.0 * DBL_EPSILON * fabs(origin+maxPosition), DBL_MIN)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex%self.numberOfItems inSection:itemIndex/self.numberOfItems];
        LKPagerViewLayoutAttributes *attributes = (LKPagerViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        [self applyTransformToAttributes:attributes withTransformer:[self pagerView].transformer];
        [layoutAttributes addObject:attributes];
        itemIndex += 1;
        origin += self.itemSpacing;
    }
    
    return layoutAttributes;
}

- (LKPagerViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    LKPagerViewLayoutAttributes *attributes = [[LKPagerViewLayoutAttributes alloc] init];
    attributes.indexPath = indexPath;
    CGRect frame = [self frameForIndexPath:indexPath];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    attributes.center = center;
    attributes.size = self.actualItemSize;
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    UICollectionView *collectionView = self.collectionView;
    
    if (!collectionView) {
        return proposedContentOffset;
    }
    
    CGFloat proposedContentOffsetX = 0;
    CGFloat proposedContentOffsetY = 0;
    
    if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
        proposedContentOffsetX = proposedContentOffset.x;
        proposedContentOffsetY = proposedContentOffset.y;
    } else {
        {
            CGFloat translation = -[collectionView.panGestureRecognizer translationInView:collectionView].x;
            CGFloat offset = round(proposedContentOffset.x/self.itemSpacing)*self.itemSpacing;
            CGFloat minFlippingDistance = MIN(0.5 * self.itemSpacing,150);
            CGFloat originalContentOffsetX = collectionView.contentOffset.x - translation;
            if (fabs(translation) <= minFlippingDistance) {
                if (fabs(velocity.x) >= 0.3 && fabs(proposedContentOffset.x-originalContentOffsetX) <= self.itemSpacing*0.5) {
                    offset += self.itemSpacing * (velocity.x)/fabs(velocity.x);
                }
            }
            proposedContentOffsetX = offset;
        }
        {
            CGFloat translation = -[collectionView.panGestureRecognizer translationInView:collectionView].y;
            CGFloat offset = round(proposedContentOffset.y/self.itemSpacing)*self.itemSpacing;
            CGFloat minFlippingDistance = MIN(0.5 * self.itemSpacing,150);
            CGFloat originalContentOffsetY = collectionView.contentOffset.y - translation;
            if (fabs(translation) <= minFlippingDistance) {
                if (fabs(velocity.y) >= 0.3 && fabs(proposedContentOffset.y-originalContentOffsetY) <= self.itemSpacing*0.5) {
                    offset += self.itemSpacing * (velocity.y)/fabs(velocity.y);
                }
            }
            proposedContentOffsetY = offset;
        }
    }
    
    return CGPointMake(proposedContentOffsetX, proposedContentOffsetY);
}

- (void)forceInvalidate {
    self.needsReprepare = YES;
    [self invalidateLayout];
}

- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath {
    CGPoint origin = [self frameForIndexPath:indexPath].origin;
    UICollectionView *collectionView = self.collectionView;
    
    if (!collectionView) {
        return origin;
    }
    
    CGFloat contentOffsetX = 0;
    CGFloat contentOffsetY = 0;
    if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
        
    } else {
        contentOffsetX = origin.x - (collectionView.frame.size.width*0.5-self.actualItemSize.width*0.5);
        contentOffsetY = origin.y - (collectionView.frame.size.height*0.5-self.actualItemSize.height*0.5);
    }
    
    CGPoint contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
    return contentOffset;
}

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = self.numberOfItems*indexPath.section + indexPath.item;
    CGFloat originX = 0;
    CGFloat originY = 0;
    if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
        originX = (self.collectionView.frame.size.width-self.actualItemSize.width)*0.5;
        originY = (self.collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    } else {
        originX = self.leadingSpacing + (numberOfItems)*self.itemSpacing;
        originY = self.leadingSpacing + (numberOfItems)*self.itemSpacing;
    }
    
    CGRect rect = CGRectMake(originX, originY, self.actualItemSize.width, self.actualItemSize.height);
    return rect;
}

- (void)didReceiveNotification:(NSNotification *)notification {
    if (CGSizeEqualToSize([self pagerView].itemSize, CGSizeZero)) {
        [self adjustCollectionViewBounds];
    }
}

- (void)adjustCollectionViewBounds {
    UICollectionView *collectionView = self.collectionView;
    LKPagerView *pagerView = [self pagerView];
    
    if (!collectionView || !pagerView) {
        return;
    }
    
    NSInteger currentIndex = MAX(0, MIN(pagerView.currentIndex, pagerView.numberOfItems - 1));
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:self.isInfinite ? self.numberOfSections/2 : 0];
    CGPoint contentOffset = [self contentOffsetForIndexPath:newIndexPath];
    CGRect newBounds = CGRectMake(contentOffset.x, contentOffset.y, collectionView.frame.size.width, collectionView.frame.size.height);
    collectionView.bounds = newBounds;
    pagerView.currentIndex = currentIndex;
}

- (void)applyTransformToAttributes:(LKPagerViewLayoutAttributes *)attributes withTransformer:(LKPagerViewTransformer *)transformer {
    UICollectionView *collectionView = self.collectionView;
    
    if (!collectionView || !transformer) {
        return;
    }
    
    if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
        CGFloat ruler = CGRectGetMidX(collectionView.bounds);
        attributes.position = (attributes.center.x-ruler)/self.itemSpacing;
    } else {
        CGFloat ruler = CGRectGetMidY(collectionView.bounds);
        attributes.position = (attributes.center.y-ruler)/self.itemSpacing;
    }
    
    attributes.zIndex = (int)(self.numberOfItems)-(int)(attributes.position);
    [transformer applyTransformToAttributes:attributes];
}

@end
