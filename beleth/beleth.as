/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Beleth (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"
#include "${COMMON}/explosion/explosion.as"

const int C_FLAME_COUNT = 150;
const int C_SKULL_CHANGE = 190;

string g_szToolPath;
bool g_bSpawned = false;

class CDamageAll : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_oLifeTime;
	SpriteHandle m_hSprite;
	
	CDamageAll()
    {
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = Vector(0, 0);
		this.m_hSprite = R_LoadSprite(g_szToolPath + "decal.png", 1, 64, 64, 1, false);
		this.m_oLifeTime.SetDelay(3000);
		this.m_oLifeTime.Reset();
		this.m_oLifeTime.SetActive(true);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(Wnd_GetWindowCenterX() * 2, Wnd_GetWindowCenterY() * 2));
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
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
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
		return 255;
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
		CDecalSprite@ obj = CDecalSprite();
		Ent_SpawnEntity(@obj, Vector(this.m_vecPos[0] - 10, this.m_vecPos[1] + 10));
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
		return 50;
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

class CPentagram : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	SpriteHandle m_hBlackness;
	SpriteHandle m_hPentagram;
	Timer m_tmrPentagram;
	Timer m_tmrFadeOut;
	SoundHandle m_hExplosion;
	bool m_bEntSwitch;
	int m_iAlphaValue;
	
	//Let the disaster unfold: Damage all entities and unleash the inferno
	void SpawnDisaster()
	{
		S_PlaySound(this.m_hExplosion, 10);
		
		CDamageAll @obj = CDamageAll();
		Ent_SpawnEntity(@obj, Vector(0, 0));
		
		for (int i = 0; i < C_FLAME_COUNT; i++) {
			this.m_bEntSwitch = !this.m_bEntSwitch;
			
			Vector vCurPos = Vector(Util_Random(1, Wnd_GetWindowCenterX() * 2 - 64), Util_Random(1, Wnd_GetWindowCenterY() * 2 - 64));
		
			if (this.m_bEntSwitch) {
				CFlame @flame = @CFlame();
				Ent_SpawnEntity(@flame, vCurPos);
			} else {
				CExplosion @expl = @CExplosion();
				Ent_SpawnEntity(@expl, vCurPos);
			}
		}
	}
	
	CPentagram()
    {
		this.m_vecSize = Vector(800, 783);
		this.m_bEntSwitch = false;
		this.m_iAlphaValue = 200;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hBlackness = R_LoadSprite(g_szToolPath + "blackness.png", 1, Wnd_GetWindowCenterX() * 2, Wnd_GetWindowCenterY() * 2, 1, true);
		this.m_hPentagram = R_LoadSprite(g_szToolPath + "pentagram.png", 1, this.m_vecSize[0], this.m_vecSize[1], 1, false);
		this.m_tmrPentagram.SetDelay(1500);
		this.m_tmrPentagram.Reset();
		this.m_tmrPentagram.SetActive(true);
		this.m_tmrFadeOut.SetDelay(50);
		this.m_tmrFadeOut.Reset();
		this.m_tmrFadeOut.SetActive(false);
		this.m_hExplosion = S_QuerySound(g_szToolPath + "explosion.wav");
		this.SpawnDisaster();
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		g_bSpawned = false;
	}
	
	//Process entity stuff
	void OnProcess()
	{
		if (this.m_tmrFadeOut.IsActive()) {
			this.m_tmrFadeOut.Update();
			if (this.m_tmrFadeOut.IsElapsed()) {
				this.m_tmrFadeOut.Reset();
				
				this.m_iAlphaValue -= 8;
				if (this.m_iAlphaValue <= 1) {
					this.m_tmrFadeOut.SetActive(false);
				}
			}
		}
	
		this.m_tmrPentagram.Update();
		if (this.m_tmrPentagram.IsElapsed()) {
			this.m_tmrPentagram.SetActive(false);
			
			this.m_tmrFadeOut.SetDelay(50);
			this.m_tmrFadeOut.Reset();
			this.m_tmrFadeOut.SetActive(true);
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
		R_DrawSprite(this.m_hBlackness, Vector(0, 0), 0, 0.0, Vector(-1, -1), 0.0, 0.0, true, Color(0, 0, 0, this.m_iAlphaValue));
		R_DrawSprite(this.m_hPentagram, Vector(Wnd_GetWindowCenterX() - this.m_vecSize[0] / 2, Wnd_GetWindowCenterY() - this.m_vecSize[1] / 2), 0, 0.0, Vector(-1, -1), 0.0, 0.0, true, Color(255, 255, 0, this.m_iAlphaValue));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_iAlphaValue == 0;
	}
	
	//Indicate whether this entity is damageable. Damageable entities can collide with other
	//entities (even with entities from other tools) and recieve and strike damage. 
	//0 = not damageable, 1 = damage all, 2 = not damaging entities with same name
	DamageType IsDamageable()
	{
		return DAMAGEABLE_NO;
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
		return 0;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "Pentagram";
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

class CSummoning : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Vector m_vecSkull;
	Model m_oModel;
	Timer m_oAlphaChange;
	SpriteHandle m_hBlackness;
	SpriteHandle m_hSkullNormal;
	SpriteHandle m_hSkullEyes;
	int m_iAlphaValue;
	float m_fSkullScale;
	SoundHandle m_hHowl;
	SoundHandle m_hLaugh;
	bool m_bLaughed;
	
	CSummoning()
    {
		this.m_vecPos = Vector(0, 0);
		this.m_vecSize = Vector(Wnd_GetWindowCenterX() * 2, Wnd_GetWindowCenterY() * 2);
		this.m_vecSkull = Vector(Wnd_GetWindowCenterX() - 45, Wnd_GetWindowCenterY() - 60);
		this.m_iAlphaValue = 0;
		this.m_fSkullScale = 0.0f;
		this.m_bLaughed = false;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_hBlackness = R_LoadSprite(g_szToolPath + "blackness.png", 1, this.m_vecSize[0], this.m_vecSize[1], 1, true);
		this.m_hSkullNormal = R_LoadSprite(g_szToolPath + "skull_norm.png", 1, 98, 117, 1, false);
		this.m_hSkullEyes = R_LoadSprite(g_szToolPath + "skull_eyes.png", 1, 98, 117, 1, false);
		this.m_oAlphaChange.SetDelay(50);
		this.m_oAlphaChange.Reset();
		this.m_oAlphaChange.SetActive(true);
		this.m_hHowl = S_QuerySound(g_szToolPath + "howl.wav");
		this.m_hLaugh = S_QuerySound(g_szToolPath + "laugh.wav");
		S_PlaySound(this.m_hHowl, 10);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		CPentagram @pentagram = CPentagram();
		Ent_SpawnEntity(@pentagram, Vector(0, 0));
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oAlphaChange.Update();
		if (this.m_oAlphaChange.IsElapsed()) {
			this.m_oAlphaChange.Reset();
			
			this.m_iAlphaValue += 2;
			this.m_fSkullScale += 0.005f;
			
			if (this.m_iAlphaValue >= C_SKULL_CHANGE) {
				if (!this.m_bLaughed) {
					this.m_bLaughed = true;
					
					S_PlaySound(this.m_hLaugh, 10);
				}
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hBlackness, this.m_vecPos, 0, 0.0, Vector(-1, -1), 0.0, 0.0, true, Color(0, 0, 0, this.m_iAlphaValue));
		
		if (this.m_iAlphaValue >= 130) {
			if (this.m_iAlphaValue < C_SKULL_CHANGE) {
				R_DrawSprite(this.m_hSkullNormal, this.m_vecSkull, 0, 0.0, Vector(-1, -1), 1.0 + this.m_fSkullScale, 1.0 + this.m_fSkullScale, false, Color(0, 0, 0, 0));
			} else {
				R_DrawSprite(this.m_hSkullEyes, this.m_vecSkull, 0, 0.0, Vector(-1, -1), 1.0 + this.m_fSkullScale, 1.0 + this.m_fSkullScale, false, Color(0, 0, 0, 0));
			}
		}
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_iAlphaValue >= 255;
	}
	
	//Indicate whether this entity is damageable. Damageable entities can collide with other
	//entities (even with entities from other tools) and recieve and strike damage. 
	//0 = not damageable, 1 = damage all, 2 = not damaging entities with same name
	DamageType IsDamageable()
	{
		return DAMAGEABLE_NO;
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
		return 0;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "Beleth";
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
	if (!g_bSpawned) {
		CSummoning @obj = CSummoning();
		Ent_SpawnEntity(@obj, vAtPos);
		
		g_bSpawned = true;
	}
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
	The gamekeys holds virtual key codes of bound actions. The tool path can be used to load objects from. Return 
	true on success, otherwise false.
*/
bool CDG_API_QueryToolInfo(HostVersion hvVersion, ToolInfo &out info, const GameKeys& in gamekeys, const string &in szToolPath)
{
	info.szName = "Beleth";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "xhair.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 64;
	info.iCursorHeight = 64;
	info.uiTriggerDelay = 500;
	
	g_szToolPath = szToolPath;

	return true;
}