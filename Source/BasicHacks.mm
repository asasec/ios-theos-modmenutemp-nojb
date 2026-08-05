#include "../MenuLoad/Includes.h"
#include "../utils/libtitanox/mempatch/THPatchMem.h"
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

static void ShowAlertNotification(NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        UIViewController *rootVC = window.rootViewController;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"KTemp Debug"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [rootVC presentViewController:alert animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

void* BasicHacks::HacksThread(void* arg)
{
    // Thread'in çalıştığını anlamak için direkt başa alert koyuyoruz
    ShowAlertNotification(@"HacksThread Başlatıldı!");

    bool lastState = false;

    while(KTempVars.running)
    {   
        if (KTempVars.StreamerMode) 
        {
            if (!lastState) 
            {
                ShowAlertNotification(@"Streamer Mode Açıldı Tetiklendi!");
                lastState = true;
            }
        } 
        else 
        {
            if (lastState) 
            {
                ShowAlertNotification(@"Streamer Mode Kapandı!");
                lastState = false;
            }
        }

        usleep(100000);
    }

    return NULL; 
}

void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}
