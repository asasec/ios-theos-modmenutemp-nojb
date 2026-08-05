#include "../MenuLoad/Includes.h"


void* BasicHacks::HacksThread(void* arg)
{
    // UnityFramework üzerinden offset ve hex patch tanımı
    MemoryPatch patch = MemoryPatch::createWithHex("UnityFramework", 0x210EC54, "E0 47 88 52 E0 01 A0 72 C0 03 5F D6");

    bool lastState = false; // Tuşun durumunu takip etmek için

    while(KTempVars.running)
    {   
        // Streamer Mode aktif edildiyse patch uygula, kapatıldıysa eski haline döndür
        if (KTempVars.StreamerMode) 
        {
            if (!lastState && patch.isValid()) 
            {
                patch.modify(); // Hex patch'i aktif et
                lastState = true;
            }
        } 
        else 
        {
            if (lastState && patch.isValid()) 
            {
                patch.restore(); // Orijinal haline geri döndür
                lastState = false;
            }
        }

        usleep(100000); // İşlemciyi yormamak için 100ms bekleme
    } 

    return NULL; 
}

void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}
