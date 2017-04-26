//
//  PanelCellItem.h
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PanelCellItem : NSObject
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isCurrent;
@property (nonatomic, retain) UIImage *image;
@end
