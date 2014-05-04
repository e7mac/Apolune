//
//  MKHardwareControlSurfaceView.m
//  Apolune
//
//  Created by Mayank on 5/3/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKHardwareControlSurfaceView.h"
#import "MKHardwareComponentView.h"

#define TAG_OFFSET 666

@interface MKHardwareControlSurfaceView ()

@property (nonatomic, strong) UIView *startingView;
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, strong) NSMutableArray *lineLayers;
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

- (NSMutableArray *)lineLayers
{
  if (_lineLayers == nil)
  {
    _lineLayers = [[NSMutableArray alloc] init];
  }
  return _lineLayers;
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
  int numRows = 10;
  int numCols = 10;
  float width = self.bounds.size.width/numCols;
  float height = self.bounds.size.height/numRows;
  for (int i=0;i<numCols;i++) {
    for (int j=0;j<numRows;j++) {
      float x = i * width;
      float y = j * height;
      MKHardwareComponentView *view = [[MKHardwareComponentView alloc] initWithFrame:CGRectMake(x, y, width, height)];
      [self addSubview:view];
      view.alpha = arc4random()%100/100.0;
      view.mode = arc4random()%2;
      view.tag = TAG_OFFSET + i * numRows + j;
    }
  }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.connecting = YES;
  UITouch *touch = [touches anyObject];
  self.startingView = touch.view;
  CGPoint point = [touch locationInView:self];
  [self removeConnectionAtPoint:point];
  [self.layer addSublayer:self.connectingWire];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  self.connectingWire.path = [self pathFromPoint:self.startingView.center toPointB:point].CGPath;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  UIView *endView = [self hitTest:point withEvent:event];
  [self connectStartView:self.startingView toEndView:endView];
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
  CALayer *hitLayer = nil;
  for (CAShapeLayer *layer in self.lineLayers) {
    CGPathRef path = layer.path;
    if (CGPathContainsPoint(path, nil, point, NO)) {
      hitLayer = layer;
    }
  }
  if (hitLayer) {
    [hitLayer removeFromSuperlayer];
    [self.lineLayers removeObject:hitLayer];
    NSArray *removedConnection = self.layerToConnection[[hitLayer description]];
    [self.layerToConnection removeObjectForKey:[hitLayer description]];
    UIView *startView = removedConnection[0];
    UIView *endView = removedConnection[1];
    [self.delegate connectionRemovedFrom:(startView.tag-TAG_OFFSET) to:(endView.tag - TAG_OFFSET)];
  }
}

-(void)connectStartView:(MKHardwareComponentView *)startView toEndView:(MKHardwareComponentView *)endView
{
  if (!startView || !endView || startView == endView || (UIView *)endView == self) return;
  if (startView.mode == endView.mode) return;
  if (startView.mode == MKHardwareComponentViewModeOutput) {
    //swap views
    MKHardwareComponentView *tempView = startView;
    startView = endView;
    endView = tempView;
  }
  NSArray *connection = @[startView, endView];
  CAShapeLayer *lineLayer = [self makeLineLayer:self.layer lineFromPointA:startView.center toPointB:endView.center];
  [self.lineLayers addObject:lineLayer];
  [self.layerToConnection setObject:connection forKey:[lineLayer description]];
  [self.delegate connectionMadeFrom:(startView.tag-TAG_OFFSET) to:(endView.tag-TAG_OFFSET)];
}

@end
