//
//  BentAudioController.h
//  bent.fm
//
//  Created by Mayank Sanganeria on 9/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "Singleton.h"
#import "BentViewController.h"

#define NUM_X_FILTERS 8

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
    BentCircuit *bentCircuit;
    int M;
    int N;
    Biquad antiXFilter[NUM_X_FILTERS];
    ABOutputPort *audiobusOutputPort;
} EffectState;

@interface BentAudioManager : Singleton

@property (assign) EffectState effectState;
@property (assign) BOOL running;
@property (strong, nonatomic) ABAudiobusController *audiobusController;
@property (strong, nonatomic) ABAudiobusAudioUnitWrapper *audiobusAudioUnitWrapper;

-(void)setupAudio;
-(void)start;
-(void)stop;

@end
