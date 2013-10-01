#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxBox2d.h"
#include "ofxGui.h"
#include "Branch.h"
#include "SettingsUIView.h"

#define FPS 60


class ofApp : public ofxiOSApp
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
    
    ofParameter<float> initialMass;
    ofParameter<float> friction;
    ofParameter<float> bounciness;
    ofParameter<float> gravity;
    ofParameter<bool>  bDraw;
    
    float drawerRadius;
    bool bAddDrawer;
    bool bResetDrawers;
    bool bClearCanvas;
    bool bSaveCanvas;
    
    ofRectangle         *drawRect;
    
    // Clydia
    ofFbo               clydiaCanvas;
    vector<Branch *>    branches;
    
    // GUI
    SettingsUIView      *settingsUIView;
    
    // Box2d
    ofxBox2d world;
    vector <ofxBox2dCircle *> drawers;
};
