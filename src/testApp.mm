#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    // initialize the accelerometer
    ofxAccelerometer.setup();
    
    //iPhoneAlerts will be sent to this.
    ofxiPhoneAlerts.addListener(this);
    
    // register touch events
    ofRegisterTouchEvents(this);
    
    //If you want a landscape oreintation
    //iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
    ofSetBackgroundAuto(true);
    ofBackgroundGradient(ofColor(0), ofColor(0x490704));
    
    ofEnableAlphaBlending();
    ofSetFrameRate(FPS);
    ofEnableSmoothing();
    ofSetVerticalSync(true);
    
    world.init();
    world.doSleep = false;
    world.checkBounds(true);
    world.createBounds(0, 0, ofGetWidth(), ofGetHeight());
    world.registerGrabbing();
    world.setFPS(FPS);
    
    ofFbo::Settings settings;
    settings.width = ofGetWidth();
    settings.height = ofGetHeight();
    settings.internalformat = GL_RGBA;
    settings.numSamples = 0;
    settings.useDepth = true;
    settings.useStencil = true;
    clydiaCanvas.allocate(settings);
    
    clearCanvas();
    
    clydiaCanvas.begin();
    ofPushStyle();
    ofSetColor(0, 1);
    ofRect(0, 0, ofGetWidth(), ofGetHeight());
    ofPopStyle();
    clydiaCanvas.end();
    
    
    drawRect.set(0, 0, ofGetWidth(), ofGetHeight());
    bSaveCanvas = false;
    
    initialMass = 20.0f;
    friction = .8f;
    bounciness = 0.2f;
    gravity = 80.0f;
    drawerRadius = 50;
    
    settingsView = [[SettingsUIView alloc] initWithNibName:@"SettingsUIView" bundle:nil];
    [ofxiPhoneGetGLView() addSubview:settingsView.view];
    settingsView.view.hidden = YES;
}

//--------------------------------------------------------------
void testApp::update(){
    
    float accx = ofxAccelerometer.getForce().x;
    float accy = ofxAccelerometer.getForce().y;
    
    // Box2D
    world.update();
    
    float fx = accx * gravity;
    float fy = accy * -gravity;
    
    world.setGravity(fx, fy);
    
    for (int i=0; i<drawers.size(); i++) {
        ofxBox2dCircle *drawer = drawers[i];
        
        // Update tracked positions
        ofVec2f *tPos = new ofVec2f;
        
        tPos->set(drawer->getPosition());
        
        Branch *branch = new Branch;
        tPos->x += ofRandom(-1, 1) * 10;
        tPos->y += ofRandom(-1, 1) * 10;
        branch->setup(*tPos, drawRect);
        //(ofRandom(0, 10) < 8) ? branch->setDrawMode(CL_BRANCH_DRAW_LEAVES) : branch->setDrawMode(CL_BRANCH_DRAW_CIRCLES);
        branch->setDrawMode(CL_BRANCH_DRAW_LEAVES);
        branches.push_back(branch);
    }
    
    //--------------------------------------------------------------
	// update clydias
	//--------------------------------------------------------------
	for (int i=0; i<branches.size(); i++) {
		if (branches[i]->getIsAlive()) {
            branches[i]->update();
        } else {
            delete branches[i];
            branches[i] = 0;
            branches.erase(branches.begin()+i);
        }
	}
    
    // draw branches
    clydiaCanvas.begin();
    ofSetColor(0, 0);
	for (int i=0; i<branches.size(); i++) {
        branches[i]->draw();
    }
    clydiaCanvas.end();
}

//--------------------------------------------------------------
void testApp::draw() {
    
    ofSetColor(255, 255);
    clydiaCanvas.draw(0, 0);
    
    // save image
    if (bSaveCanvas) {
        ofImage temp;
        temp.grabScreen(0, 0, ofGetWidth(), ofGetHeight());
        // ofGetFrameNum()
        temp.saveImage("blah.jpg");
        bSaveCanvas = false;
    } else {
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
}

//--------------------------------------------------------------
// clear the canvas
//--------------------------------------------------------------
void testApp::clearCanvas()
{
    for (int i=0;i<branches.size();i++)
    {
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
void testApp::saveCanvas(){
    
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
    if (drawers.size() < 5) {
        
        bool bAddDrawer = true;
        
        ofxBox2dCircle *drawer = new ofxBox2dCircle;
        drawer->setPhysics(drawerRadius * drawerRadius * initialMass, bounciness, friction);
        drawer->setup(world.getWorld(), touch.x, touch.y, drawerRadius);
        
        
        for (int i=0; i<drawers.size(); i++) {
            ofxBox2dCircle *existingDrawer = drawers[i];
            
            if (existingDrawer->getPosition().distance(drawer->getPosition()) < 100) {
                bAddDrawer = false;
            }
        }
        
        if (bAddDrawer) {
            drawers.push_back(drawer);
        } else {
            drawer->destroy();
        }
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    settingsView.view.hidden = NO;
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    clearCanvas();
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}

