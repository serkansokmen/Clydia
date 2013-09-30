#include "App.h"

//--------------------------------------------------------------
void App::setup(){
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
    ofxAccelerometer.setup();
    ofRegisterTouchEvents(this);
    ofSetBackgroundAuto(true);
    
    ofxiPhoneAlerts.addListener(this);
    ofBackgroundGradient(ofColor(0), ofColor(0x490704));
    
    ofEnableAlphaBlending();
    ofSetFrameRate(FPS);
    ofSetLogLevel(OF_LOG_WARNING);
    ofEnableSmoothing();
    ofSetVerticalSync(true);
    
    // Box2d
    world.init();
    world.doSleep = false;
    world.checkBounds(true);
    world.createBounds(0, 0, ofGetWidth(), ofGetHeight());
    world.registerGrabbing();
    world.setFPS(FPS);
    
    ofFbo::Settings settings;
    settings.width = ofGetWidth();
    settings.height = ofGetHeight();
    settings.internalformat = GL_RGB;
    settings.numSamples = 0;
    settings.useDepth = true;
    settings.useStencil = true;
    clydiaCanvas.allocate(settings);
    
    clearCanvas();
    
    clydiaCanvas.begin();
    ofSetColor(0, 255);
    ofRect(0, 0, ofGetWidth(), ofGetHeight());
    clydiaCanvas.end();
    
    // GUI
    settingsUIView = [[SettingsUIView alloc] initWithNibName:@"SettingsUIView" bundle:nil];
    
    [ofxiOSGetGLView() addSubview:settingsUIView.view];
    settingsUIView.view.hidden = NO;
    
    drawRect = new ofRectangle;
    drawRect->set(0, 0, clydiaCanvas.getWidth(), clydiaCanvas.getHeight());
}

//--------------------------------------------------------------
void App::update(){
    
    if (bAddDrawer){
        addDrawer();
        bAddDrawer = false;
    }
    if (bResetDrawers){
        resetDrawers();
        bResetDrawers = false;
    }
    if (bClearCanvas){
        clearCanvas();
        bClearCanvas = false;
    }
    if (bSaveCanvas){
        saveCanvas();
        bSaveCanvas = false;
    }
    
    float accx = ofxAccelerometer.getForce().x;
    float accy = ofxAccelerometer.getForce().y;
    
    // Box2D
    world.update();
    
    float fx = accx * gravity;
    float fy = accy * -gravity;
    
    world.setGravity(fx, fy);
    
    ofVec2f *tPos = new ofVec2f;
    
    for (int i=0; i<drawers.size(); i++){
        ofxBox2dCircle *drawer = drawers[i];
        
        tPos->set(drawer->getPosition());
        
        Branch *branch = new Branch;
        tPos->x += ofRandom(-1, 1) * 10;
        tPos->y += ofRandom(-1, 1) * 10;
        branch->setup(*tPos, *drawRect);
        branches.push_back(branch);
    }
    
    if (bDraw) {
        // update clydias
        for (int i=0; i<branches.size(); i++) {
            if (branches[i]->getIsAlive()) {
                branches[i]->update();
            } else {
                delete branches[i];
                branches[i] = 0;
                branches.erase(branches.begin() + i);
            }
        }
        
        // draw branches
        clydiaCanvas.begin();
        for (int i=0; i<branches.size(); i++) {
            branches[i]->draw();
        }
        clydiaCanvas.end();
    }
}

//--------------------------------------------------------------
void App::draw(){
    
    ofSetColor(255, 255);
    clydiaCanvas.draw(0, 0);
    
    for (int i=0; i<drawers.size(); i++) {
        ofxBox2dCircle *drawer = drawers[i];
        
        ofSetColor(255, 255, 255, 20);
        ofCircle(drawer->getPosition(), drawerRadius);
        ofNoFill();
        ofSetColor(255, 0, 0, 255);
        ofCircle(drawer->getPosition(), drawerRadius);
        ofFill();
        ofSetColor(255);
        ofCircle(drawer->getPosition(), drawerRadius / 10);
    }
}

//--------------------------------------------------------------
void App::clearCanvas(){
    
    for (int i=0;i<branches.size();i++){
        branches[i]->kill();
        delete branches[i];
        branches[i] = 0;
    }
	branches.clear();
    
    clydiaCanvas.begin();
	ofSetColor(0, 255);
	ofRect(0, 0, ofGetWidth(), ofGetHeight());
    clydiaCanvas.end();
}


//--------------------------------------------------------------
void App::resetDrawers(){
    for (int i=0;i<drawers.size();i++){
        drawers[i]->destroy();
    }
	drawers.clear();
}

//--------------------------------------------------------------
void App::saveCanvas(){
    
    resetDrawers();
    
    ofFbo fbo;
    
    fbo.begin();
    
    clydiaCanvas.draw(0, 0, ofGetWidth(), ofGetHeight());
    
    fbo.end();
    
    ofxiPhoneAppDelegate * delegate = ofxiPhoneGetAppDelegate();
    
    ofxiPhoneScreenGrab(delegate);
}

//--------------------------------------------------------------
void App::exit(){
    resetDrawers();
    clearCanvas();
}

//--------------------------------------------------------------
void App::touchDown(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void App::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void App::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void App::addDrawer(){
    
    if (drawers.size() < 5) {
        
        bool bCanAddDrawer = true;
        
        ofxBox2dCircle *drawer = new ofxBox2dCircle;
        drawer->setPhysics(drawerRadius * drawerRadius * initialMass, bounciness, friction);
        
        float x = ofGetWidth() * .5f;
        float y = (ofGetHeight() - ofGetHeight() * .5f) + drawerRadius * .5f;
        
        drawer->setup(world.getWorld(), x, y, drawerRadius);
        
        for (int i=0; i<drawers.size(); i++) {
            ofxBox2dCircle *existingDrawer = drawers[i];
            
            if (existingDrawer->getPosition().distance(drawer->getPosition()) < 100) {
                bCanAddDrawer = false;
            }
        }
        
        if (bCanAddDrawer) {
            drawers.push_back(drawer);
        } else {
            drawer->destroy();
        }
    }
}

//--------------------------------------------------------------
void App::touchDoubleTap(ofTouchEventArgs & touch){
    settingsUIView.view.hidden = NO;
}

//--------------------------------------------------------------
void App::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void App::lostFocus(){
    
}

//--------------------------------------------------------------
void App::gotFocus(){
    
}

//--------------------------------------------------------------
void App::gotMemoryWarning(){
    clearCanvas();
}

//--------------------------------------------------------------
void App::deviceOrientationChanged(int newOrientation){
//    switch (newOrientation) {
//        case OF_ORIENTATION_90_LEFT:
//            ofxiPhoneSetOrientation(OF_ORIENTATION_90_RIGHT);
//            break;
//            
//        case OF_ORIENTATION_90_RIGHT:
//            ofxiPhoneSetOrientation(OF_ORIENTATION_90_RIGHT);
//            break;
//        
//        case OF_ORIENTATION_180:
//            ofxiPhoneSetOrientation(OF_ORIENTATION_180);
//            break;
//        
//        case OF_ORIENTATION_DEFAULT:
//        case OF_ORIENTATION_UNKNOWN:
//            ofxiPhoneSetOrientation(OF_ORIENTATION_DEFAULT);
//            break;
//    }
}
