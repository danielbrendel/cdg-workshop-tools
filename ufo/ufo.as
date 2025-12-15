/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Ufo (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

string g_szToolPath = "";

#include "${COMMON}/decal/decal.as"
#include "${COMMON}/explosion/explosion.as"

class CLaserEntity : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_tmrLifeTime;
	Timer m_tmrMovement;
	SpriteHandle m_hSprite;
	float m_fRotation;
	float m_fSpeed;
	
	CLaserEntity()
    {
		this.m_fSpeed = 15.0;
    }
	
	void Move(void)
	{
		//Update position according to speed
		this.m_vecPos[0] += int(sin(this.m_fRotation) * this.m_fSpeed);
		this.m_vecPos[1] -= int(cos(this.m_fRotation) * this.m_fSpeed);
	}
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_vecPos[0] += 20;
		this.m_vecPos[1] -= 45;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "laser" + (Util_Random(0, 4) + 1) + ".png", 1, 123, 127, 1, false);
		this.m_tmrLifeTime.SetDelay(1000 + Util_Random(0, 500));
		this.m_tmrLifeTime.Reset();
		this.m_tmrLifeTime.SetActive(true);
		this.m_tmrMovement.SetDelay(10);
		this.m_tmrMovement.Reset();
		this.m_tmrMovement.SetActive(true);
		SoundHandle hSound = S_QuerySound(g_szToolPath + "laser.wav");
		S_PlaySound(hSound, 10);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(50, 50));
		this.m_oModel.Alloc();
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		CDecalEntity @obj = CDecalEntity();
		Ent_SpawnEntity(@obj, Vector(this.m_vecPos[0], this.m_vecPos[1] + 20));
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
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, this.m_fRotation, Vector(-1, -1), 0.5, 0.5, false, Color(0, 0, 0, 0));
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
		return this.m_fRotation;
	}

	//Can be used to overwrite the current rotation with the given rotation
	void SetRotation(float fRotation)
	{
		this.m_fRotation = fRotation;
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

class CUfo : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSelSize;
	Vector m_vecTarget;
	Model m_oModel;
	SpriteHandle m_hSprite;
	Timer m_tmrMovement;
	Timer m_tmrShooting;
	float m_fSpawnRotation;
	int m_iRotationCount;
	bool m_bRemoval;
	
	CUfo()
    {
		this.m_vecSelSize = Vector(0, 0);
		this.m_bRemoval = false;
		this.m_fSpawnRotation = 0.0f;
		this.m_iRotationCount = 0;
    }
	
	//Perform shooting
	void Shoot()
	{
		this.m_fSpawnRotation += 0.30;
		this.m_iRotationCount++;
		
		CLaserEntity @laser = CLaserEntity();
		laser.SetRotation(this.m_fSpawnRotation);
		Ent_SpawnEntity(@laser, Vector(this.m_vecPos[0] - 20, this.m_vecPos[1] + 30));
		
		if (this.m_iRotationCount >= 20) {
			this.m_fSpawnRotation = 0;
		}
	}
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = Vector(Wnd_GetWindowCenterX() * 2 + 64, vec[1] - 20);
		this.m_vecTarget = vec;
		this.m_tmrMovement.SetDelay(10);
		this.m_tmrMovement.Reset();
		this.m_tmrMovement.SetActive(true);
		this.m_tmrShooting.SetDelay(100);
		this.m_tmrShooting.Reset();
		this.m_tmrShooting.SetActive(true);
		this.m_hSprite = R_LoadSprite(g_szToolPath + "ufo.png", 1, 100, 100, 1, true);
		SoundHandle hSound = S_QuerySound(g_szToolPath + "spawn.wav");
		S_PlaySound(hSound, 10);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_tmrMovement.Update();
		if (this.m_tmrMovement.IsElapsed()) {
			this.m_tmrMovement.Reset();
			
			this.m_vecPos[0] -= 20;
			if (this.m_vecPos[0] < -64) {
				this.m_bRemoval = true;
			}
		}
		
		if (this.m_tmrShooting.IsActive()) {
			this.m_tmrShooting.Update();
			if (this.m_tmrShooting.IsElapsed()) {
				this.m_tmrShooting.Reset();
				
				this.Shoot();
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, 0.0f, Vector(0, 0), 0.0f, 0.0f, false, Color(0, 0, 0, 0));
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
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
		return this.m_bRemoval;
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
		return this.m_vecSelSize;
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
	CUfo @obj = CUfo();
	Ent_SpawnEntity(@obj, vAtPos);
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
	info.szName = "Ufo";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "target.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 64;
	info.iCursorHeight = 64;
	info.uiTriggerDelay = 250;

	g_szToolPath = szToolPath;

	return true;
}