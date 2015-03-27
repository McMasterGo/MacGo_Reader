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
    // When loads, queryItemTable method will be selected
//    [self performSelector:@selector(queryItemTable)];
    [self queryItemTable];

}

#pragma mark - Table View Methods

- (void)queryItemTable {
    
    // Query list of items from Item table]
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    
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
    PFObject *tempObject = [itemArray objectAtIndex:indexPath.row];
    
    cell.itemLabelName.text = [NSString stringWithFormat:@"%@",tempObject[@"name"]]; //[tempObject objectForKey:@"name"];
    
    
    // Convert price display to look more elegant (i.e. $0.50 vs $0.5)
    NSMutableString *stringPrice = [NSMutableString stringWithFormat:@"%@", tempObject[@"price"]];
    
    float floatPrice = stringPrice.floatValue; //[stringPrice floatValue];
    
    
    cell.itemLabelCost.text = [NSString stringWithFormat:@"$%.2f",floatPrice ];
    
    // Displays without 2 decimal places (if there is a 0)(i.e. $0.50 vs $0.5)
//    cell.itemLabelCost.text = [NSString stringWithFormat:@"$%@",tempObject[@"price"] ];
    
    // Set tag (the unique identifier) for UIButton to the same as the index path of row
    cell.buttonAdd.tag = indexPath.row;
    cell.buttonMinus.tag = indexPath.row;
    
    cell.itemCounter.tag = indexPath.row;
    
    // Initialize counter to be 0
    cell.itemCounter.text =@"0";
    
    // "Listen" to what is clicked, if so go to addMinusClick method
    [cell.buttonAdd addTarget:self action:@selector(addMinusButton:) forControlEvents: UIControlEventTouchUpInside];
    [cell.buttonMinus addTarget:self action:@selector(addMinusButton:) forControlEvents: UIControlEventTouchUpInside];

    return cell;
}

- (void)addMinusButton:(id)sender {
    
    UIButton*senderButton = (UIButton *)sender;
    
    // Get the item at whichever row is clicked
    PFObject *tempObject = [itemArray objectAtIndex:senderButton.tag];
//    NSLog(@"Object ID: %@", tempObject.objectId);
    
    ItemController *cell = [self.itemTableView dequeueReusableCellWithIdentifier:@"itemCell"];
    cell.delegate = self;
    
    NSLog(@"Row: %li, Object name: %@, cost: %@", (long)senderButton.tag, tempObject[@"name"], tempObject[@"price"]);
    
    NSString *itemVal = cell.itemCounter.text;
//
    int itemValInt = [itemVal intValue];
    
    NSLog(@"########################%i",itemValInt);
    
    
    // Determine whether add or minus button clicked
    
    // If add/minus button cell.itemCounter.text = counter

}

// Initate counter value
//int counter = 0;

- (IBAction)addItemButton:(id)sender {
    
//    counter++;
//    NSLog(@"Counter value = %i", counter);
//    itemCounter.text = [NSString stringWithFormat:@"%i", counter];
    
    // Increment cell.itemCounter.text
}


- (IBAction)minusItemButton:(id)sender {
    
//    counter--;
//    NSLog(@"Counter value = %i", counter);
//    itemCounter.text = [NSString stringWithFormat:@"%i", counter];

    
    // Decrement cell.itemCounter.text
}


// If row is selected (for displaying data now)
- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *tempObject = [itemArray objectAtIndex:indexPath.row];
    
//    NSLog(@"Object ID: %@", tempObject.objectId);
    NSLog(@"Row: %li, Object name: %@, cost: %@", (long)indexPath.row, tempObject[@"name"], tempObject[@"price"]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation

- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            [_bbitemStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code"];
//            [_tableView setHidden:YES];
            [_itemTableView setHidden: YES];

        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        [_bbitemStart setTitle:@"Start!"];
        [_lblStatus setText:@""];
//        [_tableView setHidden:NO];
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

- (void)createPurchaseWithTokenId:(NSString*)token{
    // Initiate Purchase for Token
    NSLog(@"Token ID: %@", token);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tokens"];
    [query getObjectInBackgroundWithId:token block:^(PFObject *tokenId, NSError *error) {
        
        // If no error
        if (error == nil) {
            NSLog(@"%@",tokenId);
            
            // Get the user that corresponds to their tokenId
            NSString *user = [tokenId objectForKey:@"user"];
            
            // Create Purchase
            PFObject *purchase = [PFObject objectWithClassName:@"Purchase"];
            purchase[@"user"] = user;
            
            /* Still working on how to determine total cost */
            purchase[@"totalCost"] = @"";
            [purchase saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // Display confirmation
                    NSLog(@"Purchase item with id %@ saved",[purchase objectId]);
                }
                else {
                    // Display error
                    NSLog(@"%@",error);
                }
            }];
            
        }
        else {
            NSLog(@"%@",error);
        }
        
        
        
    }];
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
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
            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];

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
    
    NSLog(@"Quantity Changed");
    
}

@end