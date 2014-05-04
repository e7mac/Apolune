//
//  MKHardwareComponentView.h
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MKHardwareComponentViewMode {
  MKHardwareComponentViewModeInput,
  MKHardwareComponentViewModeOutput
} MKHardwareComponentViewMode;

@interface MKHardwareComponentView : UIView

@property (nonatomic, assign) MKHardwareComponentViewMode mode;

@end
