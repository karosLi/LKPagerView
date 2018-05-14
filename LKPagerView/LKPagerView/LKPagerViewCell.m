//
//  LKPagerViewCell.m
//  LKPagerView
//
//  Created by karos li on 2018/5/7.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "LKPagerViewCell.h"

static void *kvoContext = &kvoContext;

@interface LKPagerViewCell()

@property (nonatomic, strong, readwrite) UILabel *textLabel;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) UIView *selectedForegroundView;

@property (nonatomic, strong) UIColor *selectionColor;

@end

@implementation LKPagerViewCell

- (void)dealloc {
    if (_textLabel) {
        [_textLabel removeObserver:self forKeyPath:@"font" context:kvoContext];
    }
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

- (void)commonInit {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.75;
    self.contentView.layer.shadowOffset = CGSizeZero;
    self.selectionColor = [UIColor colorWithWhite:0.2 alpha:0.2];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.selectedForegroundView.layer.backgroundColor = highlighted ? self.selectionColor.CGColor : [UIColor clearColor].CGColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedForegroundView.layer.backgroundColor = selected ? self.selectionColor.CGColor : [UIColor clearColor].CGColor;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_imageView) {
        _imageView.frame = self.contentView.bounds;
    }
    
    if (_textLabel) {
        CGFloat height = _textLabel.font.pointSize*1.5;
        _textLabel.superview.frame = CGRectMake(self.contentView.bounds.origin.x, self.contentView.frame.size.height-height, self.contentView.bounds.size.width, height);
        CGRect rect = _textLabel.superview.bounds;
        rect = CGRectInset(rect, 8, 0);
        rect.size.height -= 1;
        rect.origin.y += 1;
        _textLabel.frame = rect;
    }
    
    if (_selectedForegroundView) {
        _selectedForegroundView.frame = self.contentView.bounds;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kvoContext) {
        if ([keyPath isEqualToString:@"font"]) {
            [self setNeedsLayout];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        UIView *view = [UIView new];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        
        UILabel *textLabel = [UILabel new];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:view];
        [view addSubview:textLabel];
        [textLabel addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kvoContext];
        
        _textLabel = textLabel;
    }
    
    return _textLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [UIImageView new];
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    
    return _imageView;
}

- (UIView *)selectedForegroundView {
    if (!_imageView) {
        return nil;
    }
    
    if (!_selectedForegroundView) {
        UIView *view = [[UIView alloc] initWithFrame:_imageView.bounds];
        [_imageView addSubview:view];
        _selectedForegroundView = view;
    }
    
    return _selectedForegroundView;
}

@end
