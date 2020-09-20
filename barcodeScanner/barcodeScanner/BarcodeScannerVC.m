//
//  BarcodeScannerVC.m
//  QRCodeReader
//


#import "BarcodeScannerVC.h"

@interface BarcodeScannerVC ()
{
    NSTimer *oneMinuteTimer;
}
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading;
-(void)stopReading;

@end

@implementation BarcodeScannerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    //Start reading for barcode.
    [self startReading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)startReading {
    oneMinuteTimer =[NSTimer scheduledTimerWithTimeInterval: 59.0 target: self
    selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: NO];
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
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
    //[captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
   
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}

-(void) callAfterSixtySecond:(NSTimer*) t
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Running Time Loop" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            //button click event
                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
//    if ([oneMinuteTimer isValid]) {
//        [oneMinuteTimer invalidate];
//    }
//    oneMinuteTimer = nil;
    [self stopReading];
    [self sendResult:@"Timeout"];
    NSLog(@"red");
}

- (void)viewWillLayoutSubviews {
    if(_videoPreviewLayer) {
        _videoPreviewLayer.frame = self.view.bounds;
        if (_videoPreviewLayer.connection.supportsVideoOrientation) {
            _videoPreviewLayer.connection.videoOrientation = [self interfaceOrientationToVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
    }
}

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    return AVCaptureVideoOrientationPortrait;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
  //Binso  [_captureSession release], _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
  //Binso  [_videoPreviewLayer release], _videoPreviewLayer = nil;
    if ([oneMinuteTimer isValid]) {
        NSLog(@"IS Valid");
        [oneMinuteTimer invalidate];
    }
    oneMinuteTimer = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancelReading:(id)sender
{
    [self stopReading];
    [self sendResult:@"(Cancelled)"];
}

-(void) sendResult:(NSString*) result
{
    [_scanDelegate scanResult:result];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:detectionString preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        //button click event
                                    }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                 });
                break;
            }
        }
        
        if (detectionString != nil)
        {
            // Everything is done on the main thread.
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(sendResult:) withObject:detectionString waitUntilDone:YES];
            break;
        }
    }
}



@end
