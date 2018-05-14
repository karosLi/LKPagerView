//
//  LKPagerView.h
//  LKPagerView 把FSPagerView(https://github.com/WenchaoD)转成 OC 代码
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKPagerViewCell.h"
#import "LKPagerViewTransformer.h"

@class LKPagerView;

@protocol LKPagerViewDataSource <NSObject>

/// item 数量
- (NSInteger)numberOfItemsInPagerView;

/// 每个 item 的控件
- (LKPagerViewCell *)pagerView:(LKPagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

@end

@protocol LKPagerViewDelegate <NSObject>

@optional

/// 高亮 item
- (void)pagerView:(LKPagerView *)pagerView didHighlightItemAtIndex:(NSInteger)index;

/// 是否 item 应该被选中
- (BOOL)pagerView:(LKPagerView *)pagerView shouldSelectItemAtIndex:(NSInteger)index;

/// 选中 item
- (void)pagerView:(LKPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index;

/// 即将显示的 cell
- (void)pagerView:(LKPagerView *)pagerView willDisplayCell:(LKPagerViewCell *)cell forItemAtIndex:(NSInteger)index;

/// 已经显示的 cell
- (void)pagerView:(LKPagerView *)pagerView didEndDisplayingCell:(LKPagerViewCell *)cell forItemAtIndex:(NSInteger)index;

/// 即将拖拽
- (void)pagerViewWillBeginDragging:(LKPagerView *)pagerView;

/// 结束拖拽
- (void)pagerViewWillEndDragging:(LKPagerView *)pagerView targetIndex:(NSInteger)targetIndex;

/// 用户滚动了 pager
- (void)pagerViewDidScroll:(LKPagerView *)pagerView;

/// 动画停止滚动 pager
- (void)pagerViewDidEndScrollAnimation:(LKPagerView *)pagerView;

/// pager 已经完成减速
- (void)pagerViewDidEndDecelerating:(LKPagerView *)pagerView;

@end

typedef NS_ENUM(NSInteger, LKPagerViewScrollDirection){
    LKPagerViewScrollDirectionHorizontal,
    LKPagerViewScrollDirectionVertical,
};

IB_DESIGNABLE @interface LKPagerView : UIView

@property (nonatomic, weak) IBOutlet id<LKPagerViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<LKPagerViewDelegate> delegate;

@property (nonatomic, assign) LKPagerViewScrollDirection scrollDirection;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

/// The spacing to use between items in the pager view. Default is 0.
@property (nonatomic, assign) CGFloat interitemSpacing;

 /// The item size of the pager view. .zero means always fill the bounds of the pager view. Default is .zero.
@property (nonatomic, assign) CGSize itemSize;

/// The transformer of the pager view.
@property (nonatomic, strong) LKPagerViewTransformer *transformer;

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

@end
