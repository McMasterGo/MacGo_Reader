//  ViewController.h
//  QRCodeReader
//
//  Created by Simon Quach on 2015-02-08.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ItemController.h"

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate, UITableViewDataSource>

{
    // Will be used to store list of items 
    NSArray *itemArray;
}

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;


// Cannot connect to view controller?
@property (weak, nonatomic) IBOutlet UITableViewCell *purchaseTotalCell;


- (IBAction)startStopReading:(id)sender;

@end
