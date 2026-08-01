#include "../MenuLoad/Includes.h"


void* BasicHacks::HacksThread(void* arg)
{

    while(KTempVars.running)
    {   
        usleep(100);
    } 

    return NULL; 
}

void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}