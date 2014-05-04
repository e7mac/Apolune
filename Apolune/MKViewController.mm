//
//  MKViewController.m
//  Apolune
//
//  Created by Mayank on 5/3/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKViewController.h"
#import<MKAudioKit/AudioController.h>
#import "MKApoluneCircuit.h"
#import "MKHardwareControlSurfaceView.h"

@interface MKViewController () <MKHardwareControlSurfaceViewDelegate>

@property (weak, nonatomic) IBOutlet MKHardwareControlSurfaceView *HardwareComponentView;
@property (nonatomic, strong) AudioController *audioController;
@property (nonatomic, strong) MKApoluneCircuit *apoluneCircuit;

@end

@implementation MKViewController

- (MKApoluneCircuit *)apoluneCircuit
{
  if (_apoluneCircuit == nil)
  {
    _apoluneCircuit = [[MKApoluneCircuit alloc] init];
  }
  return _apoluneCircuit;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.HardwareComponentView.delegate = self;
  
  self.audioController = [AudioController sharedInstance];
  [self.audioController setupAudioSessionRequestingSampleRate:8000];
  [self.apoluneCircuit setupCircuit];
  [self.audioController setupProcessBlockWithAudioCallback:self.apoluneCircuit.processBlock];
  [self.audioController setupDone];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)connectionMadeFrom:(int)a to:(int)b
{
}

-(void)connectionRemovedFrom:(int)a to:(int)b
{
}

-(void)createBlueprint
{
    int numRows = 5;
  NSArray *array=@[
                   // Oscillator 1
                   @{@"type":@"Knob",
                     @"location":[NSValue valueWithCGRect: CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows)],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // Oscillator 2
                   @{@"type":@"Knob",
                     @"location":[NSValue valueWithCGRect: CGRectMake(0, self.view.bounds.size.height/numRows, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows)],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/numRows, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // NAND Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(0, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*2/3, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // XOR Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(0, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*2/3, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // Counter Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*0/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*1/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*2/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*3/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*4/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*5/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*6/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*7/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGRect: CGRectMake(self.view.bounds.size.width*8/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },   
                   ];
  
}
@end
