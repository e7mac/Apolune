//
//  MKViewController.m
//  Apolune
//
//  Created by Mayank on 5/3/14.
//  Copyright (c) 2014 Enbits LLC. All rights reserved.
//

#import "MKViewController.h"
#import<MKAudioKit/AudioController.h>
#import "MKApoluneCircuit.h"
#import "MKHardwareControlSurfaceView.h"
#import "MKBlueprintItem.h"
#import "MKCircuitConnection.h"

@interface MKViewController () <MKHardwareControlSurfaceViewDelegate>

@property (weak, nonatomic) IBOutlet MKHardwareControlSurfaceView *HardwareComponentView;
@property (nonatomic, strong) AudioController *audioController;
@property (nonatomic, strong) MKApoluneCircuit *apoluneCircuit;
@property (nonatomic, strong) NSMutableArray *tagToConnection;

@end

@implementation MKViewController

- (MKApoluneCircuit *)apoluneCircuit
{
  if (_apoluneCircuit == nil)
  {
    _apoluneCircuit = [[MKApoluneCircuit alloc] init];
  }
  return _apoluneCircuit;
}

- (NSMutableArray *)tagToConnection
{
  if (_tagToConnection == nil)
  {
    _tagToConnection = [[NSMutableArray alloc] init];
  }
  return _tagToConnection;
}
- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.HardwareComponentView.delegate = self;
  
  self.audioController = [AudioController sharedInstance];
  [self.audioController setupAudioSessionRequestingSampleRate:8000];
  [self.apoluneCircuit setupCircuit];
  [self.audioController setupProcessBlockWithAudioCallback:self.apoluneCircuit.processBlock];
  [self.audioController setupDone];
  [self createBlueprint];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)connectionMadeFrom:(int)a to:(int)b
{
  MKBlueprintItem *connectionFromItem = self.tagToConnection[a];
  MKBlueprintItem *connectionToItem = self.tagToConnection[b];
  ChipOutput *output = (ChipOutput *)connectionFromItem.pin;
  ChipInput *input = (ChipInput *)connectionToItem.pin;
  
  [self.apoluneCircuit makeConnectionFromChipOutput:output toChipInput:input];
}

-(void)connectionRemovedFrom:(int)a to:(int)b
{
  //  MKBlueprintItem *connectionFromItem = self.tagToConnection[a];
  MKBlueprintItem *connectionToItem = self.tagToConnection[b];
  //  ChipOutput *output = (ChipOutput *)connectionFromItem.pin;
  ChipInput *input = (ChipInput *)connectionToItem.pin;
  
  [self.apoluneCircuit removeConnectionFromChipInput:input];
}

-(void)createBlueprint
{
  int numRows = 5;
  MKBlueprintItem *i;
  NSMutableArray *array = [@[] mutableCopy];
  
  // Oscillator 1
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"Knob";
  i.location = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows);
  
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.osc1->output[0]);
  [array addObject:i];
  
  // Oscillator 2
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"Knob";
  i.location = CGRectMake(0, self.view.bounds.size.height/numRows, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/numRows, self.view.bounds.size.width/2, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.osc2->output[0]);
  [array addObject:i];
  
  // NAND Chip
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(0, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = NO;
  i.pin = &(self.apoluneCircuit.bendNand1->input[0]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = NO;
  i.pin = &(self.apoluneCircuit.bendNand1->input[1]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*2/3, self.view.bounds.size.height/numRows*2, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendNand1->output);
  [array addObject:i];
  
  // XOR Chip
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(0, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = NO;
  i.pin = &(self.apoluneCircuit.bendXor1->input[0]);
  
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = NO;
  i.pin = &(self.apoluneCircuit.bendXor1->input[1]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*2/3, self.view.bounds.size.height/numRows*3, self.view.bounds.size.width/3, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendXor1->output);
  [array addObject:i];
  
  // Counter Chip
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*0/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = NO;
  i.pin = &(self.apoluneCircuit.bendCounter1->input);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*1/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[0]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*2/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[1]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*3/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[2]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*4/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[3]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*5/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[4]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*6/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[5]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*7/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[6]);
  [array addObject:i];
  
  i = [[MKBlueprintItem alloc] init];
  i.type = @"BananaJack";
  i.location = CGRectMake(self.view.bounds.size.width*8/9, self.view.bounds.size.height/numRows*4, self.view.bounds.size.width/9, self.view.bounds.size.height/numRows);
  i.pinIsOutput = YES;
  i.pin = &(self.apoluneCircuit.bendCounter1->output[7]);
  [array addObject:i];
  
  int tag = 0; // TAG_OFFSET
  for (MKBlueprintItem *item in array) {
    [self.tagToConnection addObject:item];
  }
  self.HardwareComponentView.blueprint = array;
}
@end
