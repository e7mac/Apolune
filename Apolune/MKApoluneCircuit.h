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

-(myAudioBlock)processBlock;

@end
