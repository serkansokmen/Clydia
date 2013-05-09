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
    ofSetLogLevel(OF_LOG_WARNING);
    ofEnableSmoothing();
    ofSetVerticalSync(true);
    ofSetCircleResolution(25);
    
    world.init();
    world.doSleep = false;
    world.checkBounds(true);
    world.createBounds(0, 0, ofGetWidth(), ofGetHeight());
    world.registerGrabbing();
    world.setFPS(FPS);
    
    // register the listener so that we get the events
    ofAddListener(world.contactStartEvents, this, &testApp::contactStart);
    ofAddListener(world.contactEndEvents, this, &testApp::contactEnd);
    
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
    ofSetColor(0, 255);
    ofRect(0, 0, ofGetWidth(), ofGetHeight());
    clydiaCanvas.end();
    
    drawRect.set(0, 0, ofGetWidth(), ofGetHeight());
    
    int width = (int)clydiaCanvas.getWidth();
    int height = (int)clydiaCanvas.getHeight();
    
    pixels = new unsigned char[width * height * 4];
    grabbed.allocate(width, height, OF_IMAGE_COLOR_ALPHA);
    
    // GUI
    gui = new ofxUISuperCanvas("CLYDIA", OFX_UI_FONT_LARGE);
    gui->setPosition(30, 30);
    gui->setGlobalButtonDimension(80);
    gui->setGlobalCanvasWidth(ofGetWidth() - 60);
    gui->setGlobalSliderHeight(44);
    gui->setGlobalSpacerHeight(1);
    
    gui->addSlider("BOUNCINESS", 0.0f, 1.0f, &bounciness);
    gui->addSlider("FRICTION", 0.1f, 2.0f, &friction);
    gui->addSlider("GRAVITY", 20.0f, 100.0f, &gravity);
    gui->addSpacer();
    gui->addLabelButton("ADD DRAWER", &bAddDrawer);
    gui->addLabelButton("RESET DRAWERS", &bResetDrawers);
    gui->addSpacer();
    gui->addLabelButton("SAVE", &bSaveCanvas);
    gui->addLabelButton("CLEAR", &bClearCanvas);
    
    ofAddListener(gui->newGUIEvent, this, &testApp::guiEvent);
    
    gui->loadSettings("GUI/guiSettings.xml");
}

//--------------------------------------------------------------
void testApp::update(){
    
    if (bAddDrawer) {
        addDrawer();
        bAddDrawer = false;
    }
    if (bResetDrawers) {
        resetDrawers();
        bResetDrawers = false;
    }
    if (bClearCanvas) {
        clearCanvas();
        bClearCanvas = false;
    }
    if (bSaveCanvas) {
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
    
    for (int i=0; i<drawers.size(); i++) {
        ofxBox2dCircle *drawer = drawers[i];
        
        ofVec2f *tPos = new ofVec2f;
        
        tPos->set(drawer->getPosition());
        if (drawer->getVelocity().x >= 2.0f || drawer->getVelocity().y >= 2.0f) {
            Branch *branch = new Branch;
            tPos->x += ofRandom(-1, 1) * 10;
            tPos->y += ofRandom(-1, 1) * 10;
            branch->setup(*tPos, drawRect);
            (ofRandomf() < .1f) ? branch->setDrawMode(CL_BRANCH_DRAW_CIRCLES) : branch->setDrawMode(CL_BRANCH_DRAW_CIRCLES);
            branch->setDrawMode(CL_BRANCH_DRAW_LEAVES);
            branches.push_back(branch);
        }
    }
    
	// update clydias
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
void testApp::draw(){
    
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
void testApp::contactStart(ofxBox2dContactArgs &e){
    if (e.a != NULL && e.b != NULL)
    {
        // don't check for ground collisions
        if(e.a->GetType() == b2Shape::e_circle && e.b->GetType() == b2Shape::e_circle)
        {
            ofVec2f *aPos = new ofVec2f;
            ofVec2f *bPos = new ofVec2f;
            ofVec2f *middlePos = new ofVec2f;
            
            aPos->set(e.a->GetBody()->GetPosition().x, e.a->GetBody()->GetPosition().y);
            bPos->set(e.b->GetBody()->GetPosition().x, e.b->GetBody()->GetPosition().y);
            
            middlePos->set(aPos->getMiddle(*bPos));
            
//            Branch *branch = new Branch;
//            middlePos->x += ofRandom(-1, 1) * 10;
//            middlePos->y += ofRandom(-1, 1) * 10;
//            branch->setup(*middlePos, drawRect);
//            (ofRandomf() < .5f) ? branch->setDrawMode(CL_BRANCH_DRAW_LEAVES) : branch->setDrawMode(CL_BRANCH_DRAW_CIRCLES);
//            branch->setDrawMode(CL_BRANCH_DRAW_LEAVES);
//            branches.push_back(branch);
        }
    }
}

//--------------------------------------------------------------
void testApp::contactEnd(ofxBox2dContactArgs &e) {
    if (e.a != NULL && e.b != NULL)
    {
//        SoundData * aData = (SoundData*)e.a->GetBody()->GetUserData();
//        SoundData * bData = (SoundData*)e.b->GetBody()->GetUserData();
        
//        if(aData)
//        {
//            aData->bHit = false;
//        }
//        
//        if(bData)
//        {
//            bData->bHit = false;
//        }
    }
}

//--------------------------------------------------------------
void testApp::guiEvent(ofxUIEventArgs &e)
{
	
}

//--------------------------------------------------------------
void testApp::clearCanvas(){
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
void testApp::resetDrawers(){
    for (int i=0;i<drawers.size();i++){
        drawers[i]->destroy();
    }
	drawers.clear();
}

//--------------------------------------------------------------
void testApp::saveCanvas(){
    
    ofFbo fbo;
    
    int width = (int)clydiaCanvas.getWidth();
    int height = (int)clydiaCanvas.getHeight();
    
    fbo.begin();
    
    clydiaCanvas.draw(0, 0, ofGetWidth(), ofGetHeight());
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    
    grabbed.setFromPixels(pixels, width, height, OF_IMAGE_COLOR_ALPHA);
    grabbed.saveImage("test1.png");
    fbo.end();
}

//--------------------------------------------------------------
void testApp::exit(){
    gui->saveSettings("GUI/guiSettings.xml");
    delete gui;
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::addDrawer(){
    
    if (drawers.size() < 5) {
        
        bool bCanAddDrawer = true;
        
        ofxBox2dCircle *drawer = new ofxBox2dCircle;
        drawer->setPhysics(drawerRadius * drawerRadius * initialMass, bounciness, friction);
        
        float x = ofGetWidth() / 2;
        float y = drawerRadius * 1.5f;
        
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
            delete drawer;
            drawer = 0;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    gui->toggleMinified();
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

