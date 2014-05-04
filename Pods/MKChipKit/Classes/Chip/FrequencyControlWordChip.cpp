//
//  FrequencyControlWordChip.cpp
//  CircuitModel
//
//  Created by Mayank on 9/7/12.
//  Copyright (c) 2012 Mayank, Kurt. All rights reserved.
//

#include "FrequencyControlWordChip.h"
#include <math.h>

FrequencyControlWordChip::FrequencyControlWordChip()
{
    clockInputRegister.setChip(this);
    resetInputRegister.setChip(this);
    output.setChip(this);
    deviationInput.setChip(this);

    // TODO: put theDenominator back in!!!
//    theDenominator = 1/log2f(srate/2)*((1<<nbits)-1); // RESET THIS WITH NEW NBITS
}


void FrequencyControlWordChip::setBeta(float withBeta)
{
    mBeta = withBeta;
}

void FrequencyControlWordChip::setDeviation(float withDeviation)
{
    mDeviation = withDeviation;
}


void FrequencyControlWordChip::setCenterFrequency(float withFrequency)
{
    mCenterFrequency = withFrequency;
}

void FrequencyControlWordChip::tickInput()
{
    clockInputRegister.refreshInput();
    if (clockInputRegister.getRisingEdge())
        clockInput();
    resetInputRegister.refreshInput();
    if (resetInputRegister.getRisingEdge())
        resetInput();
}

void FrequencyControlWordChip::tickOutput()
{
    if (clockInputRegister.getRisingEdge())
        clockOutput();
    if (resetInputRegister.getRisingEdge())
        resetOutput();
}

void FrequencyControlWordChip::clockInput()
{
    if (deviationInput.isConnected()){
        deviationInput.refreshInput();
    }
}

void FrequencyControlWordChip::clockOutput()
{
    output.outputRegister.leftCircularShift(1);
}

void FrequencyControlWordChip::resetInput()
{
    if (deviationInput.isConnected())
    {
        mDeviation = deviationInput.inputRegister.getValue();
        mDeviationFloat =  (float)mDeviation / ((1<<nbits)-1); // TODO possible precompute denom
        mDeviationFloat = mDeviationFloat*2-1;
    }
    
    mDeltaFrequency = mCenterFrequency * mBeta;
    mDeviationAmountFloat = mDeviationFloat*mDeltaFrequency;
    mFrequency = mCenterFrequency + mDeviationAmountFloat;
    
    // TODO: efficiency, precompute denominator? and mDeviationAmountFLoat/minFreq
//    mControlWord = log2f((mCenterFrequency+mDeviationAmountFloat/1.0))*theDenominator;
    
    // TODO: add theDenominator back in!!! this must be killing efficiency
    mControlWord = log2f((mCenterFrequency+mDeviationAmountFloat/1.0))*(1/log2f(srate/2)*((1<<nbits)-1));
    
    //log2f(srate/0.002) = 24.39428
}

void FrequencyControlWordChip::resetOutput()
{
    output.outputRegister.setValue(mControlWord);
}
