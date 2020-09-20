//
//  BarcodeReader.m
//  QRCodeReader
//


#import "BarcodeReader.h"

@implementation BarcodeReader

+(id)init
{
    
    static BarcodeReader *reader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reader = [[self alloc] init];
    });
    return reader;
 
}

-(oneway void) release
{
}

-(void)startCamera:(CallBack*)callBack
{
  self.callbackObj = callBack;
  
  [self presentView];
}

-(void) presentView
{
  BarcodeScannerVC * controller = [[BarcodeScannerVC alloc] initWithNibName:@"BarcodeScannerVC" bundle:[NSBundle mainBundle]];
  controller.scanDelegate = self;
  
  //[self presentViewController:controller animated:YES completion:nil];
  UIWindow * currentwindow = [[UIApplication sharedApplication] keyWindow];
  [currentwindow.rootViewController presentViewController:controller animated:NO completion:nil];
}

-(void) scanResult:(NSString*) scanData
{
  NSArray * result = [[NSArray alloc] initWithObjects:scanData, nil];
  executeClosure(self.callbackObj, result, NO);
}

@end
