//
//  SettingsUIView.cpp
//  FishEyes
//
//  Created by Serkan Sökmen on 30.04.2013.
//
//

#import "SettingsUIView.h"
#import "ofxiPhoneExtras.h"
#import "ofApp.h"

@implementation SettingsUIView

ofApp *app;

-(void)viewDidLoad
{
    app = (ofApp*)ofGetAppPtr();
}

- (IBAction)toggleDrawEnabled:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    app->bDraw.set(theSwitch.on);
}

-(IBAction)hide
{
    [[self view] setHidden:YES];
}

-(IBAction)clearCanvas:(id)sender
{
    app->clearCanvas();
}

-(IBAction)saveCanvas:(id)sender
{
    app->saveCanvas();
}

-(IBAction)addDrawer:(id)sender
{
    app->addDrawer();
}

-(IBAction)resetDrawers:(id)sender
{
    app->resetDrawers();
}


- (IBAction)setBounciness:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->bounciness.set([sliderObj value]);
}

- (IBAction)setFriction:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->friction.set([sliderObj value]);
}

- (IBAction)setGravity:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->gravity.set([sliderObj value]);
}

@end
