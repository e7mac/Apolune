//
//  MKApoluneCircuit.m
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKApoluneCircuit.h"

#define MAX_SINT32 32767

@implementation MKApoluneCircuit {
  CircuitBoard *circuitBoard;
}


-(myAudioBlock)processBlock
{
  __weak typeof(self) weakSelf = self;
  myAudioBlock audioBlock = ^(AudioBufferList *ioData, UInt32 inNumberFrames, AudioTimeStamp *timestamp, AudioStreamBasicDescription asbd) {
    AudioSampleType sample = 0;
    UInt32 bytesPerChannel = asbd.mBytesPerFrame/asbd.mChannelsPerFrame;
    MKApoluneCircuit *circuit;
    circuit = weakSelf;
    
    for (int bufCount=0; bufCount<ioData->mNumberBuffers; bufCount++) {
      AudioBuffer buf = ioData->mBuffers[bufCount];
      int currentFrame = 0;
      while ( currentFrame < inNumberFrames ) {
        // copy sample to buffer, across all channels
        for (int currentChannel=0; currentChannel<buf.mNumberChannels; currentChannel++) {
          memcpy(&sample,(char *)buf.mData + (currentFrame * asbd.mBytesPerFrame) +
                 (currentChannel * bytesPerChannel),
                 sizeof(AudioSampleType));
          //sample access here
          static float sampleFloat[2];
          sampleFloat[currentChannel] = (float)sample / MAX_SINT32; // convert to float for DSP
          
          
          
          static float drySampleFloat;
          drySampleFloat = sampleFloat[currentChannel];
          
          // get int back
          sample = 0.5 * (sampleFloat[0]+sampleFloat[1]) * MAX_SINT32;
          //copy sample back
          memcpy((char *)buf.mData + (currentFrame * asbd.mBytesPerFrame) +
                 (currentChannel * bytesPerChannel),
                 &sample,
                 sizeof(AudioSampleType));
        }
        currentFrame++;
      }
    }
  };
  return audioBlock;
}

@end
