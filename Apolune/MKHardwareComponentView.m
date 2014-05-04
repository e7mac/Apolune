//
//  MKHardwareComponentView.m
//  Apolune
//
//  Created by Mayank on 5/4/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKHardwareComponentView.h"

@implementation MKHardwareComponentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setMode:(MKHardwareComponentViewMode)mode
{
  _mode = mode;
  if (mode) {
    self.backgroundColor = [UIColor purpleColor];
  } else {
    self.backgroundColor = [UIColor orangeColor];
  }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
