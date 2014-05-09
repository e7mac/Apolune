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
  __block void (^audioBlock)(AudioBufferList* ioData, UInt32 inNumberFrames, AudioTimeStamp *timestamp, AudioStreamBasicDescription asbd);
}

-(void)setupCircuit
{
  _circuitBoard = new CircuitBoard;
  _timer1 = new TimerChip;
  _timer2 = new TimerChip;
  
  _osc1 = new CounterChip;
  _osc2 = new CounterChip;
  
  _bendNand1 = new NandBinaryGate;
  _bendXor1 = new XorBinaryGate;
  _bendCounter1 = new CounterChip;
  
  
  
  _circuitBoard->addChip(_timer1);
  _circuitBoard->addChip(_timer2);
  _circuitBoard->addChip(_osc1);
  _circuitBoard->addChip(_osc2);
  _circuitBoard->addChip(_bendNand1);
  _circuitBoard->addChip(_bendCounter1);
  
  _circuitBoard->addConnection(&_timer1->output, &_osc1->input);
  _circuitBoard->addConnection(&_timer2->output, &_osc2->input);
  
  _circuitBoard->addConnection(&_osc1->output[0],         &_bendCounter1->input);
  _circuitBoard->addConnection(&_bendCounter1->output[2], &_bendNand1->input[0]);
  _circuitBoard->addConnection(&_bendCounter1->output[3], &_bendNand1->input[1]);
  _circuitBoard->addConnection(&_bendNand1->output,       &_bendXor1->input[0] );
  _circuitBoard->addConnection(&_osc2->output[0],         &_bendXor1->input[1] );
  
  _circuitBoard->updateConnections();
  
  _timer1->setFrequency(0.008);
  _timer2->setFrequency(0.045);
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
            circuit->_circuitBoard->tick(); // twice, up and down for each bit, speedy loop unrolling
            circuit->_circuitBoard->tick();
          }
//          float xorOutput = circuit->bendXor1.output.outputBit;
          float xorOutput = circuit->_bendXor1->output.outputBit;
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
  _circuitBoard->addConnection(output, input);
  _circuitBoard->updateConnections();
}


-(void)removeConnectionFromChipInput:(ChipInput *)input
{
  _circuitBoard->removeConnection(input);
  _circuitBoard->updateConnections();
}

-(void)dealloc
{
  free(_timer1);
  free(_timer2);
  
  free(_osc1);
  free(_osc2);
  
  free(_bendNand1);
  free(_bendXor1);
  free(_bendCounter1);
}

@end
