#include "../MenuLoad/Includes.h"
#include "../utils/libtitanox/mempatch/THPatchMem.h"
#import <UIKit/UIKit.h>

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
    bool lastState = false;
    
    try {
        // Hex değerlerini byte dizisine çeviriyoruz
        uint8_t patchBytes[] = {0xE0, 0x47, 0x88, 0x52, 0xE0, 0x01, 0xA0, 0x72, 0xC0, 0x03, 0x5F, 0xD6};
        
        // UnityFramework temel adresini bulmak veya offset eklemek için mach-o yapıları kullanılır
        // Doğrudan adres üzerinden patch atmak için kütüphane adresini alıyoruz:
        void* targetAddress = (void*)(stringGetAddress("UnityFramework") + 0x210EC54);

        while(KTempVars.running)
        {   
            if (KTempVars.StreamerMode) 
            {
                if (!lastState) 
                {
                    bool success = THPatchMem::PatchMemory(targetAddress, patchBytes, sizeof(patchBytes));
                    if (success) {
                        ShowAlertNotification(@"Streamer Mode: AÇILDI (Patch Başarılı)");
                    } else {
                        ShowAlertNotification(@"Hata: Patch Başarısız!");
                    }
                    lastState = true;
                }
            } 
            else 
            {
                if (lastState) 
                {
                    // Not: Eğer orijinal baytları saklamadıysan kapatma (restore) işleminde orijinal hex'leri bilmen gerekir.
                    lastState = false;
                    ShowAlertNotification(@"Streamer Mode: KAPANDI");
                }
            }

            usleep(100000);
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
