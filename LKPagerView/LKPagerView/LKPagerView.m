//
//  LKPagerView.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPagerView.h"
#import "LKPagerViewLayout.h"
#import "LKPagerViewCollectionView.h"

@interface LKPagerView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) LKPagerViewLayout *collectionViewLayout;
@property (nonatomic, strong) LKPagerViewCollectionView *collectionView;
@property (nonatomic, strong) UIView *contentView;

/// public
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, readwrite) NSInteger numberOfItems;
@property (nonatomic, assign, readwrite) NSInteger numberOfSections;
@property (nonatomic, assign, readwrite) CGFloat scrollOffset;

/// internal
@property (nonatomic, assign) NSInteger dequeingSection;
@property (nonatomic, strong) NSIndexPath *centermostIndexPath;
@property (nonatomic, strong) NSIndexPath *possibleTargetingIndexPath;

@end

@implementation LKPagerView

#pragma mark - Public properties
- (void)setScrollDirection:(LKPagerViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setAutomaticSlidingInterval:(CGFloat)automaticSlidingInterval {
    _automaticSlidingInterval = automaticSlidingInterval;
    [self cancelTimer];
    if (_automaticSlidingInterval > 0) {
        [self startTimer];
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setItemSize:(CGSize)itemSize{
    _itemSize = itemSize;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setIsInfinite:(BOOL)isInfinite {
    _isInfinite = isInfinite;
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical {
    _alwaysBounceVertical = alwaysBounceVertical;
    self.collectionView.alwaysBounceVertical = alwaysBounceVertical;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    
    if (backgroundView) {
        if (backgroundView.superview) {
            [backgroundView removeFromSuperview];
        }
        
        [self insertSubview:backgroundView atIndex:0];
        [self setNeedsLayout];
    }
}

- (void)setTransformer:(LKPagerViewTransformer *)transformer {
    _transformer = transformer;
    _transformer.pagerView = self;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setRemovesInfiniteLoopForSingleItem:(BOOL)removesInfiniteLoopForSingleItem {
    _removesInfiniteLoopForSingleItem = removesInfiniteLoopForSingleItem;
    [self reloadData];
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.collectionView.panGestureRecognizer;
}


#pragma mark - Public readonly-properties
/// Returns whether the user has touched the content to initiate scrolling.
- (BOOL)isTracking {
    return self.collectionView.isTracking;
}

- (CGFloat)scrollOffset {
    CGFloat contentOffset = MAX(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    CGFloat scrollOffset = (contentOffset/self.collectionViewLayout.itemSpacing);
    return fmod((scrollOffset), (self.numberOfItems));
}

- (NSIndexPath *)centermostIndexPath {
    if (self.numberOfItems == 0 || CGSizeEqualToSize(self.collectionView.contentSize, CGSizeZero)) {
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    NSArray *sortedIndexPaths = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull l, NSIndexPath * _Nonnull r) {
        CGRect leftFrame = [self.collectionViewLayout frameForIndexPath:l];
        CGRect rightFrame = [self.collectionViewLayout frameForIndexPath:r];
        CGFloat leftCenter;
        CGFloat rightCenter;
        CGFloat ruler;
        
        if (self.scrollDirection == LKPagerViewScrollDirectionHorizontal) {
            leftCenter = CGRectGetMidX(leftFrame);
            rightCenter = CGRectGetMidX(rightFrame);
            ruler = CGRectGetMidX(self.collectionView.bounds);
        } else {
            leftCenter = CGRectGetMidY(leftFrame);
            rightCenter = CGRectGetMidY(rightFrame);
            ruler = CGRectGetMidY(self.collectionView.bounds);
        }
        
        if (fabs(ruler-leftCenter) < fabs(ruler-rightCenter)) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    if (sortedIndexPaths.firstObject) {
        return sortedIndexPaths.firstObject;
    }
    
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.collectionView.frame = self.contentView.bounds;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self startTimer];
    } else {
        [self cancelTimer];
    }
}

- (void)prepareForInterfaceBuilder {
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:25];
    label.text = @"LKPagerView";
    [self.contentView addSubview:label];
}

- (void)dealloc {
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    id<LKPagerViewDataSource> dataSource = self.dataSource;
    if (!dataSource) {
        return 1;
    }
    
    self.numberOfItems = [dataSource numberOfItemsInPagerView:self];
    if (self.numberOfItems <= 0) {
        return 0;
    }
    
    self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? (int)(INT16_MAX)/self.numberOfItems : 1;
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item;
    self.dequeingSection = indexPath.section;
    LKPagerViewCell *cell = [self.dataSource pagerView:self cellForItemAtIndex:index];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldHighlightItemAtIndex:)]) {
        return [self.delegate pagerView:self shouldHighlightItemAtIndex:indexPath.item % self.numberOfItems];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didHighlightItemAtIndex:)]) {
        [self.delegate pagerView:self didHighlightItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldSelectItemAtIndex:)]) {
        return [self.delegate pagerView:self shouldSelectItemAtIndex:indexPath.item % self.numberOfItems];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didSelectItemAtIndex:)]) {
        self.possibleTargetingIndexPath = indexPath;
        [self.delegate pagerView:self didSelectItemAtIndex:indexPath.item % self.numberOfItems];
        self.possibleTargetingIndexPath = nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:willDisplayCell:forItemAtIndex:)]) {
        [self.delegate pagerView:self willDisplayCell:(LKPagerViewCell *)cell forItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didEndDisplayingCell:forItemAtIndex:)]) {
        [self.delegate pagerView:self didEndDisplayingCell:(LKPagerViewCell *)cell forItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfItems > 0) {
        // In case someone is using KVO
        NSInteger currentIndex = lround((self.scrollOffset)) % self.numberOfItems;
        if (currentIndex != self.currentIndex) {
            self.currentIndex = currentIndex;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(pagerViewDidScroll:)]) {
        [self.delegate pagerViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillBeginDragging:)]) {
        [self.delegate pagerViewWillBeginDragging:self];
    }
    
    if (self.automaticSlidingInterval > 0) {
        [self cancelTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillEndDragging:targetIndex:)]) {
        CGFloat contentOffset = self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? targetContentOffset->x : targetContentOffset->y;
        NSInteger targetItem = lround((contentOffset/self.collectionViewLayout.itemSpacing));
        [self.delegate pagerViewWillEndDragging:self targetIndex:targetItem % self.numberOfItems];
    }
    
    if (self.automaticSlidingInterval > 0) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndDecelerating:)]) {
        [self.delegate pagerViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndScrollAnimation:)]) {
        [self.delegate pagerViewDidEndScrollAnimation:self];
    }
}

#pragma mark - register class
/// Register a class for use in creating new pager view cells.
///
/// - Parameters:
///   - cellClass: The class of a cell that you want to use in the pager view.
///   - identifier: The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
- (void)registerClass:(Class)class forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
}

/// Register a nib file for use in creating new pager view cells.
///
/// - Parameters:
///   - nib: The nib object containing the cell object. The nib file must contain only one top-level object and that object must be of the type FSPagerViewCell.
///   - identifier: The reuse identifier to associate with the specified nib file. This parameter must not be nil and must not be an empty string.
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

/// Returns a reusable cell object located by its identifier
///
/// - Parameters:
///   - identifier: The reuse identifier for the specified cell. This parameter must not be nil.
///   - index: The index specifying the location of the cell.
/// - Returns: A valid FSPagerViewCell object.
- (__kindof LKPagerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier atIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.dequeingSection];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (![cell isKindOfClass:[LKPagerViewCell class]]) {
        @throw [NSException exceptionWithName:@"" reason:@"Cell class must be subclass of LKPagerViewCell" userInfo:nil];
    }
    
    return (LKPagerViewCell *)cell;
}

/// Reloads all of the data for the collection view.
- (void)reloadData {
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
}

/// Selects the item at the specified index and optionally scrolls it into view.
///
/// - Parameters:
///   - index: The index path of the item to select.
///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    UICollectionViewScrollPosition scrollPosition = self.scrollDirection == LKPagerViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

/// Deselects the item at the specified index.
///
/// - Parameters:
///   - index: The index of the item to deselect.
///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

/// Scrolls the pager view contents until the specified item is visible.
///
/// - Parameters:
///   - index: The index of the item to scroll into view.
///   - animated: Specify true to animate the scrolling behavior or false to adjust the pager view’s visible content immediately.
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= self.numberOfItems) {
        @throw [NSException exceptionWithName:@"" reason:[NSString stringWithFormat:@"index %@ is out of range [0...\(self.numberOfItems-1)]", @(index)] userInfo:nil];
    }
    
    NSIndexPath *indexPath = [self.possibleTargetingIndexPath copy];
    if (indexPath && indexPath.item == index) {
        self.possibleTargetingIndexPath = nil;
    } else if (self.numberOfItems > 1) {
        indexPath = [self nearbyIndexPathForIndex:index];
    } else {
        indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    }
    
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:indexPath];
    [self.collectionView setContentOffset:contentOffset animated:animated];
}

/// Returns the index of the specified cell.
///
/// - Parameter cell: The cell object whose index you want.
/// - Returns: The index of the cell or NSNotFound if the specified cell is not in the pager view.
- (NSInteger)indexForCell:(LKPagerViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) {
        return NSNotFound;
    }
    
    return indexPath.item;
}

- (void)commonInit {
    // Content View
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    // UICollectionView
    LKPagerViewLayout *collectionViewLayout = [LKPagerViewLayout new];
    LKPagerViewCollectionView *collectionView = [[LKPagerViewCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
}

#pragma mark - timer
- (void)startTimer {
    if (self.automaticSlidingInterval <= 0 || self.timer) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.automaticSlidingInterval target:self selector:@selector(flipNextSender:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)flipNextSender:(NSTimer *)timer {
    if (!self.superview || !self.window || self.numberOfItems <=0 || self.isTracking) {
        return;
    }
    
    NSIndexPath *indexPath = self.centermostIndexPath;
    NSInteger section = self.numberOfSections > 1 ? (indexPath.section+(indexPath.item+1)/self.numberOfItems) : 0;
    NSInteger item = (indexPath.item+1) % self.numberOfItems;
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
    [self.collectionView setContentOffset:contentOffset animated:YES];
}

- (void)cancelTimer {
    if (!self.timer) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}

- (NSIndexPath *)nearbyIndexPathForIndex:(NSInteger)index {
    // Is there a better algorithm?
    NSInteger currentIndex = self.currentIndex;
    NSInteger currentSection = self.centermostIndexPath.section;
    if (labs(currentIndex-index) <= self.numberOfItems/2) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection];
    } else if (index-currentIndex >= 0) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection-1];
    } else {
        return [NSIndexPath indexPathForItem:index inSection:currentSection+1];
    }
}

@end
