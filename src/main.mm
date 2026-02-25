#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#include <iostream>
#include "SynergeticRenderer.hpp"
#include "SynergeticsMath.hpp"

using namespace Synergetics;

@interface SynergeticView : NSView
@property (assign, nonatomic) SynergeticRenderer *renderer;
@end

@implementation SynergeticView
- (BOOL)acceptsFirstResponder { return YES; }
- (void)keyDown:(NSEvent *)event {
    if (event.keyCode == 49) { // Spacebar
        if (self.renderer) self.renderer->toggleJanus();
    } else {
        [super keyDown:event];
    }
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSWindow *window;
@property (assign, nonatomic) SynergeticRenderer *renderer;
@property (strong, nonatomic) CAMetalLayer *metalLayer;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // DETERMINISM BENCHMARK
    std::cout << "--- Synergetic Determinism Benchmark ---" << std::endl;
    
    // Exact 60-degree rotation rotor (about W-axis)
    // w = cos(30) = sqrt(3)/2, x = sin(30) = 1/2
    RationalSurd w60 = {0, 1, 2}; // (0 + 1*sqrt(3))/2
    RationalSurd x60 = {1, 0, 2}; // (1 + 0*sqrt(3))/2
    SurdRotor delta = {w60, x60, RationalSurd::zero(), RationalSurd::zero(), 1};
    
    SurdRotor current = SurdRotor::identity();
    SurdRotor identity = SurdRotor::identity();

    std::cout << "Chaining 60-degree SurdRotor 6 times..." << std::endl;
    for(int i=0; i<6; i++) {
        current = current.multiply(delta);
    }

    // Check if we are back to identity (1, 0, 0, 0)
    if(current.w.equals(identity.w) && current.x.equals(identity.x)) {
        std::cout << "SUCCESS: Result is BIT-EXACT to identity (Zero Drift)." << std::endl;
    } else {
        std::cout << "FAILURE: Numerical drift detected." << std::endl;
        std::cout << "  Final W: (" << current.w.a << " + " << current.w.b << "sqrt(3)) / " << current.w.divisor << std::endl;
    }
    std::cout << "---------------------------------------" << std::endl;

    NSRect frame = NSMakeRect(0, 0, 800, 600);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                             styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable)
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
    [self.window setTitle:@"Synergetic Renderer - Press SPACE to Flip Janus"];
    
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    self.metalLayer = [CAMetalLayer layer];
    self.metalLayer.device = device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Use custom SynergeticView
    SynergeticView *view = [[SynergeticView alloc] initWithFrame:frame];
    [view setWantsLayer:YES];
    [view setLayer:self.metalLayer];
    
    self.renderer = new SynergeticRenderer((MTL::Device*)device);
    view.renderer = self.renderer; // Link renderer to view
    
    [self.window setContentView:view];
    [self.window makeKeyAndOrderFront:nil];
    
    // Capture self unsafely for MRC context
    __unsafe_unretained AppDelegate *weakSelf = self;
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf && strongSelf.renderer) {
            strongSelf.renderer->draw((CA::MetalLayer*)strongSelf.metalLayer);
        }
    }];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
