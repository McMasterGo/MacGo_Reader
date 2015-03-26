//  ItemController.h
//  QRCodeReader
//
//  Created by Simon Quach on 2015-02-08.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol ItemControllerProtocol <NSObject>

- (void)quantityDidChange:(NSInteger)quantity;

@end

@interface ItemController : UITableViewCell

@property (assign) id<ItemControllerProtocol> delegate;

@property (weak, nonatomic) IBOutlet UILabel *itemLabelName;

@property (weak, nonatomic) IBOutlet UILabel *itemLabelCost;

@property (weak, nonatomic) IBOutlet UILabel *itemCounter;

@property (weak, nonatomic) IBOutlet UITextField *numberOfItems;

@property (weak, nonatomic) IBOutlet UIButton *buttonMinus;

@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;

@end
