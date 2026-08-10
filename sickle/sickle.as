/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2026 by Daniel Brendel
	
	Tool: Sickle (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"
#include "${COMMON}/explosion/explosion.as"

string g_szToolPath = "";

class CSickleEntity : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	SpriteHandle m_hSprite;
	float m_fRotation;
	float m_fDrawRot;
	float m_fSpeed;
	Timer m_tmrRotation;
	Timer m_tmrDuration;
	bool m_bCollided;
	
	CSickleEntity()
    {
		this.m_vecSize = Vector(100, 100);
		this.m_fSpeed = 15.0;
		this.m_bCollided = false;
    }
	
	void SetRotation(float fRotation)
	{
		//Set rotation
		
		this.m_fRotation = fRotation;
		this.m_fDrawRot = this.m_fRotation;
	}
	
	void Move()
	{
		//Move laser
		
		//Set next position according to view
		this.m_vecPos[0] += int(sin(this.m_fRotation + 0.014) * this.m_fSpeed);
		this.m_vecPos[1] -= int(cos(this.m_fRotation + 0.014) * this.m_fSpeed);
	}
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "sickle" + Util_Random(1, 5) + ".png", 1, 60, 99, 1, true);
		this.m_tmrRotation.SetDelay(10);
		this.m_tmrRotation.Reset();
		this.m_tmrRotation.SetActive(true);
		this.m_tmrDuration.SetDelay(5000);
		this.m_tmrDuration.Reset();
		this.m_tmrDuration.SetActive(true);
		this.m_oModel.Alloc();
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), this.m_vecSize);
		this.m_oModel.Alloc();
		this.m_oModel.SetCenter(Vector(this.m_vecSize[0] / 2, this.m_vecSize[1] / 2));
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.Move();
		
		if (this.m_tmrRotation.IsActive()) {
			this.m_tmrRotation.Update();
			if (this.m_tmrRotation.IsElapsed()) {
				this.m_tmrRotation.Reset();
				
				this.m_fDrawRot += 0.3f;
			}
		}
		
		this.m_tmrDuration.Update();
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, this.m_fDrawRot, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return (this.m_bCollided) || (this.m_tmrDuration.IsElapsed());
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
		this.m_bCollided = true;
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
	
	//Called for querying the damage value for this entity
	DamageValue GetDamageValue()
	{
		return 200;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "weapon.sickle";
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
	float fSpawnRotation = 0.00f;
	
	for (int i = 0; i < 10; i++) {
		CSickleEntity @obj = CSickleEntity();
		obj.SetRotation(fSpawnRotation);
		Ent_SpawnEntity(@obj, vAtPos);
		
		fSpawnRotation += 0.60;
	}
	
	SoundHandle hShoot = S_QuerySound(g_szToolPath + "shoot.wav");
	S_PlaySound(hShoot, S_GetCurrentVolume());
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
	info.szName = "Sickle";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "xhair.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 52;
	info.iCursorHeight = 52;
	info.uiTriggerDelay = 250;
	
	g_szToolPath = szToolPath;

	return true;
}