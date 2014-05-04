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
  NSArray *array=@[
                   // Oscillator 1
                   @{@"type":@"Knob",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // Oscillator 2
                   @{@"type":@"Knob",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // NAND Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // XOR Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   // Counter Chip
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:NO],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   @{@"type":@"BananaJack",
                     @"location":[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                     @"inputOrOutput":[NSNumber numberWithBool:YES],
                     },
                   
                   ];
  
}
@end
