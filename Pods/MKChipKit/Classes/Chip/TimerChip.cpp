//
//  TimerChip.cpp
//  CircuitModel
//
//  Created by Mayank on 9/6/12.
//  Copyright (c) 2012 Mayank, Kurt. All rights reserved.
//

#include "TimerChip.h"

TimerChip::TimerChip()
{
    output.setChip(this);
    mAccumulate = 0.0;
    mPhaseIncrement = 0.5; // nyquist by default
}

void TimerChip::tickInput()
{
//    mState = !mState;
    
    // something like this
    mAccumulate += mPhaseIncrement; // increment
    if (mAccumulate >= 1.0){ // overflow
        mAccumulate -= 1.0;
        mState = 1; // 1 on overflow
    } else {
        mState = 0; // 0 otherwide
    }
}

void TimerChip::tickOutput()
{
    output.setOutputBit(mState);
}

// normalized freq... as in, never put above 1/2 (nyquist)
void TimerChip::setFrequency(float withFreq)
{
    mPhaseIncrement = withFreq;
}