/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Thompson Gun (developed by Daniel Brendel)
	Version: 0.2
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"

bool g_bSelectionStatus = false;
Vector g_vCursorPos;
string g_szToolPath;
SpriteHandle g_hMuzzleFlash;
bool g_bDrawMuzzleFlashOnce = false;
SpriteHandle g_hXHair;

/*
	This function shall be used for global initializations. Return true on success, otherwise false.
	This function gets called after CDG_API_QueryToolInfo().
*/
bool CDG_API_Initialize()
{
	g_hMuzzleFlash = R_LoadSprite(g_szToolPath + "muzzle.png", 1, 256, 256, 1, false);
	g_hXHair = R_LoadSprite(g_szToolPath + "xhair.png", 1, 32, 32, 1, false);

	return true;
}

/*
	Called for processing stuff
*/
void CDG_API_Process()
{
	if (g_bSelectionStatus)
		SetCursorRotation(19.3);
}

/*
	Default drawing can be done here
*/
void CDG_API_Draw()
{
}

/*
	On-Top drawing can be done here
*/
void CDG_API_DrawOnTop()
{
	if (g_bSelectionStatus) {
		if (g_bDrawMuzzleFlashOnce) {
			g_bDrawMuzzleFlashOnce = false;
			
			Vector vDrawingPos = g_vCursorPos;
			vDrawingPos[0] -= 100;
			vDrawingPos[1] -= 145;
			
			R_DrawSprite(g_hMuzzleFlash, vDrawingPos, 0, 179.5, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
		}
		
		if (!HasOpenGameDialog()) {
			R_DrawSprite(g_hXHair, Vector(g_vCursorPos[0] - 128 - 12, g_vCursorPos[1] - 90), 0, 0.0, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
		}
	}
}

/*
	This function is called when this tool is triggered. The screen position is also passed.
	You can spawn scripted entities here.
*/
void CDG_API_Trigger(const Vector& in vAtPos)
{
	g_bDrawMuzzleFlashOnce = true;
	
	CDamageDecal@ obj = CDamageDecal();
	obj.SetDamageSize(Vector(10, 10));
	obj.SetDamageValue(39);
	obj.SetOffspringFlag(true);
	obj.SetDecalSprite("decal_small.png");
	obj.SetRandomRotation(true);
	Ent_SpawnEntity(@obj, Vector(g_vCursorPos[0] - 128, g_vCursorPos[1] - 80));
	
	SoundHandle hSound = S_QuerySound(g_szToolPath + "gunshot.wav");
	S_PlaySound(hSound, 10);
}

/*
	Called for restoring entities that are part of a loaded blueprint
*/
IScriptedEntity@+ CDG_API_OnSpawnRestoreEntity()
{
	return null;
}

/*
	This function is called for any keyboard key event. This is even the case if 
	this tool is not currently selected.
*/
void CDG_API_KeyEvent(int iKey, bool bDown)
{
}

/*
	This function is called for any mouse event. This is even the case if 
	this tool is not currently selected.
*/
void CDG_API_MouseEvent(const Vector &in coords, int iKey, bool bDown)
{
	if (iKey == 0) g_vCursorPos = coords;
}

/*
	Called for tool selection status.
*/
void CDG_API_SelectionStatus(bool bSelectionStatus)
{
	g_bSelectionStatus = bSelectionStatus;
	if (g_bSelectionStatus) {
		SetCursorRotation(179.5);
	}
}

/*
	This function shall be used for any global cleanup
*/
void CDG_API_Release()
{
}

/*
	This function is called for recieving the tool information.  The host version is passed which can be used
	to determine if the tool works for this game version. Tool information must be stored into the info struct.
	The tool path can be used to load objects from. Return true on success, otherwise false.
*/
bool CDG_API_QueryToolInfo(HostVersion hvVersion, ToolInfo &out info, const GameKeys& in gamekeys, const string &in szToolPath)
{
	info.szName = "Thompson";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "gun.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 250;
	info.iCursorHeight = 100;
	info.uiTriggerDelay = 125;
	
	g_szToolPath = szToolPath;

	return true;
}