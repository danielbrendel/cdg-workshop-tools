/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Potato Masher (developed by Daniel Brendel)
	Version: 0.2
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"

bool g_bSelectionStatus = false;
Vector g_vCursorPos;
string g_szToolPath;

class CFlame : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_oLifeTime;
	Timer m_oFlames;
	SpriteHandle m_hSprite;
	int m_iCurrentFrame;
	
	CFlame()
    {
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_vecPos[1] += 22;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "flames.png", 7, 48, 48, 7, false);
		this.m_oLifeTime.SetDelay(10000);
		this.m_oLifeTime.Reset();
		this.m_oLifeTime.SetActive(true);
		this.m_oFlames.SetDelay(10);
		this.m_oFlames.Reset();
		this.m_oFlames.SetActive(true);
		SoundHandle hBurningSound = S_QuerySound("burn.wav");
		S_PlaySound(hBurningSound, 8);
		CDecalSprite@ obj = CDecalSprite();
		Ent_SpawnEntity(@obj, this.m_vecPos);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(48, 48));
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
		this.m_oLifeTime.Update();
		
		this.m_oFlames.Update();
		if (this.m_oFlames.IsElapsed()) {
			this.m_oFlames.Reset();
			this.m_iCurrentFrame++;
			if (this.m_iCurrentFrame >= 7)
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
		return this.m_oLifeTime.IsElapsed();
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
		return 3;
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
		return this.m_vecPos;
	}
	
	//This method is used to set the movement destination position
	void MoveTo(const Vector& in vec)
	{
	}
}

class CMainExplosion : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_oExplosion;
	int m_iFrameCount;
	SpriteHandle m_hSprite;
	SoundHandle m_hSound;
	
	CMainExplosion()
    {
		this.m_iFrameCount = 0;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = Vector(vec[0] - 90, vec[1] - 90);
		this.m_hSprite = R_LoadSprite(g_szToolPath + "explosion.png", 8, 256, 256, 8, false);
		this.m_oExplosion.SetDelay(1);
		this.m_oExplosion.Reset();
		this.m_oExplosion.SetActive(true);
		this.m_hSound = S_QuerySound(g_szToolPath + "explosion.wav");
		S_PlaySound(this.m_hSound, 10);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(256, 256));
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
		this.m_oExplosion.Update();
		if (this.m_oExplosion.IsElapsed()) {
			this.m_oExplosion.Reset();
			this.m_iFrameCount++;
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw everything on top here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, this.m_iFrameCount, 0.0, Vector(-1, -1), 2.0, 2.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_iFrameCount >= 64;
	}
	
	//Indicate whether this entity is damageable. Damageable entities can collide with other
	//entities (even with entities from other tools) and recieve and strike damage. 
	//0 = not damageable, 1 = damage all, 2 = not damaging entities with same name
	DamageType IsDamageable()
	{
		return DAMAGEABLE_NOTSQUAD;
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
		return 4;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "Explosion";
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
		return this.m_vecPos;
	}
	
	//This method is used to set the movement destination position
	void MoveTo(const Vector& in vec)
	{
	}
}

class CPotatoMasherEntity : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_tmrLifeTime;
	Timer m_tmrMovement;
	SpriteHandle m_hSprite;
	SoundHandle m_hFlames;
	float m_fRotation;
	float m_fDisplayRot;
	float m_fSpeed;
	
	CPotatoMasherEntity()
    {
		this.m_fSpeed = 10.0;
    }
	
	void Move(void)
	{
		//Update position according to speed
		this.m_vecPos[0] += int(sin(this.m_fRotation) * this.m_fSpeed);
		this.m_vecPos[1] -= int(cos(this.m_fRotation) * this.m_fSpeed);
		
		this.m_fDisplayRot += 0.1;
	}
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_vecPos[0] += 20;
		this.m_vecPos[1] -= 45;
		this.m_fRotation = -1.0 + ((Util_Random(0, 2) == 1) ? -0.1 : 0.1);
		this.m_fDisplayRot = this.m_fRotation;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "potatomasher.png", 1, 28, 66, 1, false);
		this.m_hFlames = S_QuerySound(g_szToolPath + "flames.wav");
		this.m_tmrLifeTime.SetDelay(1000 + Util_Random(0, 100));
		this.m_tmrLifeTime.Reset();
		this.m_tmrLifeTime.SetActive(true);
		this.m_tmrMovement.SetDelay(10);
		this.m_tmrMovement.Reset();
		this.m_tmrMovement.SetActive(true);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(32, 32));
		this.m_oModel.Alloc();
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		CMainExplosion @mex = CMainExplosion();
		Ent_SpawnEntity(@mex, this.m_vecPos);
		
		S_PlaySound(this.m_hFlames, 10);
		
		CDamageDecal @mdc = CDamageDecal();
		mdc.SetDamageSize(Vector(64, 64));
		mdc.SetDecalSprite("decal_medium.png");
		mdc.SetOffspringFlag(true);
		mdc.SetDamageValue(50);
		Ent_SpawnEntity(@mdc, this.m_vecPos);
	
		for (int i = 0; i < 6 + Util_Random(1, 5); i++) {
			Vector vTarget = Vector(this.m_vecPos[0] + (Util_Random(0, 200) - 100), this.m_vecPos[1] + (Util_Random(0, 200) - 100));
			vTarget[1] -= 15;
			
			CFlame @flame = @CFlame();
			Ent_SpawnEntity(@flame, vTarget);
		}
	}
	
	//Process entity stuff
	void OnProcess()
	{
		//Process life time timer
		this.m_tmrLifeTime.Update();
		
		//Process movement timer
		if (this.m_tmrMovement.IsActive()) {
			this.m_tmrMovement.Update();
			if (this.m_tmrMovement.IsElapsed()) {
				this.m_tmrMovement.Reset();
				this.Move();
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw everything on top here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, this.m_fDisplayRot, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_tmrLifeTime.IsElapsed();
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
		return 10;
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
		return this.m_vecPos;
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
	if (g_bSelectionStatus)
		SetCursorRotation(0.5);
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
	CPotatoMasherEntity@ obj = CPotatoMasherEntity();
	Ent_SpawnEntity(@obj, Vector(vAtPos[0] - 10, vAtPos[1] + 40));
	
	SoundHandle hSound = S_QuerySound(g_szToolPath + "throw.wav");
	S_PlaySound(hSound, 10);
}

/*
	Called for restoring entities that are part of a loaded blueprint
*/
IScriptedEntity@+ CDG_API_OnSpawnRestoreEntity()
{
	CPotatoMasherEntity @obj = CPotatoMasherEntity();
	Ent_SpawnEntity(@obj, Vector(0, 0));

	return @obj;
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
		SetCursorRotation(0.5);
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
	info.szName = "Potato Masher";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "potatomasher.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 28;
	info.iCursorHeight = 66;
	info.uiTriggerDelay = 250;
	
	g_szToolPath = szToolPath;

	return true;
}