#include <open.mp>

#define STARTING_CASH (2000)
#define COLOR_WHITE (0xFFFFFFFF)
#define COLOR_ORANGE (0xFF9900FF)

#include "../maps/omar_district.inc"

main()
{
    print("[OmarRP] Gamemode starting.");
}

public OnGameModeInit()
{
    SetGameModeText("Omar RP | Medium RP");
    AddPlayerClass(26, 2495.0, -1687.0, 13.5, 90.0, 0, 0, 0, 0, 0, 0);
    LoadOmarDistrict();
    return 1;
}

public OnPlayerConnect(playerid)
{
    SendClientMessage(playerid, COLOR_ORANGE, "Welcome to Omar RP! /help");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    // Prototype only: money resets on every spawn until accounts are implemented.
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, STARTING_CASH);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/help", true))
    {
        SendClientMessage(playerid, COLOR_WHITE, "/district - Omar District information");
        return 1;
    }
    if (!strcmp(cmdtext, "/district", true))
    {
        SendClientMessage(playerid, COLOR_ORANGE, "Omar District: development area near Ganton, Los Santos.");
        return 1;
    }
    return 0;
}
