#pragma once

class BasicHacks {
public:
    BasicHacks(const BasicHacks&) = delete;

    static BasicHacks& GetInstance() {
        static BasicHacks Instance;
        return Instance;
    }

    static void* HacksThread(void* arg);

    void Initialize();
    void UpdateCheats();

private:
    BasicHacks() = default;
};

static BasicHacks& BasicCheats = BasicHacks::GetInstance();
