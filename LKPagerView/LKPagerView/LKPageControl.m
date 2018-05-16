//
//  LKPageControl.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPageControl.h"

@interface LKPageControl()

// UIControlState: UIColor
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *strokeColors;

// UIControlState: UIColor
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *fillColors;

// UIControlState: UIBezierPath
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIBezierPath *> *paths;

// UIControlState: UIImage
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *images;

// UIControlState: CGFloat
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *alphas;

// UIControlState: CGAffineTransform
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSValue *> *transforms;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL needsUpdateIndicators;
@property (nonatomic, assign) BOOL needsCreateIndicators;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *indicatorLayers;

@end

@implementation LKPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)commonInit {
    self.itemSpacing = 6;
    self.interitemSpacing = 6;
    self.contentInsets = UIEdgeInsetsZero;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.strokeColors = [NSMutableDictionary dictionary];
    self.fillColors = [NSMutableDictionary dictionary];
    self.paths = [NSMutableDictionary dictionary];
    self.images = [NSMutableDictionary dictionary];
    self.alphas = [NSMutableDictionary dictionary];
    self.transforms = [NSMutableDictionary dictionary];
    self.indicatorLayers = [NSMutableArray array];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    self.contentView = view;
    self.userInteractionEnabled = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, self.frame.size.width - self.contentInsets.left - self.contentInsets.right, self.frame.size.height - self.contentInsets.top - self.contentInsets.bottom);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    NSUInteger diameter = self.itemSpacing;
    NSUInteger spacing = self.interitemSpacing;
    __block CGFloat x = 0;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeading
            || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
            x = 0;
        } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentTrailing
                   || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
            CGFloat contentWidth = diameter * self.numberOfPages + (self.numberOfPages-1)*spacing;
            x = self.contentView.frame.size.width - contentWidth;
        }
    }

#else
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        x = 0;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        CGFloat contentWidth = diameter * self.numberOfPages + (self.numberOfPages-1)*spacing;
        x = self.contentView.frame.size.width - contentWidth;
    }
#endif
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter
        || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill) {
        CGFloat midX = CGRectGetMidX(self.contentView.bounds);
        CGFloat amplitude = self.numberOfPages/2 * diameter + spacing*((self.numberOfPages-1)/2);
        x = midX - amplitude;
    }
    
    [self.indicatorLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull value, NSUInteger index, BOOL * _Nonnull stop) {
        UIControlState state = (index == self.currentPage ? UIControlStateSelected : UIControlStateNormal);
        UIImage *image = self.images[@(state)];
        CGSize size = image ? image.size : CGSizeMake(diameter, diameter);
        CGPoint origin = CGPointMake(x - (size.width-diameter)*0.5, CGRectGetMidY(self.contentView.bounds)-size.height*0.5);
        value.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        x = x + spacing + diameter;
    }];
}

#pragma mark - public method
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self setNeedsCreateIndicators];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self setNeedsUpdateIndicators];
}

- (void)setItemSpacing:(NSInteger)itemSpacing {
    _itemSpacing = itemSpacing;
    [self setNeedsUpdateIndicators];
}

- (void)setInteritemSpacing:(NSInteger)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    [self setNeedsLayout];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    [self setNeedsUpdateIndicators];
}

- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state {
    if (self.strokeColors[@(state)] == strokeColor) {
        return;
    }
    
    self.strokeColors[@(state)] = strokeColor;
    [self setNeedsUpdateIndicators];
}

- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state {
    if (self.fillColors[@(state)] == fillColor) {
        return;
    }
    
    self.fillColors[@(state)] = fillColor;
    [self setNeedsUpdateIndicators];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.images[@(state)] == image) {
        return;
    }
    
    self.images[@(state)] = image;
    [self setNeedsUpdateIndicators];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state {
    if (self.alphas[@(state)].floatValue == alpha) {
        return;
    }
    
    self.alphas[@(state)] = @(alpha);
    [self setNeedsUpdateIndicators];
}

- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state {
    if (self.paths[@(state)] == path) {
        return;
    }
    
    self.paths[@(state)] = path;
    [self setNeedsUpdateIndicators];
}

#pragma mark - private methods
- (void)setNeedsUpdateIndicators {
    self.needsUpdateIndicators = YES;
    [self setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateIndicatorsIfNecessary];
    });
}

- (void)updateIndicatorsIfNecessary {
    if (!self.needsUpdateIndicators || self.indicatorLayers.count == 0) {
        return;
    }
    
    self.needsUpdateIndicators = NO;
    self.contentView.hidden = self.hidesForSinglePage && self.numberOfPages <= 1;
    if (!self.contentView.hidden) {
        for (CAShapeLayer *layer in self.indicatorLayers) {
            layer.hidden = NO;
            [self updateIndicatorAttributesForLayer:layer];
        }
    }
}

- (void)updateIndicatorAttributesForLayer:(CAShapeLayer *)layer {
    NSInteger index = [self.indicatorLayers indexOfObject:layer];
    UIControlState state = (index == self.currentPage ? UIControlStateSelected : UIControlStateNormal);
    UIImage *image = self.images[@(state)];
    if (image) {
        layer.strokeColor = nil;
        layer.fillColor = nil;
        layer.path = nil;
        layer.contents = (__bridge id)image.CGImage;
    } else {
        layer.contents = nil;
        UIColor *strokeColor = self.strokeColors[@(state)];
        UIColor *fillColor = self.fillColors[@(state)];
        if (!strokeColor && !fillColor) {
            layer.fillColor = (state == UIControlStateSelected ? [UIColor whiteColor] : [UIColor grayColor]).CGColor;
            layer.strokeColor = nil;
        } else {
            layer.fillColor = strokeColor.CGColor;
            layer.strokeColor = fillColor.CGColor;
        }
        
        layer.path = self.paths[@(state)].CGPath ? self.paths[@(state)].CGPath : [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.itemSpacing, self.itemSpacing)].CGPath;
    }
    NSValue *transform = self.transforms[@(state)];
    if (transform) {
        layer.transform = CATransform3DMakeAffineTransform([transform CGAffineTransformValue]);
    }
    layer.opacity = self.alphas[@(state)] ? self.alphas[@(state)].floatValue : 1.0;
}

- (void)setNeedsCreateIndicators {
    self.needsCreateIndicators = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createIndicatorsIfNecessary];
    });
}

- (void)createIndicatorsIfNecessary {
    if (!self.needsCreateIndicators) {
        return;
    }
    self.needsCreateIndicators = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.currentPage >= self.numberOfPages) {
        self.currentPage = self.numberOfPages - 1;
    }
    for (CAShapeLayer *layer in self.indicatorLayers) {
        [layer removeFromSuperlayer];
    }
    [self.indicatorLayers removeAllObjects];
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        CAShapeLayer *layer = [CAShapeLayer new];
        layer.actions = @{@"bounds": [NSNull null]};
        [self.contentView.layer addSublayer:layer];
        [self.indicatorLayers addObject:layer];
    }
    [self setNeedsUpdateIndicators];
    [self updateIndicatorsIfNecessary];
    [CATransaction commit];
}

@end
