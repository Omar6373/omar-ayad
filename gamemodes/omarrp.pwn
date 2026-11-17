#include <open.mp>
#include <a_mysql>
#include <bcrypt>

#define COLOR_WHITE (0xFFFFFFFF)
#define COLOR_ORANGE (0xFF9900FF)
#define COLOR_RED (0xFF4444FF)
#define DIALOG_REGISTER (1000)
#define DIALOG_LOGIN (1001)
#define STARTING_CASH (2000)
#define BCRYPT_COST (12)

#include "../maps/omar_district.inc"

new MySQL:g_SQL = MYSQL_INVALID_HANDLE;
new bool:g_Authed[MAX_PLAYERS];
new g_AccountId[MAX_PLAYERS];
new g_Cash[MAX_PLAYERS];
new g_LoginAttempts[MAX_PLAYERS];
new g_Session[MAX_PLAYERS];

forward AccountLookup(playerid, session);
forward AccountRegistered(playerid, session);
forward AccountPasswordHashed(playerid, session);
forward AccountPasswordVerified(playerid, session);
forward AccountSaved(playerid, session);

main() { print("[OmarRP] Server starting"); }

public OnGameModeInit()
{
    SetGameModeText("Omar RP | Medium RP");
    AddPlayerClass(26, 2495.0, -1687.0, 13.5, 90.0, 0, 0, 0, 0, 0, 0);
    LoadOmarDistrict();
    // Change credentials in private deployment config, NEVER in a public repo.
    // A local database is assumed; deployment must provide actual credentials.
    g_SQL = mysql_connect("127.0.0.1", "omarrp", "CHANGE_ME", "omarrp");
    if (mysql_errno(g_SQL) != 0)
    {
        print("[OmarRP] Database connection failed; accounts disabled.");
    }
    return 1;
}

public OnGameModeExit()
{
    if (g_SQL != MYSQL_INVALID_HANDLE) mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid)
{
    g_Session[playerid]++;
    g_Authed[playerid] = false;
    g_AccountId[playerid] = 0;
    g_Cash[playerid] = 0;
    g_LoginAttempts[playerid] = 0;
    TogglePlayerControllable(playerid, false);
    if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
    {
        SendClientMessage(playerid, COLOR_RED, "Accounts unavailable. Try later.");
        return 1;
    }
    new name[MAX_PLAYER_NAME + 1], query[160];
    GetPlayerName(playerid, name, sizeof name);
    mysql_format(g_SQL, query, sizeof query,
        "SELECT id, password_hash, cash FROM accounts WHERE username='%e' LIMIT 1", name);
    mysql_tquery(g_SQL, query, "AccountLookup", "ii", playerid, g_Session[playerid]);
    return 1;
}

public AccountLookup(playerid, session)
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    if (cache_num_rows())
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Omar RP - Login", "Enter your account password:", "Login", "Exit");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Omar RP - Register", "Choose a password (8-64 characters):", "Register", "Exit");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused listitem
    if (dialogid != DIALOG_LOGIN && dialogid != DIALOG_REGISTER) return 0;
    if (!response) { Kick(playerid); return 1; }
    new len = strlen(inputtext);
    if (len < 8 || len > 64)
    {
        SendClientMessage(playerid, COLOR_RED, "Password must be 8-64 characters.");
        OnPlayerConnect(playerid);
        return 1;
    }
    if (dialogid == DIALOG_REGISTER)
    {
        bcrypt_hash(inputtext, BCRYPT_COST, "AccountPasswordHashed", "ii", playerid, g_Session[playerid]);
    }
    else
    {
        new name[MAX_PLAYER_NAME + 1], query[160];
        GetPlayerName(playerid, name, sizeof name);
        mysql_format(g_SQL, query, sizeof query,
            "SELECT id, password_hash, cash FROM accounts WHERE username='%e' LIMIT 1", name);
        mysql_tquery(g_SQL, query, "AccountPasswordQuery", "iis", playerid, g_Session[playerid], inputtext);
    }
    return 1;
}

forward AccountPasswordQuery(playerid, session, password[]);
public AccountPasswordQuery(playerid, session, password[])
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    if (!cache_num_rows()) { Kick(playerid); return 1; }
    new hash[255];
    cache_get_value_name(0, "password_hash", hash, sizeof hash);
    bcrypt_verify(playerid, password, hash, "AccountPasswordVerified", "i", session);
    return 1;
}

public AccountPasswordVerified(playerid, session)
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    if (!bcrypt_is_equal())
    {
        g_LoginAttempts[playerid]++;
        if (g_LoginAttempts[playerid] >= 3) { Kick(playerid); return 1; }
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Omar RP - Login", "Incorrect password. Try again:", "Login", "Exit");
        return 1;
    }
    new name[MAX_PLAYER_NAME + 1], query[160];
    GetPlayerName(playerid, name, sizeof name);
    mysql_format(g_SQL, query, sizeof query,
        "SELECT id, cash FROM accounts WHERE username='%e' LIMIT 1", name);
    mysql_tquery(g_SQL, query, "AccountLoaded", "ii", playerid, session);
    return 1;
}

forward AccountLoaded(playerid, session);
public AccountLoaded(playerid, session)
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    if (!cache_num_rows()) { Kick(playerid); return 1; }
    cache_get_value_name_int(0, "id", g_AccountId[playerid]);
    cache_get_value_name_int(0, "cash", g_Cash[playerid]);
    g_Authed[playerid] = true;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, g_Cash[playerid]);
    TogglePlayerControllable(playerid, true);
    SendClientMessage(playerid, COLOR_ORANGE, "Login successful. Welcome to Omar RP.");
    return 1;
}

public AccountPasswordHashed(playerid, session)
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    new hash[255], name[MAX_PLAYER_NAME + 1], query[700];
    bcrypt_get_hash(hash, sizeof hash);
    GetPlayerName(playerid, name, sizeof name);
    mysql_format(g_SQL, query, sizeof query,
        "INSERT IGNORE INTO accounts (username,password_hash,cash) VALUES ('%e','%e',%d)",
        name, hash, STARTING_CASH);
    mysql_tquery(g_SQL, query, "AccountRegistered", "ii", playerid, session);
    return 1;
}

public AccountRegistered(playerid, session)
{
    if (!IsPlayerConnected(playerid) || g_Session[playerid] != session) return 1;
    if (cache_affected_rows() != 1)
    {
        SendClientMessage(playerid, COLOR_RED, "Account exists. Reconnect and log in.");
        Kick(playerid);
        return 1;
    }
    new name[MAX_PLAYER_NAME + 1], query[160];
    GetPlayerName(playerid, name, sizeof name);
    mysql_format(g_SQL, query, sizeof query,
        "SELECT id,cash FROM accounts WHERE username='%e' LIMIT 1", name);
    mysql_tquery(g_SQL, query, "AccountLoaded", "ii", playerid, session);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!g_Authed[playerid]) { TogglePlayerControllable(playerid, false); return 1; }
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, g_Cash[playerid]);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    g_Session[playerid]++;
    g_Authed[playerid] = false;
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!g_Authed[playerid]) return 1;
    if (!strcmp(cmdtext, "/help", true))
    {
        SendClientMessage(playerid, COLOR_WHITE, "/district /balance");
        return 1;
    }
    if (!strcmp(cmdtext, "/district", true))
    {
        SendClientMessage(playerid, COLOR_ORANGE, "Omar District: near Ganton, Los Santos.");
        return 1;
    }
    if (!strcmp(cmdtext, "/balance", true))
    {
        new msg[80];
        format(msg, sizeof msg, "Your cash: $%d", g_Cash[playerid]);
        SendClientMessage(playerid, COLOR_WHITE, msg);
        return 1;
    }
    return 0;
}
