#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <clientprefs>
#pragma newdecls required
#pragma semicolon 1

Handle g_hGDPRCookie;
Handle g_iTimer[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "SimpleGDPRCompliance",
	author = "Sarrus",
	description = "A simple plugin to comply to the GDPR",
	version = "1.0",
	url = "https://github.com/Sarrus1/"
};
 
public void OnPluginStart()
{
	LoadTranslations("SimpleGDPRCompliance.phrases");
	g_hGDPRCookie = RegClientCookie("GDPRCookie", "Cookie that remembers the clients GDPR preferences.", CookieAccess_Protected);
}
 


public Action CmdScout(int client, int args)
{
	if (AreClientCookiesCached(client))
	{
		char sCookieValue[12];
		GetClientCookie(client, g_hGDPRCookie, sCookieValue, sizeof(sCookieValue));
		int cookieValue = StringToInt(sCookieValue);
		if (cookieValue == 0)
		{
			cookieValue = 1;
			PrintToChat(client, "You are now using the Scout.");
			PrintCenterText(client, "HS ONLY ON");
		}
		else
		{
			cookieValue = 0;
			PrintToChat(client, "You are now using the AWP.");
		}
		IntToString(cookieValue, sCookieValue, sizeof(sCookieValue));
		SetClientCookie(client, g_hGDPRCookie, sCookieValue);
	}
	return Plugin_Handled;
}


public void OnClientCookiesCached(int client)
{
	char sCookieValue[12];
	GetClientCookie(client, g_hGDPRCookie, sCookieValue, sizeof(sCookieValue));
	int cookieValue = StringToInt(sCookieValue);
	if (cookieValue == 0)
	{
		delete g_iTimer[client];
		g_iTimer[client] = CreateTimer(3.0, GDPRCallback, client);
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
      else
      {
				SetClientCookie(param1, g_hGDPRCookie, "1");
				KickClient(param1, "You must accept the GDPR rules to play on this server");
      }
    }
    case MenuAction_End:
    {
      delete menu;
    }
  }
  return 0;
}

public Action GDPRCallback(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid); 
	if ( client && IsClientInGame(client) )
	{
		g_iTimer[client] = null;
		GDPRMenu(client);
	}
}

public Action GDPRMenu(int client)
{
	Menu menu = new Menu(MenuHandler, MENU_ACTIONS_ALL);
	char sContent[256];
	Format(sContent, sizeof(sContent), "%T", "Content");
	menu.SetTitle("%T", "Title", LANG_SERVER);
	menu.AddItem("#content", sContent, ITEMDRAW_RAWLINE);
	menu.AddItem("#accept", "Accept");
	menu.AddItem("#refuse", "Refuse");
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
  delete g_iTimer[client];
}