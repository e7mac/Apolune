//
//  ApoluneKnobView.m
//  Pods
//
//  Created by Mayank on 5/9/14.
//
//

#import "ApoluneKnobView.h"

@implementation ApoluneKnobView {
  UIView *colorView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      colorView = [[UIView alloc] initWithFrame:self.bounds];
      [self addSubview:colorView];
      colorView.backgroundColor = [UIColor blackColor];
      colorView.alpha = arc4random()%60/100.0 + 0.4;
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  self.value = point.y / self.bounds.size.height;
  if ([self.delegate respondsToSelector:@selector(knob:changedValue:)]) {
    [self.delegate knob:self changedValue:self.value];
  }
}

-(void)setValue:(float)value
{
  _value = value;
  colorView.frame = CGRectMake(0, 0, self.bounds.size.width, value * self.bounds.size.height);
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
