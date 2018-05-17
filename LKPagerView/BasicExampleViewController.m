//
//  BasicExampleViewController.m
//  FSPagerViewExample-Objc
//
//  Created by Wenchao Ding on 19/01/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//

#import "BasicExampleViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "LKPagerView.h"

@interface BasicExampleViewController () <UITableViewDataSource,UITableViewDelegate,LKPagerViewDataSource,LKPagerViewDelegate>

@property (strong, nonatomic) NSArray<NSString *> *sectionTitles;
@property (strong, nonatomic) NSArray<NSString *> *configurationTitles;
@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (assign, nonatomic) NSInteger numberOfItems;

@property (weak  , nonatomic) IBOutlet UITableView *tableView;
@property (weak  , nonatomic) IBOutlet LKPagerView *pagerView;
@property (weak  , nonatomic) IBOutlet LKPageControl *pageControl;

- (IBAction)sliderValueChanged:(UISlider *)sender;

@end

@implementation BasicExampleViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionTitles = @[@"Configurations", @"Item Size", @"Interitem Spacing", @"Number Of Items"];
    self.configurationTitles = @[@"Automatic sliding", @"Infinite"];
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg"];
    self.numberOfItems = 7;
    
    [self.pagerView registerClass:[LKPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.pagerView.itemSize = self.pagerView.frame.size;
    self.pageControl.numberOfPages = self.imageNames.count;
    self.pageControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.pageControl.contentInsets = UIEdgeInsetsMake(0, 20, 0, 20);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.configurationTitles.count;
        case 1:
        case 2:
        case 3:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // Configurations
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = self.configurationTitles[indexPath.row];
            if (indexPath.row == 0) {
                // Automatic Sliding
                cell.accessoryType = self.pagerView.automaticSlidingInterval > 0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            } else if (indexPath.row == 1) {
                // IsInfinite
                cell.accessoryType = self.pagerView.isInfinite ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            return cell;
        }
        case 1: {
            // Item Spacing
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = indexPath.section;
            slider.value = ({
                CGFloat scale = self.pagerView.itemSize.width/self.pagerView.frame.size.width;
                CGFloat value = (scale-0.5)*2;
                value;
            });
            slider.continuous = YES;
            return cell;
        }
        case 2: {
            // Interitem Spacing
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = indexPath.section;
            slider.value = self.pagerView.interitemSpacing / 20.0;
            slider.continuous = YES;
            return cell;
        }
        case 3: {
            // Number Of Items
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = indexPath.section;
            slider.value = self.numberOfItems / 7.0;
            slider.minimumValue = 1.0 / 7;
            slider.maximumValue = 1.0;
            slider.continuous = NO;
            return cell;
        }
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"cell"];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                // Automatic Sliding
                self.pagerView.automaticSlidingInterval = 3.0 - self.pagerView.automaticSlidingInterval;
            } else if (indexPath.row == 1) {
                // IsInfinite
                self.pagerView.isInfinite = !self.pagerView.isInfinite;
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 40 : 20;
}

#pragma mark - LKPagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(LKPagerView *)pagerView
{
    return self.numberOfItems;
}

- (LKPagerViewCell *)pagerView:(LKPagerView *)pagerView cellForItemAtIndex:(NSInteger)index
{
    LKPagerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]]; // 这句解码是在主线程，会耗CPU，所以会看到第一次我们进来的时候会卡顿一次，一般项目里面会使用图片库来异步解码并保存解码后的图片数据的。
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@(index),@(index)];
    
// 如果纯设置颜色不会卡顿
//    int R = (arc4random() % 256) ;
//    int G = (arc4random() % 256) ;
//    int B = (arc4random() % 256) ;
//    [cell setBackgroundColor:[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]];
    
// 如果异步解码也不会卡顿
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *decodedImage = [self decodedImageWithImage:[UIImage imageNamed:self.imageNames[index]]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.imageView.image = decodedImage;
//        });
//    });
    
    return cell;
}

#pragma mark - LKPagerView Delegate

- (void)pagerView:(LKPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
{
    [pagerView deselectItemAtIndex:index animated:YES];
    [pagerView scrollToItemAtIndex:index animated:YES];
    self.pageControl.currentPage = index;
}

- (void)pagerViewDidScroll:(LKPagerView *)pagerView
{
    if (self.pageControl.currentPage != pagerView.currentIndex) {
        self.pageControl.currentPage = pagerView.currentIndex;
    }
}

#pragma mark - Target actions

- (void)sliderValueChanged:(UISlider *)sender
{
    switch (sender.tag) {
        case 1: {
            CGFloat scale = 0.5 * (1 + sender.value); // [0.5 - 1.0]
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, CGAffineTransformMakeScale(scale, scale));
            break;
        }
        case 2: {
            self.pagerView.interitemSpacing = sender.value * 20; // [0 - 20]
            break;
        }
        case 3: {
            self.numberOfItems = roundf(sender.value * 7);
            self.pageControl.numberOfPages = self.numberOfItems;
            [self.pagerView reloadData];
            break;
        }
        default:
            break;
    }
}

- (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    @autoreleasepool{
        
        CGImageRef imageRef = image.CGImage;
        CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        size_t bytesPerRow = 8 * width;
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     8,
                                                     bytesPerRow,
                                                     colorspaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        if (context == NULL) {
            return image;
        }
        
        // Draw the image into the context and retrieve the new bitmap image without alpha
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}

@end

