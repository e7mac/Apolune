//
//  MKBlueprintItem.h
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChipIO.h>

@interface MKBlueprintItem : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) CGRect location;
@property (nonatomic, assign) ChipIO *pin;
@property (nonatomic, assign) BOOL pinIsOutput;

@end
