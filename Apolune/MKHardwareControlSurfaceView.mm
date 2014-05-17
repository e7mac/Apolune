//
//  MKHardwareControlSurfaceView.m
//  Apolune
//
//  Created by Mayank on 5/3/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKHardwareControlSurfaceView.h"
#import "MKHardwareComponentView.h"
#import "MKBlueprintItem.h"
#import "ApoluneKnobView.h"

#define TAG_OFFSET 666

@interface MKHardwareControlSurfaceView () <ApoluneKnobViewDelegate>

@property (nonatomic, strong) UIView *startingView;
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, strong) NSMutableArray *wires;
@property (nonatomic, strong) NSMutableDictionary *layerToConnection;
@property (nonatomic, strong) CAShapeLayer *connectingWire;

@end

@implementation MKHardwareControlSurfaceView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (NSMutableArray *)wires
{
  if (_wires == nil)
  {
    _wires = [[NSMutableArray alloc] init];
  }
  return _wires;
}

- (CAShapeLayer *)connectingWire
{
  if (_connectingWire == nil)
  {
    _connectingWire = [CAShapeLayer layer];
    _connectingWire.fillColor = [UIColor blueColor].CGColor;
    _connectingWire.strokeColor = [UIColor clearColor].CGColor;
  }
  return _connectingWire;
}

- (NSMutableDictionary *)layerToConnection
{
  if (_layerToConnection == nil)
  {
    _layerToConnection = [[NSMutableDictionary alloc] init];
  }
  return _layerToConnection;
}

-(void)commonInit
{
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.connecting = YES;
  UITouch *touch = [touches anyObject];
  self.startingView = touch.view;
  CGPoint point = [touch locationInView:self];
  if ([self.startingView class] == [MKHardwareComponentView class]) {
    [self removeConnectionAtPoint:point];
    [self.layer addSublayer:self.connectingWire];
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  if ([self.startingView class] == [MKHardwareComponentView class]) {
    self.connectingWire.path = [self pathFromPoint:self.startingView.center toPointB:point].CGPath;
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  UIView *endView = [self hitTest:point withEvent:event];
  
  if ([self.startingView class] == [MKHardwareComponentView class] &&
      [endView class] == [MKHardwareComponentView class]) {
    [self connectStartView:self.startingView toEndView:endView];
  }
  self.connectingWire.path = nil;
  self.startingView = nil;
  self.connecting = NO;  
}

-(CAShapeLayer *)makeLineLayer:(CALayer *)layer lineFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB
{
  CAShapeLayer *line = [CAShapeLayer layer];
  UIBezierPath *linePath=[self pathFromPoint:pointA toPointB:pointB];
  line.path=linePath.CGPath;
  line.fillColor = [UIColor blueColor].CGColor;
  line.opacity = 1.0;
  line.strokeColor = [UIColor clearColor].CGColor;
  [layer addSublayer:line];
  return line;
}

-(UIBezierPath *)pathFromPoint:(CGPoint)pointA toPointB:(CGPoint)pointB
{
  UIBezierPath *linePath=[UIBezierPath bezierPath];
  float theta = atan2f(pointB.y - pointA.y, pointB.x - pointA.x);
  theta += 3.14159/2;
  float thickness = 10;
  [linePath moveToPoint: pointA];
  [linePath addLineToPoint:CGPointMake(pointA.x+ thickness*cosf(theta), pointA.y+ thickness*sinf(theta))];
  [linePath addLineToPoint:CGPointMake(pointB.x+ thickness*cosf(theta), pointB.y+ thickness*sinf(theta))];
  [linePath addLineToPoint:pointB];
  return linePath;
}

-(void)removeConnectionAtPoint:(CGPoint)point
{
  NSDictionary *hitWire = nil;
  for (NSDictionary *wire in self.wires) {
    CAShapeLayer *layer = wire[@"lineLayer"];
    CGPathRef path = layer.path;
    if (CGPathContainsPoint(path, nil, point, NO)) {
      hitWire = wire;
    }
  }
  if (hitWire) {
    [self removeWire:hitWire];
  }
}

-(void)removeWire:(NSDictionary *)wire
{
  CALayer *hitLayer = wire[@"lineLayer"];
  [hitLayer removeFromSuperlayer];
  [self.wires removeObject:wire];
  NSArray *removedConnection = self.layerToConnection[[hitLayer description]];
  [self.layerToConnection removeObjectForKey:[hitLayer description]];
  UIView *startView = removedConnection[0];
  UIView *endView = removedConnection[1];
  [self.delegate connectionRemovedFrom:(startView.tag-TAG_OFFSET) to:(endView.tag - TAG_OFFSET)];
}

-(void)connectStartView:(MKHardwareComponentView *)startView toEndView:(MKHardwareComponentView *)endView
{
  if (!startView || !endView || startView == endView || (UIView *)endView == self) return;
  if (startView.mode == endView.mode) return;
  if (startView.mode == MKHardwareComponentViewModeInput) {
    //swap views
    MKHardwareComponentView *tempView = startView;
    startView = endView;
    endView = tempView;
  }
  //remove connection to input if present
  [self.wires enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *wire = (NSDictionary *)obj;
    UIView *wireEndView = wire[@"endView"];
    if (wireEndView == endView) {
      [self removeWire:wire];
    }
  }];
  
  NSArray *connection = @[startView, endView];
  CAShapeLayer *lineLayer = [self makeLineLayer:self.layer lineFromPointA:startView.center toPointB:endView.center];
  [self.wires addObject:@{@"startView":startView,
                          @"endView":endView,
                          @"lineLayer":lineLayer,
                          }];
  [self.layerToConnection setObject:connection forKey:[lineLayer description]];
  [self.delegate connectionMadeFrom:(startView.tag-TAG_OFFSET) to:(endView.tag-TAG_OFFSET)];
}

-(void)setBlueprint:(NSArray *)blueprint
{
  _blueprint = blueprint;
  if (blueprint) {
    [self relayViewsFromBlueprint];
  }
}

-(void)relayViewsFromBlueprint
{
  [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *view = (UIView *)obj;
    [view removeFromSuperview];
  }];
  int tag = TAG_OFFSET;
  for (MKBlueprintItem *item in self.blueprint) {
    NSString *type = item.type;
    CGRect rect = item.location;
    if ([type isEqualToString:@"BananaJack"]) {
      BOOL io = item.pinIsOutput;
      MKHardwareComponentView *view = [[MKHardwareComponentView alloc] initWithFrame:rect];
      [self addSubview:view];
      view.alpha = arc4random()%100/100.0*0.6 + 0.4;
      if (io) {
        view.mode = MKHardwareComponentViewModeOutput;
      } else {
        view.mode = MKHardwareComponentViewModeInput;
      }
      view.tag = tag;
      tag++;
    } else if ([type isEqualToString:@"Knob"]) {
      ApoluneKnobView *view = [[ApoluneKnobView alloc] initWithFrame:rect];
      view.blueprintItem = item;
      [self addSubview:view];
      view.tag = tag;
      view.delegate = self;
      tag++;
    }
  }
}

-(void)knob:(ApoluneKnobView *)knob changedValue:(float)value
{
  knob.blueprintItem.process(value);
}

@end
