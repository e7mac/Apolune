//
//  MKApoluneCircuit.h
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MKChipKit/ChipLibraryInclude.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void (^myAudioBlock)(AudioBufferList* ioData, UInt32 inNumberFrames, AudioTimeStamp *timestamp, AudioStreamBasicDescription asbd);

@interface MKApoluneCircuit : NSObject


@property (nonatomic, assign) CircuitBoard *circuitBoard;

@property (nonatomic, assign) TimerChip *timer1;
@property (nonatomic, assign) TimerChip *timer2;

@property (nonatomic, assign) CounterChip *osc1;
@property (nonatomic, assign) CounterChip *osc2;

@property (nonatomic, assign) NandBinaryGate *bendNand1;
@property (nonatomic, assign) XorBinaryGate  *bendXor1;
@property (nonatomic, assign) CounterChip    *bendCounter1;

-(void)setupCircuit;
-(myAudioBlock)processBlock;

-(void)makeConnectionFromChipOutput:(ChipOutput *)output toChipInput:(ChipInput *)input;
-(void)removeConnectionFromChipInput:(ChipInput *)input;

@end
