/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Firewall (developed by Daniel Brendel)
	Version: 0.2
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"

string g_szToolPath;

class CFlame : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	Timer m_oMovement;
	Timer m_oFlames;
	SpriteHandle m_hSprite;
	int m_iCurrentFrame;
	int m_iDecalCount;
	
	CFlame()
    {
		this.m_vecSize = Vector(128, 128);
		this.m_iDecalCount = 10;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = Vector(vec[0], Util_Random(0, 100) - 150);
		this.m_hSprite = R_LoadSprite(g_szToolPath + "flames.png", 64, this.m_vecSize[0], this.m_vecSize[1], 8, false);
		this.m_oMovement.SetDelay(10);
		this.m_oMovement.Reset();
		this.m_oMovement.SetActive(true);
		this.m_oFlames.SetDelay(10);
		this.m_oFlames.Reset();
		this.m_oFlames.SetActive(true);
		SoundHandle hBurningSound = S_QuerySound("burn.wav");
		S_PlaySound(hBurningSound, 8);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), this.m_vecSize);
		this.m_oModel.Alloc();
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oMovement.Update();
		if (this.m_oMovement.IsElapsed()) {
			this.m_oMovement.Reset();
			
			this.m_vecPos[1] += 5;
			
			this.m_iDecalCount++;
			if (this.m_iDecalCount >= 10) {
				this.m_iDecalCount = 0;
				
				CDecalSprite @dcl = CDecalSprite();
				dcl.SetSprite("decal_medium.png");
				dcl.SetSize(this.m_vecSize);
				dcl.SetScale(2.5f);
				Ent_SpawnEntity(@dcl, Vector(this.m_vecPos[0] + 80, this.m_vecPos[1] + 90));
			}
		}

		this.m_oFlames.Update();
		if (this.m_oFlames.IsElapsed()) {
			this.m_oFlames.Reset();
			this.m_iCurrentFrame++;
			if (this.m_iCurrentFrame >= 64)
				this.m_iCurrentFrame = 0;
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, this.m_iCurrentFrame, 0.0, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_vecPos[1] >= Wnd_GetWindowCenterY() * 2 + 50;
	}
	
	//Indicate whether this entity is damageable. Damageable entities can collide with other
	//entities (even with entities from other tools) and recieve and strike damage. 
	//0 = not damageable, 1 = damage all, 2 = not damaging entities with same name
	DamageType IsDamageable()
	{
		return DAMAGEABLE_ALL;
	}
	
	//Called when the entity recieves damage
	void OnDamage(DamageValue dv)
	{
	}
	
	//Called for recieving the model data for this entity. This is only used for
	//damageable entities. 
	Model& GetModel()
	{
		return this.m_oModel;
	}
	
	//Called for recieving the current position. This is useful if the entity shall move.
	Vector& GetPosition()
	{
		return this.m_vecPos;
	}

	//Can be used to overwrite the current position with the given position
	void SetPosition(const Vector& in vec)
	{
	}
	
	//Return the rotation. This is actually not used by the host application, but might be useful to other entities
	float GetRotation()
	{
		return 0.0;
	}

	//Can be used to overwrite the current rotation with the given rotation
	void SetRotation(float fRotation)
	{
	}
	
	//Called for querying the damage value for this entity
	DamageValue GetDamageValue()
	{
		return 100;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "";
	}

	//Return a data string that represents the value of the info identifier string
	string GetExtraInfo(const string &in info)
	{
		return "";
	}
	
	//Set data information identified by the info expression
	void SetExtraInfo(const string &in info, const string &in data)
	{
	}
	
	//Indicate if this entity is movable
	bool IsMovable()
	{
		return false;
	}
	
	//This vector is used for drawing the selection box
	Vector& GetSelectionSize()
	{
		return this.m_vecSize;
	}
	
	//This method is used to set the movement destination position
	void MoveTo(const Vector& in vec)
	{
	}
}

/*
	This function shall be used for global initializations. Return true on success, otherwise false.
	This function gets called after CDG_API_QueryToolInfo().
*/
bool CDG_API_Initialize()
{
	return true;
}

/*
	Called for processing stuff
*/
void CDG_API_Process()
{
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
}

/*
	This function is called when this tool is triggered. The screen position is also passed.
	You can spawn scripted entities here.
*/
void CDG_API_Trigger(const Vector& in vAtPos)
{
	const int STEP_DIVISOR = 128;
	const int MAX_COUNT = (Wnd_GetWindowCenterX() * 2) / STEP_DIVISOR;
	
	for (int i = 0; i < MAX_COUNT; i++) {
		CFlame@ obj = CFlame();
		Ent_SpawnEntity(@obj, Vector(i * STEP_DIVISOR, 0));
	}
	
	SoundHandle hFire = S_QuerySound(g_szToolPath + "fire.wav");
	S_PlaySound(hFire, 8);
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
}

/*
	Called for tool selection status.
*/
void CDG_API_SelectionStatus(bool bSelectionStatus)
{
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
	info.szName = "Firewall";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.2";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "cursor.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 64;
	info.iCursorHeight = 64;
	info.uiTriggerDelay = 250;
	
	g_szToolPath = szToolPath;

	return true;
}