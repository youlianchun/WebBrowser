//
//  TabBarView.m
//  TabBarController
//
//  Created by YLCHUN on 2017/4/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "TabBarView.h"
@interface TabBarItem ()
@property (nonatomic, copy)void(^action)(TabBarItem *item);
@property (nonatomic, weak)TabBarView *tabBar;

@end

@interface TabBarView ()
@property (nonatomic, readwrite, weak) id receiver;

@property (nonatomic) UIImageView *lineImageView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UIVisualEffectView *visualEffectView;
@property (nonatomic) BOOL didInit;
@end

@implementation TabBarView

-(instancetype)init{
    self=[super init];
    if (self) {
        [self customIntitialization];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self customIntitialization];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self customIntitialization];
    }
    return self;
}


- (void)customIntitialization{
    if (!self.didInit) {
        self.didInit = YES;
        [self resetStyle];
        self.delegate = (id<TabBarDelegate>) self;
    }
}


-(void)setDelegate:(id<TabBarDelegate>)delegate{
    if ((id<TabBarDelegate>)self != delegate) {
        self.receiver = delegate;
    }
    [super setDelegate:(id<TabBarDelegate>) self];
}

-(void)setItems:(NSArray<TabBarItem *> *)items {
    for (TabBarItem*item in self.items) {
        item.tabBar = nil;
    }
    for (TabBarItem*item in items) {
        item.tabBar = self;
    }
    [super setItems:items];
}

-(UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView=[[UIImageView alloc]init];
        _lineImageView.backgroundColor = [UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:0.3];
        [self insertSubview:_lineImageView atIndex:0];
        _lineImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lineImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lineImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lineImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_lineImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
    }
    return _lineImageView;
}

-(UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]init];
        [self insertSubview:_backgroundImageView atIndex:0];
        _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    return _backgroundImageView;
}

-(UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        _visualEffectView.layer.shadowOffset = CGSizeMake(0, -2);
        _visualEffectView.layer.shadowRadius = 2;
        _visualEffectView.layer.shadowOpacity = 1;
        _visualEffectView.layer.shadowColor = [UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:0.6].CGColor;
        [super insertSubview:_visualEffectView atIndex:0];
        _visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    return _visualEffectView;
}

-(void)resetStyle {
    self.lineImageView.image = nil;
    self.backgroundImageView.image = nil;
    [self visualEffectView];
}


-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
        return;
    }
    [super insertSubview:view atIndex:index];
}

-(UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}
-(void)setShadowColor:(UIColor *)shadowColor {
    self.visualEffectView.layer.shadowColor = [UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:0.6].CGColor;
}

-(UIImage *)backgroundImage {
    return self.backgroundImageView.image;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage {
    self.backgroundImageView.image = backgroundImage;
}

-(UIImage *)lineImage {
    return self.lineImageView.image;
}

-(void)setLineImage:(UIImage *)lineImage {
    self.lineImageView.image = lineImage;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(TabBarItem *)item{
    if ([self.delegate respondsToSelector:@selector(tabBar:shouldSelectWithItem:)]) {
        if (![self.delegate tabBar:self shouldSelectWithItem:item]) {
            return;
        }
    }
    BOOL receiver = YES;
    if ([item isKindOfClass:[TabBarItem class]]) {
        item.selected = !item.selected;
        if (item.action) {
            receiver = NO;
            item.action(item);
        }
    }
    if (receiver && [self.receiver respondsToSelector:@selector(tabBar:didSelectItem:)]) {
        [self.receiver tabBar:tabBar didSelectItem:item];
    }
}



- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString*selName=NSStringFromSelector(aSelector);
    if ([selName hasPrefix:@"keyboardInput"] || [selName isEqualToString:@"customOverlayContainer"]) {//键盘输入代理过滤
        return NO;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

@end
