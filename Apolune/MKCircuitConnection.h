//
//  MKCircuitConnection.h
//  Apolune
//
//  Created by Mayank on 5/8/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChipInput.h>
#import <ChipOutput.h>

@interface MKCircuitConnection : NSObject

@property (nonatomic,assign) ChipInput *input;
@property (nonatomic,assign) ChipOutput *output;

@end
