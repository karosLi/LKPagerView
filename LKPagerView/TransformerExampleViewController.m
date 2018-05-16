//
//  TransformerExampleViewController.m
//  LKPagerViewExample-Objc
//
//  Created by Wenchao Ding on 19/01/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//

#import "TransformerExampleViewController.h"
#import "LKPagerView.h"

@interface TransformerExampleViewController () <UITableViewDataSource,UITableViewDelegate,LKPagerViewDataSource,LKPagerViewDelegate>

@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (strong, nonatomic) NSArray<NSString *> *transformerNames;
@property (assign, nonatomic) NSInteger typeIndex;

@property (weak  , nonatomic) IBOutlet UITableView *tableView;
@property (weak  , nonatomic) IBOutlet LKPagerView *pagerView;

@end

@implementation TransformerExampleViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg"];
    self.transformerNames = @[@"cross fading", @"zoom out", @"depth", @"linear", @"overlap", @"ferris wheel", @"inverted ferris wheel", @"coverflow", @"cubic"];
    [self.pagerView registerClass:[LKPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.pagerView.isInfinite = YES;
    self.typeIndex = 0;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.typeIndex = self.typeIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transformerNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.transformerNames[indexPath.row];
    cell.accessoryType = indexPath.row == self.typeIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.typeIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Transformers";
}

#pragma mark - LKPagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(LKPagerView *)pagerView
{
    return self.imageNames.count;
}

- (LKPagerViewCell *)pagerView:(LKPagerView *)pagerView cellForItemAtIndex:(NSInteger)index
{
    LKPagerViewCell * cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    return cell;
}

#pragma mark - LKPagerViewDelegate

- (void)pagerView:(LKPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
{
    [pagerView deselectItemAtIndex:index animated:YES];
    [pagerView scrollToItemAtIndex:index animated:YES];
}

#pragma mark - Private properties

- (void)setTypeIndex:(NSInteger)typeIndex
{
    _typeIndex = typeIndex;
    LKPagerViewTransformerType type;
    switch (typeIndex) {
        case 0: {
            type = LKPagerViewTransformerTypeCrossFading;
            break;
        }
        case 1: {
            type = LKPagerViewTransformerTypeZoomOut;
            break;
        }
        case 2: {
            type = LKPagerViewTransformerTypeDepth;
            break;
        }
        case 3: {
            type = LKPagerViewTransformerTypeLinear;
            break;
        }
        case 4: {
            type = LKPagerViewTransformerTypeOverlap;
            break;
        }
        case 5: {
            type = LKPagerViewTransformerTypeFerrisWheel;
            break;
        }
        case 6: {
            type = LKPagerViewTransformerTypeInvertedFerrisWheel;
            break;
        }
        case 7: {
            type = LKPagerViewTransformerTypeCoverFlow;
            break;
        }
        case 8: {
            type = LKPagerViewTransformerTypeCubic;
            break;
        }
        default:
            type = LKPagerViewTransformerTypeZoomOut;
            break;
    }
    self.pagerView.transformer = [[LKPagerViewTransformer alloc] initWithType:type];
    switch (type) {
        case LKPagerViewTransformerTypeCrossFading:
        case LKPagerViewTransformerTypeZoomOut:
        case LKPagerViewTransformerTypeDepth: {
            self.pagerView.itemSize = CGSizeZero; // 'Zero' means fill the size of parent
            break;
        }
        case LKPagerViewTransformerTypeLinear:
        case LKPagerViewTransformerTypeOverlap: {
            CGAffineTransform transform = CGAffineTransformMakeScale(0.6, 0.75);
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, transform);
            break;
        }
        case LKPagerViewTransformerTypeFerrisWheel:
        case LKPagerViewTransformerTypeInvertedFerrisWheel: {
            self.pagerView.itemSize = CGSizeMake(180, 140);
            break;
        }
        case LKPagerViewTransformerTypeCoverFlow: {
            self.pagerView.itemSize = CGSizeMake(220, 170);
            break;
        }
        case LKPagerViewTransformerTypeCubic: {
            CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, transform);
            break;
        }
        default:
            break;
    }
}

@end


