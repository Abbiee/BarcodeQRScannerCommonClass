//
//  BarcodeScannerVC.h
//  QRCodeReader
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BarcodeScannerDelegate
-(void) scanResult:(NSString*) scanData;
@end

@interface BarcodeScannerVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (assign, nonatomic) IBOutlet UIView *viewPreview;
@property (assign, nonatomic) id<BarcodeScannerDelegate> scanDelegate;
- (IBAction)cancelReading:(id)sender;

@end
