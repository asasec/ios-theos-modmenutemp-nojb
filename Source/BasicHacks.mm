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

uintptr_t GetImageSlideAddress(const char *imageName) {
    uint32_t imageCount = _dyld_image_count();
    for (uint32_t i = 0; i < imageCount; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, imageName)) {
            // Doğru bellek header adresini döndürüyoruz
            return (uintptr_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

void* BasicHacks::HacksThread(void* arg)
{
    ShowAlertNotification(@"HacksThread Başlatıldı!");

    // UnityFramework belleğe yüklenene kadar güvenle bekle
    uintptr_t baseAddr = 0;
    while (baseAddr == 0 && KTempVars.running) {
        baseAddr = GetImageSlideAddress("UnityFramework");
        if (baseAddr == 0) {
            usleep(500000); // 0.5 saniye bekle
        }
    }

    ShowAlertNotification(@"UnityFramework Adresi Bulundu!");

    uint8_t patchBytes[] = {0xE0, 0x47, 0x88, 0x52, 0xE0, 0x01, 0xA0, 0x72, 0xC0, 0x03, 0x5F, 0xD6};
    void* targetAddress = (void*)(baseAddr + 0x210EC54);

    bool lastState = false;

    while(KTempVars.running)
    {   
        if (KTempVars.AimHack) 
        {
            if (!lastState) 
            {
                ShowAlertNotification(@"Aim Hack Açıldı Tetiklendi!");
                
                bool success = THPatchMem::PatchMemory(targetAddress, patchBytes, sizeof(patchBytes));
                if (success) {
                    ShowAlertNotification(@"Patch Başarıyla Uygulandı!");
                } else {
                    ShowAlertNotification(@"Patch Başarısız!");
                }
                
                lastState = true;
            }
        } 
        else 
        {
            if (lastState) 
            {
                ShowAlertNotification(@"Aim Hack Kapandı!");
                lastState = false;
            }
        }

        usleep(200000);
    }

    return NULL; 
}

void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}
