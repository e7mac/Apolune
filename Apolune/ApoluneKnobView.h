//
//  ApoluneKnobView.h
//  Pods
//
//  Created by Mayank on 5/9/14.
//
//

#import <UIKit/UIKit.h>
#import "MKBlueprintItem.h"

@class ApoluneKnobView;

@protocol ApoluneKnobViewDelegate <NSObject>

-(void)knob:(ApoluneKnobView *)knob changedValue:(float)value;

@end

@interface ApoluneKnobView : UIView

@property (nonatomic, assign) float value;
@property (nonatomic, strong) MKBlueprintItem *blueprintItem;
@property (nonatomic, weak) id<ApoluneKnobViewDelegate> delegate;

@end
