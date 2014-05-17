//
//  BentAudioController.m
//  bent.fm
//
//  Created by Mayank Sanganeria on 9/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "BentAudioManager.h"

#define BUFFER_DURATION 0.025
#define SOFTWARE_SAMPLE_RATE 8000
#define SRATE 44100
#define MAX_SINT32 32767

@class BentAudioController;

static void CheckError(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	
	char str[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
	fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
	exit(1);
}


#pragma mark callbacks
static void MyInterruptionListener (void *inUserData,
                                    UInt32 inInterruptionState) {
	
	printf ("Interrupted! inInterruptionState=%ld\n", inInterruptionState);
	BentAudioManager *audioManager = (__bridge BentAudioManager*)inUserData;
	switch (inInterruptionState) {
		case kAudioSessionBeginInterruption:
            break;
		case kAudioSessionEndInterruption:
			CheckError(AudioSessionSetActive(true),
					   "Couldn't set audio session active");
			CheckError (AudioOutputUnitStart (audioManager.effectState.rioUnit),
						"Couldn't start RIO unit");
            break;
		default:
			break;
	};
}

static void audioRouteChangeListenerCallback (
                                              void                   *inUserData,                                 // 1
                                              AudioSessionPropertyID inPropertyID,                                // 2
                                              UInt32                 inPropertyValueSize,                         // 3
                                              const void             *inPropertyValue                             // 4
) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return; // 5
    
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;        // 8
    CFNumberRef routeChangeReasonRef =
    (CFNumberRef) CFDictionaryGetValue (
                                        routeChangeDictionary,
                                        CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                                        );
    
    SInt32 routeChangeReason;
    CFNumberGetValue (
                      routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason
                      );
    
    //headphones taken out
    if (routeChangeReason ==
        kAudioSessionRouteChangeReason_OldDeviceUnavailable) {  // 9
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  // 1
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,                         // 2
                                 sizeof (audioRouteOverride),                                      // 3
                                 &audioRouteOverride                                               // 4
                                 );
        
    }
    //headphones plugged
    if (routeChangeReason ==
        kAudioSessionRouteChangeReason_NewDeviceAvailable) {  // 9
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;  // 1
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,                         // 2
                                 sizeof (audioRouteOverride),                                      // 3
                                 &audioRouteOverride                                               // 4
                                 );
        
    }
    
}

static OSStatus AudioCallback (
                               void *							inRefCon,
                               AudioUnitRenderActionFlags *	ioActionFlags,
                               const AudioTimeStamp *			inTimeStamp,
                               UInt32							inBusNumber,
                               UInt32							inNumberFrames,
                               AudioBufferList *				ioData) {
	EffectState *effectState = (EffectState*) inRefCon;
    
    //    NSLog(@"collaback girl");
	// walk the samples
	AudioSampleType sample = 0;
	UInt32 bytesPerChannel = effectState->asbd.mBytesPerFrame/effectState->asbd.mChannelsPerFrame;
    
    
    
    for (int bufCount=0; bufCount<ioData->mNumberBuffers; bufCount++) {
        AudioBuffer buf = ioData->mBuffers[bufCount];
		int currentFrame = 0;
		while ( currentFrame < inNumberFrames ) {
			// copy sample to buffer, across all channels
			for (int currentChannel=0; currentChannel<buf.mNumberChannels; currentChannel++) {
				memcpy(&sample,(char *)buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame) +
                       (currentChannel * bytesPerChannel),
					   sizeof(AudioSampleType));
                static float sampleFloat[2];
                sampleFloat[currentChannel] = (float)sample / MAX_SINT32; // convert to float for DSP
                if (currentChannel == 0) {
                    static int theCount = 0;
                    static float calculatedSample;
                    
                    for(int n=0; n<effectState->N;n++) { // decimate
                        theCount++;
                        if(!(theCount%effectState->M)) { // interleave zeros
                            calculatedSample = [effectState->bentCircuit tickPerSample];
                        } else {
                            calculatedSample = 0;
                        }
                        for(int i=0; i<NUM_X_FILTERS; i++) {
                            effectState->antiXFilter[i].process(calculatedSample, calculatedSample);
                        }
                    }
                    sampleFloat[currentChannel] = calculatedSample;
                }
                // get int back
                sample = sampleFloat[0] * MAX_SINT32;
                
                //copy sample back
				memcpy((char *)buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame) +
                       (currentChannel * bytesPerChannel),
					   &sample,
					   sizeof(AudioSampleType));
			}
			currentFrame++;
		}
	}
	return noErr;
}


@interface BentAudioManager()
{
    Float64 _softwareSampleRate;
    Float64 _actualSampleRate;
    AUGraph _processingGraph;
}
@end

@implementation BentAudioManager


-(id)init
{
    self = [super init];
    if (self) {
        _effectState.bentCircuit = [[BentCircuit alloc] init];
        _running = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionsChanged:) name:ABConnectionsChangedNotification object:nil];
    }
    return self;
}


-(void)setupAudio
{
    [self setupAudioSession];
    [self setupFilters];
    [self setupAudio_processingGraph];
    [self setupAudiobus];
    [self.effectState.bentCircuit setSampleRate:_softwareSampleRate];
}


-(void)setupAudioSession
{
    CheckError(AudioSessionInitialize(NULL,
                                      kCFRunLoopDefaultMode,
                                      MyInterruptionListener,
                                      (__bridge void *)(self)),
               "couldn't initialize audio session");
    
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    CheckError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                       sizeof(category),
                                       &category),
               "Couldn't set category on audio session");
    
    // route audio to bottom speaker for iphone
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
    {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride
                                 );
        AudioSessionPropertyID routeChangeID =
        kAudioSessionProperty_AudioRouteChange;
        AudioSessionAddPropertyListener (
                                         routeChangeID,
                                         audioRouteChangeListenerCallback,
                                         nil
                                         );
    }
    
    Float32 preferredBufferDuration = BUFFER_DURATION;
    CheckError(AudioSessionSetProperty (                                     // 2
                                        kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                                        sizeof (preferredBufferDuration),
                                        &preferredBufferDuration
                                        ),
               "couldn't set buffer duration");
    
    
    _softwareSampleRate = SOFTWARE_SAMPLE_RATE;
    // INCREASE SAMPLING RATE FOR IPHONE 5
    //    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    //    if (screenRect.size.height > 480)
    //    {
    //        _softwareSampleRate *= 2;
    //    }
    Float64 requestedSampleRate = SRATE;
    UInt32 propSize = sizeof (requestedSampleRate);
    CheckError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate,
                                       propSize,
                                       &requestedSampleRate),
               "Couldn't set hardwareSampleRate");
    // inspect the hardware sample rate
    propSize = sizeof (_actualSampleRate);
    CheckError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
                                       &propSize,
                                       &_actualSampleRate),
               "Couldn't get hardwareSampleRate");
    propSize = sizeof (preferredBufferDuration);
    CheckError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration,
                                       &propSize,
                                       &preferredBufferDuration),
               "Couldn't get buffer duration");

    NSLog (@"buffer duration = %f", preferredBufferDuration);
    NSLog (@"actual sample rate = %f", _actualSampleRate);
    NSLog (@"requested sample rate = %f", _softwareSampleRate);
}



-(void)setupAudio_processingGraph
{
    NSLog (@"Configuring and then initializing audio processing graph");
    
    CheckError(NewAUGraph(&_processingGraph),"NewAUGraph");
    
    // I/O unit
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType          = kAudioUnitType_Output;
    ioUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    
    // Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
    AUNode   ioNode;         // node for I/O unit
    // Add the nodes to the audio processing graph
    CheckError(AUGraphAddNode ( _processingGraph,
                               &ioUnitDescription,
                               &ioNode),"AUGraphNewNode failed for I/O unit");
    CheckError(AUGraphOpen (_processingGraph),"AUGraphOpen");
    CheckError(AUGraphNodeInfo ( _processingGraph,
                                ioNode,
                                NULL,
                                &_effectState.rioUnit
                                ),"AUGraphNodeInfo");
    
    // setup an asbd in the iphone canonical format
    AudioStreamBasicDescription myASBD;
    memset (&myASBD, 0, sizeof (myASBD));
    myASBD.mSampleRate = _actualSampleRate;
    myASBD.mFormatID = kAudioFormatLinearPCM;
    myASBD.mFormatFlags = kAudioFormatFlagsCanonical;
    myASBD.mBytesPerPacket = 4;
    myASBD.mFramesPerPacket = 1;
    myASBD.mBytesPerFrame = 4;
    myASBD.mChannelsPerFrame = 2;
    myASBD.mBitsPerChannel = 16;
    
    CheckError(AudioUnitSetProperty (_effectState.rioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input,
                                     0,
                                     &myASBD,
                                     sizeof (myASBD)),
               "Couldn't set ASBD for RIO on input scope / bus 0");
    
    _effectState.asbd = myASBD;
    // set callback method
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = AudioCallback; // callback function
    callbackStruct.inputProcRefCon = &_effectState;
    
    CheckError(AUGraphSetNodeInputCallback(_processingGraph, ioNode, 0, &callbackStruct),"callback failed");
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (_processingGraph);
    NSLog (@"Initializing the audio processing graph");
    CheckError(AUGraphInitialize (_processingGraph),"AUGraphInitialize");
    [self start];
//    CheckError(AUGraphStart(_processingGraph),"AUGtaphStart");
    
}

-(void)start {
    if(!_running) {
        CheckError(AUGraphStart(_processingGraph),"AUGtaphStart");
        _running = YES;
    }
}

-(void)stop {
    if(_running) {
        CheckError(AUGraphStop(_processingGraph),"AUGtaphStart");
        _running = NO;
    }
}

-(void)setupFilters
{
    //_actualSampleRate - actual value
    //_softwareSampleRate - our desire
    
    // jank lookup
    if (_softwareSampleRate == 8000) {
        switch ((int)_actualSampleRate) {
            case 8000:
            {
                _effectState.M = 2; //1
                _effectState.N = 2; //1
            }
                break;
            case 16000:
            {
                _effectState.M = 4; //2
                _effectState.N = 2; //1
            }
                break;
            case 22050:
            {
                _effectState.M = 11;
                _effectState.N = 4;
            }
                break;
            case 44100:
            {
                _effectState.M = 11;
                _effectState.N = 2;
            }
                break;
            default:
                break;
        }
    } else if (_softwareSampleRate == 16000) {
        switch ((int)_actualSampleRate) {
            case 8000:
            {
                _effectState.M = 2;
                _effectState.N = 2;
                //However, special case
                _softwareSampleRate = _actualSampleRate;
            }
                break;
            case 16000:
            {
                _effectState.M = 2; //1
                _effectState.N = 2; //1
            }
                break;
            case 22050:
            {
                _effectState.M = 11;
                _effectState.N = 8;
            }
                break;
            case 44100:
            {
                _effectState.M = 11;
                _effectState.N = 4;
            }
                break;
            default:
                NSLog(@"everything is broken, give UP");
                break;
        }
    }
    double coefs[5];
    switch (_effectState.M) {
        case 2:
        {
            coefs[0] = 0.2929;
            coefs[1] = 0.5858;
            coefs[2] = 0.2929;
            coefs[3] = 0.0000;
            coefs[4] = 0.1716;
        }
            break;
        case 4:
        {
            coefs[0] = 0.0976;
            coefs[1] = 0.1953;
            coefs[2] = 0.0976;
            coefs[3] = -0.9428;
            coefs[4] = 0.3333;
        }
            break;
        case 11:
        {
            coefs[0] = 0.0169;
            coefs[1] = 0.0338;
            coefs[2] = 0.0169;
            coefs[3] = -1.6002;
            coefs[4] = 0.6678;
        }
            break;
        default:
            NSLog(@"everything is broken, give UP");
            break;
    }
    for(int i=0; i<NUM_X_FILTERS; i++) {
        _effectState.antiXFilter[i].setCoefs(coefs);
    }
}

-(void)setupAudiobus
{
    self.audiobusController = [[ABAudiobusController alloc]
                               initWithAppLaunchURL:[NSURL URLWithString:@"bent-fm-lite.audiobus://"]
                               apiKey:@"MCoqKmJlbnQuZm0gbGl0ZSoqKmJlbnQtZm0tbGl0ZS5hdWRpb2J1czovLw==:GZOU5xkBsxd8zQa3z4S9CTqztnA+pv1A90PP2GUvJFkfiRp6ZRCYQvHR45kjxmV/J6O8KOulov8J8cqbajtm+B/wXiw6Z+4xoqeV7Gj9lGxWCL/ULo6ahYBFhTVg9aK0"];
    
    self.audiobusAudioUnitWrapper = [[ABAudiobusAudioUnitWrapper alloc]
                                     initWithAudiobusController:self.audiobusController
                                     audioUnit:self.effectState.rioUnit
                                     output:[self.audiobusController addOutputPortNamed:@"Audio Output"
                                                                                  title:NSLocalizedString(@"Main App Output", @"")]
                                     input:nil];
    self.audiobusAudioUnitWrapper.useLowLatencyInputStream = YES;
    UInt32 allowMixing = YES;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing);

}


- (void)connectionsChanged:(NSNotification*)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop) object:nil];
    if ( self.audiobusController.connected && !self.running ) {
        // Start the audio system upon connection, if it's not running already
        [self start];
    } else if ( !_audiobusController.connected && self.running
               && [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground ) {
        // Shut down after 10 seconds if we disconnected while in the background
        [self performSelector:@selector(stop) withObject:nil afterDelay:10.0];
    }
}


@end
