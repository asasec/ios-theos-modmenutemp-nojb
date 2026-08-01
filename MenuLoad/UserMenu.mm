#include "Includes.h"


void UserMenu::DrawMenu()
{
    ImVec2 WindowSize = ImVec2(320, 260);
    ImGui::SetNextWindowSize(WindowSize, ImGuiCond_Once);

    ImVec2 WindowPosition = ImVec2((SCREEN_WIDTH - WindowSize.x) / 2, (SCREEN_HEIGHT - WindowSize.y) / 2);
    ImGui::SetNextWindowPos(WindowPosition, ImGuiCond_Once);

    ImGuiWindowFlags WindowFlags = KTempVars.MoveMenu ? ImGuiWindowFlags_NoCollapse : ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;

    if (ImGui::Begin("KomaruTemp", NULL, WindowFlags))
    {
        ImGuiWindow* CurrentWindow = ImGui::GetCurrentWindow();
        KTempVars.MenuSize   = CurrentWindow->Size;
        KTempVars.MenuOrigin = CurrentWindow->Pos;

        ImGui::Checkbox("Master Switch", &KTempVars.running);
        
        if (KTempVars.running)
        {
            /*
            if(ImGui::CollapsingHeader("Aim")) 
            {

            }   

            if(ImGui::CollapsingHeader("ESP")) 
            {

            }   
            if(ImGui::CollapsingHeader("Misc")) 
            {

            }
            if(ImGui::CollapsingHeader("Customize")) 
            {

            }
            */
            if(ImGui::CollapsingHeader("Development")) 
            {
                ImGui::Checkbox("DBG Console", &KTempVars.console);
            }
        }

        ImGui::Spacing();
        ImGui::Checkbox("Move Menu", &KTempVars.MoveMenu);
        ImGui::SameLine();
        ImGui::Checkbox("Streamer Mode", &KTempVars.StreamerMode);
        
        ImGui::End();
    }
}

void UserMenu::RenderingMenu()
{

    ImGuiWindowFlags WFlags = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoInputs;
    
    ImGui::Begin("RenderMenu", nullptr, WFlags);

    ImDrawList* drawList = ImGui::GetBackgroundDrawList();

    if (KTempVars.ESPEnabled) {
        // DrawESP();
    }

    ImGui::End();
}


static char consoleBuffer[4096] = "";

void UserMenu::ShowOutputTextbox() 
{
    ImGui::InputTextMultiline("Output", consoleBuffer, sizeof(consoleBuffer), 
                               ImVec2(ImGui::GetWindowContentRegionMax().x - 10, ImGui::GetWindowContentRegionMax().y - 30), 
                               ImGuiInputTextFlags_ReadOnly);
}


void UserMenu::AppendToOutput(const std::string& text) 
{
    strncat(consoleBuffer, (text + "\n").c_str(), sizeof(consoleBuffer) - strlen(consoleBuffer) - 1);
}


void UserMenu::ConsoleMenu()
{
    ImGuiWindowFlags WFlags = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;;
    ImVec2 WS = ImVec2(350, 300);
    ImGui::SetNextWindowSize(WS, ImGuiCond_Once);

    ImVec2 WP = ImVec2((SCREEN_WIDTH - WS.x) / 2, (SCREEN_HEIGHT - WS.y) / 2);
    ImGui::SetNextWindowPos(WP, ImGuiCond_Once);

    if (KTempVars.console)
    {
        ImGui::Begin("KomaruConsole", nullptr, WFlags);

        ImGuiWindow* ConsoleWindow = ImGui::GetCurrentWindow();
        KTempVars.ConsoleSize   = ConsoleWindow->Size;
        KTempVars.ConsoleOrigin = ConsoleWindow->Pos;

        ShowOutputTextbox();

        if(ImGui::Button("Test")) 
        {
            AppendToOutput("Test!");
        }

        ImGui::SameLine();

        if(ImGui::Button("Clear")) 
        {
            consoleBuffer[0] = '\0';
        }

        ImGui::SameLine();
        
        if(ImGui::Button("Close")) 
        {
            KTempVars.console = false;
        }

        ImGui::End();
    }
}


void UserMenu::Initialize()
{
    if (!KTempVars.console) DrawMenu();
    RenderingMenu();
    ConsoleMenu();
}
