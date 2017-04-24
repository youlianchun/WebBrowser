//
//  TabBarItem.m
//  TabBarController
//
//  Created by YLCHUN on 2017/4/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "TabBarItem.h"
#import "TabBarView.h"

@interface TabBarItem ()
//{
//    UIImage *_selectedIcon;
//}
@property (nonatomic, copy)void(^action)(TabBarItem *item);
@property (nonatomic, weak) TabBarView *tabBar;
@property (nonatomic, retain) UIColor *textColor;

@end

@implementation TabBarItem
-(instancetype)initWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString*)selectedTitle normalIcon:(UIImage *)normalIcon selectedIcon:(UIImage*)selectedIcon normalTextColor:(UIColor*)normalTextColor selectedTextColor:(UIColor*)selectedTextColor action:(void(^)(TabBarItem *item))action {
    self = [super initWithTitle:nil image:nil tag:0];
    if (self) {
        self.action = action;
        self.normalTitle = normalTitle;
        self.selectedTitle = selectedTitle;
        self.normalIcon = normalIcon;
        self.selectedIcon = selectedIcon;
        self.normalTextColor = normalTextColor;
        self.selectedTextColor = selectedTextColor;
    }
    return self;
}

-(instancetype)initWithNormalTitle:(NSString *)normalTitle normalIcon:(UIImage *)normalIcon normalTextColor:(UIColor*)normalTextColor action:(void(^)(TabBarItem *item))action {
    self = [self initWithNormalTitle:normalTitle selectedTitle:nil normalIcon:normalIcon selectedIcon:nil normalTextColor:normalTextColor selectedTextColor:nil action:action];
    return self;
}

-(instancetype)initWithNormalTitle:(NSString *)normalTitle normalIcon:(UIImage *)normalIcon action:(void(^)(TabBarItem *item))action {
    self = [self initWithNormalTitle:normalTitle selectedTitle:nil normalIcon:normalIcon selectedIcon:nil normalTextColor:nil selectedTextColor:nil action:action];
    return self;
}

-(instancetype)initWithAction:(void(^)(TabBarItem *item))action {
    self = [self initWithNormalTitle:nil selectedTitle:nil normalIcon:nil selectedIcon:nil normalTextColor:nil selectedTextColor:nil action:action];
    return self;
}

-(void)doAction {
    if (self.action) {
        self.action(self);
        self.selected = !self.selected;
    }
}

-(void)removeFromTabBar{
    if (self.tabBar) {
        NSMutableArray*items = [self.tabBar.items mutableCopy];
        [items removeObject:self];
        self.tabBar.items = items;
    }
}

-(void)selectedChange {
    NSString *title;
    UIImage *image;
    UIColor *textColor;
    if (!self.nilStatus) {
        if (self.selected) {
            image = self.selectedIcon?self.selectedIcon:self.normalIcon;
            title = self.selectedTitle?self.selectedTitle:self.normalTitle;
            textColor = self.selectedTextColor?self.selectedTextColor:self.normalTextColor;
        }else{
            image = self.normalIcon;
            title = self.normalTitle;
            textColor = self.normalTextColor;
        }
    }
    super.image = image;
    super.selectedImage = image;
    super.title = title;
    self.textColor = textColor;
}

-(void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        [self selectedChange];
    }
}

-(void)setTextColor:(UIColor*)textColor{
    _textColor = textColor;
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_textColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

-(void)setNormalIcon:(UIImage *)normalIcon {
    _normalIcon = [normalIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self selectedChange];
}

-(void)setSelectedIcon:(UIImage *)selectedIcon {
    _selectedIcon = [selectedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self selectedChange];
}

-(void)setNormalTitle:(NSString *)normalTitle {
    _normalTitle = normalTitle;
    [self selectedChange];
}

-(void)setSelectedTitle:(NSString *)selectedTitle {
    _selectedTitle = selectedTitle;
    [self selectedChange];
}

-(void)setNormalTextColor:(UIColor *)normalTextColor {
    _normalTextColor = normalTextColor;
    [self selectedChange];
}

-(void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    [self selectedChange];
}

-(void)setNilStatus:(BOOL)nilStatus {
    if (_nilStatus != nilStatus) {
        _nilStatus = nilStatus;
        [self selectedChange];
    }
}

@end
