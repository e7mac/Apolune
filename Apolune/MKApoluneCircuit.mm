//
//  MKApoluneCircuit.m
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKApoluneCircuit.h"

#define MAX_SINT32 32767
#define SRATE 8000
#define NBITS 10

short Chip::nbits = NBITS;
int Chip::srate = SRATE;
short Register::nbits = NBITS;

@implementation MKApoluneCircuit {
  CircuitBoard circuitBoard;
  
  TimerChip timer1;
  TimerChip timer2;
  
  CounterChip osc1;
  CounterChip osc2;

  NandBinaryGate bendNand1;
  XorBinaryGate  bendXor1;
  CounterChip    bendCounter1;
  
  __block void (^audioBlock)(AudioBufferList* ioData, UInt32 inNumberFrames, AudioTimeStamp *timestamp, AudioStreamBasicDescription asbd);
}

-(void)setupCircuit
{
  circuitBoard.addChip(&timer1);
  circuitBoard.addChip(&timer2);
  circuitBoard.addChip(&osc1);
  circuitBoard.addChip(&osc2);
  circuitBoard.addChip(&bendNand1);
  circuitBoard.addChip(&bendCounter1);
  
  circuitBoard.addConnection(&timer1.output, &osc1.input);
  circuitBoard.addConnection(&timer2.output, &osc2.input);
  
  circuitBoard.addConnection(&osc1.output[0],         &bendCounter1.input);
  circuitBoard.addConnection(&bendCounter1.output[2], &bendNand1.input[0]);
  circuitBoard.addConnection(&bendCounter1.output[3], &bendNand1.input[1]);
  circuitBoard.addConnection(&bendNand1.output,       &bendXor1.input[0] );
  circuitBoard.addConnection(&osc2.output[0],         &bendXor1.input[1] );
  
  circuitBoard.updateConnections();
  
  timer1.setFrequency(0.008);
  timer2.setFrequency(0.045);
}


-(myAudioBlock)processBlock
{
  __weak typeof(self) weakSelf = self;
  audioBlock = ^(AudioBufferList *ioData, UInt32 inNumberFrames, AudioTimeStamp *timestamp, AudioStreamBasicDescription asbd) {
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
//          static float sampleFloat[2];
//          sampleFloat[currentChannel] = (float)sample / MAX_SINT32; // convert to float for DSP
          
          for (int jIndex=0; jIndex < Chip::nbits; jIndex++) {
            circuit->circuitBoard.tick(); // twice, up and down for each bit, speedy loop unrolling
            circuit->circuitBoard.tick();
          }
//          float xorOutput = circuit->bendXor1.output.outputBit;
          float xorOutput = circuit->bendXor1.output.outputBit;
//          NSLog(@"%f", xorOutput);
          
          // get int back
          sample = ((xorOutput*2.0)-1) * MAX_SINT32;
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

-(void)makeConnectionFromChipOutput:(ChipOutput *)output toChipInput:(ChipInput *)input
{
  circuitBoard.addConnection(output, input);
  circuitBoard.updateConnections();
}


-(void)removeConnectionFromChipInput:(ChipInput *)input
{
  circuitBoard.removeConnection(input);
  circuitBoard.updateConnections();
}

@end
