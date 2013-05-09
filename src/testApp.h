#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxBox2d.h"
#include "ofxUI.h"
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
    
    void guiEvent(ofxUIEventArgs &e);
    
    ofxUISuperCanvas *gui;
    SettingsUIView *settingsUIView;
    
    bool bAddDrawer = false;
    bool bResetDrawers = false;
    bool bClearCanvas = false;
    bool bSaveCanvas = false;
    
    float initialMass = 1.0f;
    float friction = .8f;
    float bounciness = 0.8f;
    float gravity = 80.0f;
    float drawerRadius = 120;
    
    ofFbo clydiaCanvas;
    ofImage grabbed;
    unsigned char * pixels;
    
    // Branches
    vector <Branch *> branches;
    
    
    ofxBox2d world;
    vector <ofxBox2dCircle *> drawers;
    ofRectangle drawRect;
    
    void processOpenFileSelection(ofFileDialogResult openFileResult);
    //bool sortColorFunction (ofColor i,ofColor j);
	vector <ofImage> loadedImages;
	vector <ofImage> processedImages;
	string originalFileExtension;
    
};
