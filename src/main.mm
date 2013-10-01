#include "ofMain.h"
#include "ofAppiOSWindow.h"
#include "ofApp.h"


int main()
{
    ofAppiOSWindow * window = new ofAppiOSWindow();
    
    // iOSWindow->enableDepthBuffer();
    if (window->isRetinaSupportedOnDevice()) {
        window->enableRetina();
    } else {
        window->enableAntiAliasing(2);
    }
    
    ofSetupOpenGL(window, 1024, 768, OF_FULLSCREEN);
	ofRunApp(new ofApp());
}
