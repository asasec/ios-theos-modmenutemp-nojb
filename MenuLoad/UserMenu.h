#pragma once
#include <string>

class UserMenu {
public:
    UserMenu(const UserMenu&) = delete;

    static UserMenu& GetInstance() {
        static UserMenu Instance;
        return Instance;
    }

    void DrawMenu();
    void RenderingMenu();
    void Initialize();
    void ShowOutputTextbox();
    void AppendToOutput(const std::string& text);
    void ConsoleMenu();
private:
    UserMenu() { }
};

static UserMenu& Menu = UserMenu::GetInstance();