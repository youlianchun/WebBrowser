//
//  PanelTableViewCell.h
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelCellItem.h"

FOUNDATION_EXPORT NSString * kPanelTableViewCell_ID;
FOUNDATION_EXPORT CGFloat kWH_P;//宽高比

@interface PanelTableViewCell : UITableViewCell

-(void)updateContentWithPanelCellItem:(PanelCellItem*)item closeAction:(void(^)())action;

@end
