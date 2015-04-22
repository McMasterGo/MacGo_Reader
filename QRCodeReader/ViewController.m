//  ViewController.m
//  QRCodeReader
//
//  Created by Simon Quach on 2015-02-08.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ViewController.h"
#import "ItemController.h"


@interface ViewController () <ItemControllerProtocol>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation ViewController

// Instead of this, add _ (i.e. _itemTableView) to instance
//@synthesize itemTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    //[self loadBeepSound];
    
    self.itemTableView.delegate = self;
    
    // When loads, queryItemTable method will be selected
//    [self performSelector:@selector(queryItemTable)];
    [self queryItemTable];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Methods

- (void)queryItemTable {
    
    // Query list of items from Item table]
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query orderByAscending:@"name"];
    
    // Stores items into 'objects'
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            
            // Prints out the items
            //NSLog(@"%@", objects);
            
            // Store items queried into the array
            itemArray = [[NSArray alloc] initWithArray:objects];
        }
        
        else {
            NSLog(@"%@", error);
            
        }
        
        // Populate table with itemArray
        [self.itemTableView reloadData];
//        [_itemTableView reloadData];
        
    }];
}

// get number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return number of sections
    return 1;
}

// get number of rows by counting number of items in array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemArray.count;
}

// setup cells in tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell
    static NSString *itemIdentifier = @"itemCell";
    
    // ItemController used from ItemController.h
    ItemController *cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    cell.delegate = self;
    
    // Change the colours of the rows
    if (indexPath.row % 2 == 1) {
        cell.itemLabelName.textColor = [UIColor whiteColor];
        cell.itemLabelCost.textColor = [UIColor whiteColor];
        cell.itemQuantityLabelCost.textColor = [UIColor whiteColor];
        cell.itemCounter.textColor = [UIColor whiteColor];
        
        UIImage *plusIconW = [UIImage imageNamed:@"Plus Icon-w"];
        UIImage *minusIconW = [UIImage imageNamed:@"Minus Icon-w"];

        [cell.buttonAdd setImage:plusIconW forState:UIControlStateNormal];
        [cell.buttonMinus setImage:minusIconW forState:UIControlStateNormal];

        cell.buttonAdd.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.buttonMinus.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else {
//        cell.itemQuantityLabelCost.textColor = [UIColor whiteColor];
        
    }
    
    // Display each item in table cells
    PFObject *tempObject = [itemArray objectAtIndex:indexPath.row];

    // Add object to nil object when table is off screen
//    NSMutableArray *newArrayOfStrings = [NSMutableArray array];
//    
//    for (int i=0; i<itemArray.count; i++) {
//        PFObject *newTempObj = itemArray[i];
//        [newArrayOfStrings addObject:newTempObj];
//    }
//    if ([itemArray containsObject:[NSNull null]]) {
//        NSLog(@"nil in minus");
//    }
    
    // Set item names
    cell.itemLabelName.text = [NSString stringWithFormat:@"%@",tempObject[@"name"]]; //[tempObject objectForKey:@"name"];
    
    // Convert price display to look more elegant (i.e. $0.50 vs $0.5)
    NSString *stringPrice = [NSString stringWithFormat:@"%@", tempObject[@"price"]];
    
    float floatPrice = stringPrice.floatValue; //[stringPrice floatValue];
    
    // Set item cost
    cell.itemLabelCost.text = [NSString stringWithFormat:@"$%.2f",floatPrice ];
    
    // Displays without 2 decimal places (if there is a 0)(i.e. $0.50 vs $0.5)
//    cell.itemLabelCost.text = [NSString stringWithFormat:@"$%@",tempObject[@"price"] ];
    
    // Set tag (the unique identifier) for UIButton to the same as the index path of row
    cell.buttonAdd.tag = indexPath.row;
    cell.buttonMinus.tag = indexPath.row;
    
    cell.itemCounter.tag = indexPath.row;
    
    // "Listen" to what is clicked, if so go to addMinusClick method
    [cell.buttonAdd addTarget:self action:@selector(addPlusButton:) forControlEvents: UIControlEventTouchUpInside];
    [cell.buttonMinus addTarget:self action:@selector(addMinusButton:) forControlEvents: UIControlEventTouchUpInside];

    return cell;
}

- (void)addMinusButton:(id)sender {
    
    UIButton *senderButton = (UIButton *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForItem:senderButton.tag inSection:0];
    ItemController *cell = (ItemController *)[self.itemTableView cellForRowAtIndexPath:path];
    
    // Decrement itemCounter, item count can not be less than 0
    if (cell.itemCount > 0) {
        cell.itemCount -= 1;
    }
    else {
        cell.itemCount = 0;
    }
    cell.itemCounter.text = [NSString stringWithFormat:@"%lu", (long)cell.itemCount];
    
//    PFObject *tempObject = [itemArray objectAtIndex:senderButton.tag];

//    NSString *itemName = tempObject[@"name"];
//    float floatPrice = [tempObject[@"price"]floatValue] * cell.itemCount;
//    NSLog(@"Cost of %i %@ is %.2f",cell.itemCount, itemName, floatPrice);

//    NSString *itemName = cell.itemLabelName.text;
    
    NSString *itemCostString = cell.itemLabelCost.text;
    
    // Removes the $ from the string
    NSString *itemCostStringNew = [itemCostString substringFromIndex:1];
    float floatPrice = [itemCostStringNew floatValue] * cell.itemCount;
    float newFloatPrice = [[NSString stringWithFormat:@"%.2f",floatPrice] floatValue];
    
    cell.itemQuantityLabelCost.text = [NSString stringWithFormat:@"$%.2f", newFloatPrice];

    float totalCost = [self purchaseTotalCost];
    
    NSLog(@"Total cost of all items: %.2f", totalCost);
    
}

- (void)addPlusButton:(id)sender {
    
    UIButton *senderButton = (UIButton *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForItem:senderButton.tag inSection:0];
    ItemController *cell = (ItemController *)[self.itemTableView cellForRowAtIndexPath:path];
    
    // Increment itemCounter
    cell.itemCount += 1;
    cell.itemCounter.text = [NSString stringWithFormat:@"%lu", (long)cell.itemCount];
    
    NSString *itemCostString = cell.itemLabelCost.text;
    
    // Removes the $ from the string
    NSString *itemCostStringNew = [itemCostString substringFromIndex:1];
    float floatPrice = [itemCostStringNew floatValue] * cell.itemCount;
    float newFloatPrice = [[NSString stringWithFormat:@"%.2f",floatPrice] floatValue];

    cell.itemQuantityLabelCost.text = [NSString stringWithFormat:@"$%.2f", newFloatPrice];
    
    float totalCost = [self purchaseTotalCost];
    
    NSLog(@"Total cost of all items: %.2f", totalCost);

}

- (float)purchaseTotalCost {
    
    // Loop through each cell in itemTableView
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [_itemTableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [_itemTableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[_itemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    
    double sumOfAllItems=0;
    
    for (ItemController *cell in cells) {
        int itemQuantity = cell.itemCount;
        
        NSString *itemCostString = cell.itemLabelCost.text;
        
        // Removes the $ from the string
        NSString *itemCostStringNew = [itemCostString substringFromIndex:1];
        float itemCost = [itemCostStringNew floatValue] * itemQuantity;
        float newItemCost = [[NSString stringWithFormat:@"%.2f",itemCost] floatValue];
        sumOfAllItems += newItemCost;
        
        // Change the purchase total label to the cost of each item added up
        _purchaseTotalLabel.text = [NSString stringWithFormat:@"$%.2f",sumOfAllItems];
        
    }
    
    return sumOfAllItems;

}
// If row is selected (for displaying data now)
- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *tempObject = [itemArray objectAtIndex:indexPath.row];
    
    NSLog(@"Object ID: %@", tempObject.objectId);
    NSLog(@"Row: %li, Object name: %@, cost: %@", (long)indexPath.row, tempObject[@"name"], tempObject[@"price"]);

}

#pragma mark - Create Purchase and Purchase Items Methods

- (void)createPurchaseWithTokenId:(NSString*)token{
    
    // Initiate Purchase for Token
    PFQuery *query = [PFQuery queryWithClassName:@"Tokens"];
    [query getObjectInBackgroundWithId:token block:^(PFObject *tokenId, NSError *error) {
        
        // If no error
        if (error == nil) {
            // Get the user that corresponds to their tokenId
            PFObject *userPointerObject = [tokenId objectForKey:@"user"];
            NSString *userId = userPointerObject.objectId;
            
            BOOL isTokenActive = [[tokenId objectForKey:@"active"] boolValue];

            if (isTokenActive == false) {
                
                // Alert box indicating that token has expired
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token Error" message:@"The QR Code that you are attempting to use has expired.\n Please generate a new code from the MacGo application." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alert show];
                // Tableview may be hidden at this point, uncomment in live app
                // [_itemTableView setHidden: NO];
                // [self stopReading];

                
            } else {
                // Token is true
                
                // Get info of user
                PFQuery *query = [PFUser query];
                
                [query whereKey:@"objectId" equalTo:userId];
                
                [query getObjectInBackgroundWithId:userId block:^(PFObject *userInfo, NSError *error) {
                    
                    // If no error
                    if (error ==nil) {
                        
                        NSNumber *userBalanceNumber = userInfo[@"balance"];
                        
                        float userBalance = [userBalanceNumber floatValue];
                        
                        float totalCostFloat =[self purchaseTotalCost];
                        
                        // Get the cost to 2 decimal places
                        float newTotalCostFloat = [[NSString stringWithFormat:@"%.2f", totalCostFloat]floatValue];
                        
                        NSNumber *totalCost = [NSNumber numberWithFloat:newTotalCostFloat];
                        
                        if (userBalance < newTotalCostFloat) {
                            NSLog(@"User balance of %.2f is less than total price of %.2f", userBalance, newTotalCostFloat);
                            
                            NSString *balanceErrorMessage = [NSString stringWithFormat: @"Insufficient Balance The user balance of %.2f does not meet the total required amount of %.2f", userBalance,newTotalCostFloat];
                            
                            // Alert box indicating that the balance does not meet the purchase amount
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insufficient Balance" message:balanceErrorMessage delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                            [alert show];
                            
                            // Tableview may be hidden at this point, uncomment in live app
                            // [_itemTableView setHidden: NO];
                            // [self stopReading];
                            
                        } else {
                            NSLog(@"User balance of %.2f is greater than total price of %.2f", userBalance, newTotalCostFloat);
                            
                            // Create Purchase
                            PFObject *purchase = [PFObject objectWithClassName:@"Purchase"];
                            
                            purchase[@"user"] = userPointerObject;
                            purchase[@"totalCost"] = totalCost;
                            
                            [purchase saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    // Display confirmation
                                    NSLog(@"Purchase item with id %@ saved",[purchase objectId]);
                                    
                                    
                                    // Change the token to be false after using it, so it can not be used again within the duration
                                    [tokenId setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
                                    [tokenId saveInBackground];
                                    
                                    // purchase if of type PFObject
                                    [self createPurchaseItemWithPurchaseId:purchase];
                                    
                                    // Calculate the new balance after transaction
                                    float newBalance = userBalance - newTotalCostFloat;
                                    NSNumber *newBalanceNumber = [NSNumber numberWithFloat:newBalance];
                                    
                                    NSString *successMessage = [NSString stringWithFormat:@"Your purchase has been successful, your remaining balance is %.2f", newBalance];
                                    
                                    // To change user data that is not logged in, require cloud code
//                                    [PFCloud callFunction:@"editUser" withParameters:@{ @"userId": userId, @"balance": newBalanceNumber
//                                    }];
                                    
                                    [PFCloud callFunctionInBackground:@"editUser" withParameters:@{ @"userId": userId, @"balance":newBalanceNumber} block:^(id object, NSError *error) {
                                        
                                        if (error == nil) {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Successful" message:successMessage delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                                            [alert show];
                                            [self resetItemValues];
                                            
                                            // Tableview may be hidden at this point, uncomment in live app
                                            [self stopReading];
                                            [_itemTableView setHidden: NO];

                                        }
                                        else {
                                            NSLog(@"PFCloud Error: %@", error);
                                        }
                                        
                                    }];
                                    
                                }
                                else {
                                    // Display error
                                    NSLog(@"%@",error);
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                                    [alert show];
                                    
                                    // Tableview may be hidden at this point, uncomment in live app
                                    // [_itemTableView setHidden: NO];
                                    // [self stopReading];
                                    
                                    
                                }
                            }];
                            
                        }
                        
                    } else {
                        NSLog(@"Error: %@",error);
                        // Display Error
                        NSLog(@"%@",error);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                        [alert show];
                        
                        // Tableview may be hidden at this point, uncomment in live app
                        // [_itemTableView setHidden: NO];
                        // [self stopReading];
                        
                    }
                    
                }];
                
            }
            
        } else {
            NSLog(@"%@",error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token Error" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
            
            // Tableview may be hidden at this point, uncomment in live app
            // [_itemTableView setHidden: NO];
            // [self stopReading];
        }
        
    }];
    
}

- (void)createPurchaseItemWithPurchaseId:(PFObject *)purchaseId {
//    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    
    // Loop through each cell in itemTableView
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [_itemTableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [_itemTableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[_itemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    
    for (ItemController *cell in cells) {
        
        // Get the count of each item
        int intItemQuantity = cell.itemCount;
        NSNumber *itemQuantity = [NSNumber numberWithInt:intItemQuantity];
        
        // Get the item object of each row
        PFObject *itemObject = [itemArray objectAtIndex:cell.itemCounter.tag];

        // If the quantity was at least 1
        if (intItemQuantity > 0) {
            
            // Initiate creation of purchaseItem
            PFObject *purchaseItem = [PFObject objectWithClassName:@"PurchaseItem"];
            purchaseItem[@"item"] = itemObject;
            purchaseItem[@"purchase"] = purchaseId;
            purchaseItem[@"quantity"] = itemQuantity;
            [purchaseItem saveInBackground];
            
        }
        
    }
    
}

- (void)resetItemValues {
    
    // Loop through each cell in itemTableView
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [_itemTableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [_itemTableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[_itemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    
    for (ItemController *cell in cells) {
        
        cell.itemCount = 0;
        cell.itemCounter.text = @"0";
        cell.itemQuantityLabelCost.text = @"$0.00";
    
    }
    _purchaseTotalLabel.text = @"$0.00";
}

#pragma mark - IBAction method implementation

- (IBAction)startStopReading:(id)sender {
    // Test to see if works with hardcoded string
//    [self createPurchaseWithTokenId:@"YBkI9Fatth"];
    
//    UIImage *cancelButton = [UIImage imageNamed:@"Cancel"];
//    UIImage *purchaseButton = [UIImage imageNamed:@"Purchase"];
    
//    [_buttonPurchase setImage:cancelButton];
//    _buttonPurchase.imageView.contentMode = UIViewContentModeScaleAspectFit


    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        
        float totalCostFloat =[self purchaseTotalCost];
        
        // Can only begin reading if there is at least 1 item selected
        if (totalCostFloat > 0) {
            
            if ([self startReading]) {
                
                // If the startReading methods returns YES and the capture session is successfully
                // running, then change the start button title and the status message.
                [_bbitemStart setTitle:@"Cancel Transaction"];
//                [_buttonPurchase setImage:cancelButton];
                [_lblStatus setText:@"Scanning for QR Code"];
                [_itemTableView setHidden:YES];
                
            } else {
                
                // Camera does not work
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera" message:@"Your camera may not be working" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alert show];
                // Set flag back to not reading because if user cancels transaction, _isReading is still set to being read
                _isReading = !_isReading;
                
            }
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Items Selected" message:@"You need to choose at least one item to make a purchase" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
            
            // Set flag back to not reading because if user cancels transaction, _isReading is still set to being read
            _isReading = !_isReading;

        }

    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        [_bbitemStart setTitle:@"Make Purchase!"];
//        [_buttonPurchase setImage:purchaseButton];
        [_lblStatus setText:@""];
        [_itemTableView setHidden: NO];

    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
    
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"Not working %@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}


-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];

    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
//    UIImage *cancelButton = [UIImage imageNamed:@"Cancel"];
//    UIImage *purchaseButton = [UIImage imageNamed:@"Purchase"];
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            
            NSString *tokenId = [metadataObj stringValue];
            [self createPurchaseWithTokenId:tokenId];
            
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:tokenId waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Make Purchase" waitUntilDone:NO];
//            [_buttonPurchase setImage:purchaseButton];

            _isReading = NO;
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
    
}

#pragma mark - ItemControllerProtocol
- (void)quantityDidChange:(NSInteger)quantity{

//    NSLog(@"Quantity Changed");

}

@end