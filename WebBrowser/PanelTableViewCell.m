//
//  PanelTableViewCell.m
//  WebBrowser
//
//  Created by YLCHUN on 2017/4/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "PanelTableViewCell.h"

NSString * kPanelTableViewCell_ID = @"PanelTableViewCell";
CGFloat kWH_P = 230/300.0;

@interface PanelTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *img_icon;
@property (weak, nonatomic) IBOutlet UILabel *lab_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_content;
@property (nonatomic, copy) void(^closeAction)();
@end

@implementation PanelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)closeAction:(id)sender {
    if (self.closeAction) {
        self.closeAction();
    }
}

-(void)updateContentWithPanelCellItem:(PanelCellItem*)item closeAction:(void(^)())action {
    self.closeAction = action;
    self.img_icon.image = item.icon;
    self.lab_title.text = item.title;
    self.img_content.image = item.image;
    self.img_content.contentMode = UIViewContentModeRedraw;
    UIFont *titleFount;
    UIColor *titleColor;
    if (item.isCurrent) {
        titleFount = [UIFont systemFontOfSize:12 weight:2];
        titleColor = [UIColor colorWithRed:100/255.0 green:170/255.0 blue:255/255.0 alpha:1];
    }else{
        titleFount = [UIFont systemFontOfSize:12];
        titleColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
    }
    self.lab_title.font = titleFount;
    self.lab_title.textColor = titleColor;
}

@end
