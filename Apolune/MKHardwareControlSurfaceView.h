//
//  MKHardwareControlSurfaceView.h
//  Apolune
//
//  Created by Mayank on 5/3/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MKHardwareControlSurfaceViewDelegate <NSObject>

-(void)connectionMadeFrom:(int)a to:(int)b;
-(void)connectionRemovedFrom:(int)a to:(int)b;

@end

@interface MKHardwareControlSurfaceView : UIView

@property (nonatomic, weak) id<MKHardwareControlSurfaceViewDelegate> delegate;
@property (nonatomic, strong) NSArray *blueprint;

@end
