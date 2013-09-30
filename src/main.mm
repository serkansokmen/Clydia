#include "ofMain.h"
#include "App.h"


int main()
{
    ofAppiOSWindow * window = new ofAppiOSWindow();
    window->enableRendererES2();
    
    // iOSWindow->enableDepthBuffer();
    if (window->isRetinaSupportedOnDevice()) {
        window->enableRetina();
    } else {
        window->enableAntiAliasing(2);
    }
    
	ofSetupOpenGL(window, 1024, 768, OF_FULLSCREEN);    // setup the GL context
	ofRunApp(new App());                            // run app.
}
