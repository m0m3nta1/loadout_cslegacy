#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

int g_CT_Pistol[MAXPLAYERS+1];
int g_CT_Rifle[MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "Loadout Menu For CS:Legacy",
    author = "M0m3n7a1",
    description = "USP/P2000 + M4A4/M4A1-S loadout",
    version = "2.0"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_loadout", Command_Loadout);
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_SpawnPost, OnSpawnPost);
    SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquip);
}

public void OnSpawnPost(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return;

    if (GetClientTeam(client) != 3)
        return;

    CreateTimer(0.2, Timer_ApplyPistol, client);
}

public Action Timer_ApplyPistol(Handle timer, any client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;

    int weapon = GetPlayerWeaponSlot(client, 1);

    if (weapon != -1)
    {
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");
    }

    if (g_CT_Pistol[client] == 0)
        GivePlayerItem(client, "weapon_usp_silencer");
    else
        GivePlayerItem(client, "weapon_hkp2000");

    return Plugin_Stop;
}

public void OnWeaponEquip(int client, int weapon)
{
    if (!IsClientInGame(client))
        return;

    if (GetClientTeam(client) != 3)
        return;

    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));

    if (StrEqual(classname, "weapon_m4a1"))
    {
        if (g_CT_Rifle[client] == 0) // M4A1-S selected
        {
            RemovePlayerItem(client, weapon);
            AcceptEntityInput(weapon, "Kill");

            GivePlayerItem(client, "weapon_m4a1_silencer");
        }
    }
}

public Action Command_Loadout(int client, int args)
{
    Menu menu = new Menu(Menu_Loadout);
    menu.SetTitle("CT Loadout");

    menu.AddItem("pistol", "Choose CT Pistol");
    menu.AddItem("rifle", "Choose CT Rifle");

    menu.Display(client, 20);

    return Plugin_Handled;
}

public int Menu_Loadout(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        char info[32];
        menu.GetItem(item, info, sizeof(info));

        if (StrEqual(info, "pistol"))
            ShowPistolMenu(client);

        if (StrEqual(info, "rifle"))
            ShowRifleMenu(client);
    }

    return 0;
}

void ShowPistolMenu(int client)
{
    Menu menu = new Menu(Menu_Pistol);

    menu.SetTitle("Choose CT Pistol");

    menu.AddItem("usp", "USP-S");
    menu.AddItem("p2000", "P2000");

    menu.Display(client, 20);
}

public int Menu_Pistol(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        g_CT_Pistol[client] = item;

        PrintToChat(client, "[Loadout] CT pistol saved.");
    }

    return 0;
}

void ShowRifleMenu(int client)
{
    Menu menu = new Menu(Menu_Rifle);

    menu.SetTitle("Choose CT Rifle");

    menu.AddItem("m4a1s", "M4A1-S");
    menu.AddItem("m4a4", "M4A4");

    menu.Display(client, 20);
}

public int Menu_Rifle(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select)
    {
        g_CT_Rifle[client] = item;

        PrintToChat(client, "[Loadout] CT rifle saved.");
    }

    return 0;
}