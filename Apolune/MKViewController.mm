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

@interface MKViewController ()

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
  self.audioController = [AudioController sharedInstance];
  [self.audioController setupAudioSessionRequestingSampleRate:44100];
  [self.audioController setupProcessBlockWithAudioCallback:self.apoluneCircuit.processBlock];
  [self.audioController setupDone];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
