#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxBox2d.h"
#include "Branch.h"
#include "SettingsUIView.h"

#define FPS 30


class testApp : public ofxiPhoneApp
{
public:
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void clearCanvas();
    
    ofFbo clydiaCanvas;
    
    // Branches
    vector <Branch *>	branches;
    
    
    ofxBox2d world;
    ofxBox2dCircle *drawer;
    ofRectangle drawRect;
    
    bool    bUseTouch;
    
    //
    float initialMass;
    float friction;
    float bounciness;
    float gravity;
    float drawerRadius;
    
    SettingsUIView *settingsView;
};
