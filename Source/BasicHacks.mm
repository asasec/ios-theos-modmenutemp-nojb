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

// Belirli bir kütüphanenin (örneğin UnityFramework) bellekteki başlangıç adresini (slide dahil) bulan yardımcı fonksiyon
uintptr_t GetImageSlideAddress(const char *imageName) {
    uint32_t imageCount = _dyld_image_count();
    for (uint32_t i = 0; i < imageCount; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, imageName)) {
            return _dyld_get_image_vmaddr_slide(i) + 
                   // Alternatif olarak slide ile beraber header adresini döndürüyoruz
                   (uintptr_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

void* BasicHacks::HacksThread(void* arg)
{
    bool lastState = false;
    
    try {
        uint8_t patchBytes[] = {0xE0, 0x47, 0x88, 0x52, 0xE0, 0x01, 0xA0, 0x72, 0xC0, 0x03, 0x5F, 0xD6};
        
        // UnityFramework adresini güvenli bir şekilde hesaplıyoruz
        uintptr_t baseAddr = GetImageSlideAddress("UnityFramework");
        void* targetAddress = (void*)(baseAddr + 0x210EC54);

        while(KTempVars.running)
        {   
            if (KTempVars.StreamerMode) 
            {
                if (!lastState) 
                {
                    if (baseAddr == 0) {
                        ShowAlertNotification(@"Hata: UnityFramework Bulunamadı!");
                    } else {
                        bool success = THPatchMem::PatchMemory(targetAddress, patchBytes, sizeof(patchBytes));
                        if (success) {
                            ShowAlertNotification(@"Streamer Mode: AÇILDI (Patch Başarılı)");
                        } else {
                            ShowAlertNotification(@"Hata: Patch Başarısız!");
                        }
                    }
                    lastState = true;
                }
            } 
            else 
            {
                if (lastState) 
                {
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
