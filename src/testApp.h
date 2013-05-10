#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxBox2d.h"
#include "Branch.h"
#include "SettingsUIView.h"

#define FPS 60


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
    void saveCanvas();
    
    void addDrawer();
    void resetDrawers();
    
    SettingsUIView *settingsUIView;
    
    bool bDraw = true;
    bool bAddDrawer = false;
    bool bResetDrawers = false;
    bool bClearCanvas = false;
    bool bSaveCanvas = false;
    
    float initialMass = 1.0f;
    float friction = .8f;
    float bounciness = 0.8f;
    float gravity = 80.0f;
    float drawerRadius = 80;
    
    ofRectangle *drawRect;
    
    // Clydia
    ofFbo clydiaCanvas;
    vector <Branch *> branches;
    
    int maxCircles = 50;
    
    // Box2d
    ofxBox2d world;
    vector <ofxBox2dCircle *> drawers;
};
