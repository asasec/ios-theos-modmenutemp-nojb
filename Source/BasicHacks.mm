#include "../MenuLoad/Includes.h"
#import <UIKit/UIKit.h>

// Ekranda kısa süreliğine bildirim göstermek için yardımcı fonksiyon
static void ShowAlertNotification(NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        UIViewController *rootVC = window.rootViewController;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"KTemp Debug"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [rootVC presentViewController:alert animated:YES completion:nil];
        
        // 1.5 saniye sonra bildirimi otomatik kapat
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

void* BasicHacks::HacksThread(void* arg)
{
    bool lastState = false;
    
    try {
        // UnityFramework üzerinden offset ve hex patch tanımı
        MemoryPatch patch = MemoryPatch::createWithHex("UnityFramework", 0x210EC54, "E0 47 88 52 E0 01 A0 72 C0 03 5F D6");

        while(KTempVars.running)
        {   
            if (KTempVars.StreamerMode) 
            {
                if (!lastState) 
                {
                    if (patch.isValid()) 
                    {
                        patch.modify();
                        ShowAlertNotification(@"Streamer Mode: AÇILDI (Patch Başarılı)");
                    } 
                    else 
                    {
                        ShowAlertNotification(@"Hata: Patch Geçersiz (Invalid)!");
                    }
                    lastState = true;
                }
            } 
            else 
            {
                if (lastState) 
                {
                    if (patch.isValid()) 
                    {
                        patch.restore();
                        ShowAlertNotification(@"Streamer Mode: KAPANDI (Restore)");
                    }
                    lastState = false;
                }
            }

            usleep(100000); // 100ms
        }
    } 
    catch (...) {
        ShowAlertNotification(@"Kritik Hata: Try-Catch Yakaladı!");
    }

    return NULL; 
}

void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}
