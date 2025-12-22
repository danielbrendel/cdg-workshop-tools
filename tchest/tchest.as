/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2025 by Daniel Brendel
	
	Tool: Treasure Chest (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "${COMMON}/decal/decal.as"
#include "${COMMON}/explosion/explosion.as"

string g_szToolPath = "";

const int C_SPARK_SPEED = 10;

class CSparkEntity : IScriptedEntity
{
	Vector m_vecPos;
	float m_fRotation;
	Model m_oModel;
	SpriteHandle m_hSpark;
	Timer m_tmrSpark;
	string m_szSpriteIdent;
	Vector m_vecSpriteSize;
	string m_szSoundFile;
	
	//Set sprite file name ident
	void SetSpriteIdent(const string &in ident)
	{
		this.m_szSpriteIdent = ident;
	}
	
	//Set sprite size
	void SetSpriteSize(const Vector &in size)
	{
		this.m_vecSpriteSize = size;	
	}
	
	void SetSoundFile(const string &in sound)
	{
		this.m_szSoundFile = sound;
	}
	
	//Move sprite
	void Move()
	{
		this.m_vecPos[0] += int(sin(this.m_fRotation + 0.014) * C_SPARK_SPEED);
		this.m_vecPos[1] -= int(cos(this.m_fRotation + 0.014) * C_SPARK_SPEED);
	}
	
	CSparkEntity()
    {
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		
		this.m_hSpark = R_LoadSprite(g_szToolPath + this.m_szSpriteIdent + Util_Random(1, 5) + ".png", 1, this.m_vecSpriteSize[0], this.m_vecSpriteSize[1], 1, false);
		
		this.m_tmrSpark.SetDelay(2000);
		this.m_tmrSpark.Reset();
		this.m_tmrSpark.SetActive(true);
		
		SoundHandle hExplosion = S_QuerySound(g_szToolPath + this.m_szSoundFile);
		S_PlaySound(hExplosion, 10);
		
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(this.m_vecSpriteSize[0], this.m_vecSpriteSize[1]));
		this.m_oModel.Alloc();
		this.m_oModel.SetCenter(Vector(this.m_vecSpriteSize[0] / 2, this.m_vecSpriteSize[1] / 2));
		this.m_oModel.Initialize2(bbox, this.m_hSpark);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		//Move sprite
		this.Move();
		
		//Update time if enabled
		if (this.m_tmrSpark.IsActive()) {
			this.m_tmrSpark.Update();
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSpark, this.m_vecPos, 0, this.m_fRotation, Vector(-1, -1), 1.0, 1.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_tmrSpark.IsElapsed();
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
		return 90;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "TreasureChest.Spark";
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
		return this.m_vecSpriteSize;
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

class CTreasureChest : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	SpriteHandle m_hChest;
	SpriteHandle m_hFlare;
	SoundHandle m_hSoundtrack;
	Timer m_oExplosion;
	Timer m_oFlareRot;
	Timer m_oChestAnim;
	float m_fFlareRot;
	float m_fChestAnim;
	bool m_bChestAnimDir;
	bool m_bChestAnimDim;
	
	CTreasureChest()
    {
		this.m_vecSize = Vector(30, 30);
		this.m_fFlareRot = 0.0f;
		this.m_fChestAnim = 0.0f;
		this.m_bChestAnimDir = true;
		this.m_bChestAnimDim = true;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hChest = R_LoadSprite(g_szToolPath + "chest.png", 1, this.m_vecSize[0], this.m_vecSize[1], 1, false);
		this.m_hFlare = R_LoadSprite(g_szToolPath + "flare.png", 1, 256, 256, 1, false);
		this.m_oExplosion.SetDelay(7000);
		this.m_oExplosion.Reset();
		this.m_oExplosion.SetActive(true);
		this.m_oFlareRot.SetDelay(50);
		this.m_oFlareRot.Reset();
		this.m_oFlareRot.SetActive(true);
		this.m_oChestAnim.SetDelay(150);
		this.m_oChestAnim.Reset();
		this.m_oChestAnim.SetActive(true);
		this.m_hSoundtrack = S_QuerySound(g_szToolPath + "soundtrack.wav");
		S_PlaySound(this.m_hSoundtrack, 10);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		float fSpawnRotation = 0.00f;
		
		for (int i = 0; i < 20; i++) {
			CSparkEntity @obj = CSparkEntity();
			obj.SetRotation(fSpawnRotation);
			obj.SetSpriteIdent("spark");
			obj.SetSpriteSize(Vector(119, 122));
			obj.SetSoundFile("sparks.wav");
			Ent_SpawnEntity(@obj, Vector(this.m_vecPos[0] - 50, this.m_vecPos[1] - 40));
			
			fSpawnRotation += 0.30;
		}
		
		CMainExplosion @mex = CMainExplosion();
		Ent_SpawnEntity(@mex, this.m_vecPos);
		
		CDamageDecal @mdc = CDamageDecal();
		mdc.SetDamageSize(Vector(64, 64));
		mdc.SetDecalSprite("decal_medium.png");
		mdc.SetOffspringFlag(true);
		mdc.SetDamageValue(200);
		Ent_SpawnEntity(@mdc, this.m_vecPos);
	
		for (int i = 0; i < 30; i++) {
			Vector vTarget = Vector(this.m_vecPos[0] + (Util_Random(0, 400) - 200), this.m_vecPos[1] + (Util_Random(0, 400) - 200));
			vTarget[1] -= 15;
			
			CExplosion @expl = @CExplosion();
			Ent_SpawnEntity(@expl, vTarget);
			
			CDamageDecal @dcl = CDamageDecal();
			dcl.SetDamageSize(Vector(64, 64));
			dcl.SetDecalSprite("decal_medium.png");
			dcl.SetOffspringFlag(true);
			dcl.SetDamageValue(150);
			Ent_SpawnEntity(@dcl, Vector(vTarget[0] - 15, vTarget[1] - 10));
		}
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oExplosion.Update();
		
		this.m_oFlareRot.Update();
		if (this.m_oFlareRot.IsElapsed()) {
			this.m_oFlareRot.Reset();
			
			this.m_fFlareRot += 0.2f;
		}
		
		this.m_oChestAnim.Update();
		if (this.m_oChestAnim.IsElapsed()) {
			this.m_oChestAnim.Reset();
			
			if (this.m_bChestAnimDir) {
				this.m_fChestAnim += 0.1f;
				if (this.m_fChestAnim >= 0.2f) {
					this.m_bChestAnimDir = false;
				}
			} else {
				this.m_fChestAnim -= 0.1f;
				if (this.m_fChestAnim <= 0.0f) {
					this.m_bChestAnimDir = true;
					this.m_bChestAnimDim = !this.m_bChestAnimDim;
				}
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
		R_DrawSprite(this.m_hFlare, Vector(this.m_vecPos[0] - 114, this.m_vecPos[1] - 115), 0, this.m_fFlareRot, Vector(-1, -1), 0.7, 0.7, false, Color(0, 0, 0, 0));
		R_DrawSprite(this.m_hChest, this.m_vecPos, 0, 0.0, Vector(-1, -1), 1.0f + ((this.m_bChestAnimDim) ? this.m_fChestAnim : 0.0f), 1.0f + ((!this.m_bChestAnimDim) ? this.m_fChestAnim : 0.0f), false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_oExplosion.IsElapsed();
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
	CTreasureChest @obj = CTreasureChest();
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
	The tool path can be used to load objects from. Return true on success, otherwise false.
*/
bool CDG_API_QueryToolInfo(HostVersion hvVersion, ToolInfo &out info, const GameKeys& in gamekeys, const string &in szToolPath)
{
	info.szName = "Treasure Chest";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "cursor.png";
	info.szCategory = "Weapons";
	info.iCursorWidth = 32;
	info.iCursorHeight = 32;
	info.uiTriggerDelay = 125;
	
	g_szToolPath = szToolPath;

	return true;
}