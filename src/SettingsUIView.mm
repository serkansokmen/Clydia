//
//  SettingsUIView.cpp
//  FishEyes
//
//  Created by Serkan Sökmen on 30.04.2013.
//
//

#import "SettingsUIView.h"
#import "ofxiPhoneExtras.h"
#import "testApp.h"

@implementation SettingsUIView

testApp *app;

-(void) viewDidLoad
{
    app = (testApp*)ofGetAppPtr();
}

-(IBAction)hide
{
    [[self view] setHidden:YES];
}

-(IBAction)clearCanvas:(id)sender
{
    app->clearCanvas();
}

- (IBAction)toggleToush:(UISwitch *)sender
{
    UISwitch *switchObj = (UISwitch*)sender;
    app->bUseTouch = switchObj.on;
}


- (IBAction)setBounciness:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->bounciness = [sliderObj value];
}

- (IBAction)setFriction:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->friction = [sliderObj value];
}

- (IBAction)setGravity:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->gravity = [sliderObj value];
}

@end
