#include <sourcemod>
#include <clientprefs>
#pragma newdecls required
#pragma semicolon 1

Handle g_hGDPRCookie;

public Plugin myinfo =
{
	name = "SimpleGDPRCompliance",
	author = "Sarrus",
	description = "A simple plugin to comply to the GDPR",
	version = "1.1",
	url = "https://github.com/Sarrus1/"
};
 

public void OnPluginStart()
{
	LoadTranslations("SimpleGDPRCompliance.phrases.txt");
	g_hGDPRCookie = RegClientCookie("GDPRCookie", "Remember client GDPR preferences.", CookieAccess_Protected);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("ClientGDPRStatus", Native_ClientGDPRStatus);
	return APLRes_Success;
}


public bool GDPRStatus(int client)
{
	char sCookieValue[12];
	GetClientCookie(client, g_hGDPRCookie, sCookieValue, sizeof(sCookieValue));
	int cookieValue = StringToInt(sCookieValue);
	if (cookieValue != 1)
		return false;
	return true;
}


public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!GDPRStatus(client))
	{
		GDPRMenu(client, 0);
	}
}


public int MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
  switch(action)
  {
    case MenuAction_Select:
    {
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "#accept"))
		{
			SetClientCookie(param1, g_hGDPRCookie, "1");
		}
		else if(StrEqual(info, "#refuse"))
		{
			SetClientCookie(param1, g_hGDPRCookie, "0");
			KickClient(param1, "%t", "KickMessage");
		}
		delete menu;
    }
  }
  return 0;
}


public Action GDPRMenu(int client, int args)
{
	Menu menu = new Menu(MenuHandler, MenuAction_Select);
	menu.SetTitle("%t", "Content");
	char Accept[128], Refuse[128];
	Format(Accept, sizeof Accept, "%t", "Accept");
	Format(Refuse, sizeof Refuse, "%t", "Refuse");
	menu.AddItem("#accept", Accept);
	menu.AddItem("#refuse", Refuse);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public int Native_ClientGDPRStatus(Handle plugin, int numParams)
{
	int client = view_as<bool>(GetNativeCell(1));
	if (client < 1 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	if (!IsClientConnected(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", client);
	return GDPRStatus(client);
}
