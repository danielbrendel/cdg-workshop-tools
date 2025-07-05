/*
	Casual Desktop Game (dnyCasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2023 by Daniel Brendel
	
	Tool: Creeper (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

string g_szToolPath;

class color_s
{
	uint8 r, g, b, a;
}

#include "${COMMON}/decal/decal.as"
#include "${COMMON}/hitflash/hitflash.as"

class CBigExplosion : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_oExplosion;
	int m_iFrameCount;
	SpriteHandle m_hSprite;
	SoundHandle m_hSound;
	
	CBigExplosion()
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
		return 10;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "Explosion";
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

const float C_CREEPER_DEFAULT_SPEED = 2;
const int C_CREEPER_DEFAULT_STEPDELAY = 500;
const int C_CREEPER_REACT_RANGE = 300;
const int C_CREEPER_ATTACK_RANGE = 20;

class CCreeper : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	SpriteHandle m_hSprite;
	SpriteHandle m_hFootLeft;
	SpriteHandle m_hFootRight;
	Timer m_oMoveStart;
	Timer m_oSteps;
	Timer m_oShaking;
	Timer m_oDirChange;
	Timer m_oLifeTime;
	Timer m_oEnemyCheck;
	Timer m_oFuze;
	Timer m_oFlashing;
	float m_fShakeRot;
	float m_fWalkRot;
	float m_fSpeed;
	uint8 m_hvHealth;
	bool m_bCanMove;
	bool m_bDetonate;
	bool m_bGotEnemy;
	bool m_bFlashColor;
	array<SoundHandle> m_arrSteps;
	SoundHandle m_hFuseSound;
	SoundHandle m_hPainSound;
	CHitFlash m_oHitFlash;
	
	CCreeper()
    {
		this.m_hvHealth = 100;
		this.m_fSpeed = C_CREEPER_DEFAULT_SPEED;
		this.m_fShakeRot = 0.0;
		this.m_bCanMove = false;
		this.m_bGotEnemy = false;
		this.m_bFlashColor = false;
		this.m_bDetonate = false;
		this.m_oHitFlash = CHitFlash();
    }
	
	void Move(void)
	{
		if (!this.m_bCanMove)
			return;
	
		//Update position according to speed
		this.m_vecPos[0] += int(sin(this.m_fWalkRot) * this.m_fSpeed);
		this.m_vecPos[1] -= int(cos(this.m_fWalkRot) * this.m_fSpeed);
		
		//Fix positions
		
		if (this.m_vecPos[0] <= -32) {
			this.m_vecPos[0] = Wnd_GetWindowCenterX() * 2 + 32;
		} else if (this.m_vecPos[0] >= Wnd_GetWindowCenterX() * 2 + 32) {
			this.m_vecPos[0] = -32;
		}
		
		if (this.m_vecPos[1] <= -32) {
			this.m_vecPos[1] = Wnd_GetWindowCenterY() * 2 + 32;
		} else if (this.m_vecPos[1] >= Wnd_GetWindowCenterY() * 2 + 32) {
			this.m_vecPos[1] = -32;
		}
	}
	
	bool ShallRemove(void)
	{
		//Indicate removal
		return ((this.m_oLifeTime.IsElapsed()) || (this.m_hvHealth == 0) || (this.m_bDetonate == true));
	}
	
	void LookAt(const Vector &in vPos)
	{
		//Look at position
		float flAngle = atan2(float(vPos[1] - this.m_vecPos[1]), float(vPos[0] - this.m_vecPos[0]));
		this.m_fWalkRot = flAngle + 6.30 / 4;
	}
	
	void CheckForEnemiesInRange()
	{
		//Check for enemies in close range and act accordingly
		
		this.m_bGotEnemy = false;
		IScriptedEntity@ pEntity = null;
		
		for (size_t i = 0; i < Ent_GetEntityCount(); i++) {
			@pEntity = @Ent_GetEntityHandle(i);
			if ((@pEntity != null) && (pEntity.GetName() != this.GetName()) && (pEntity.IsDamageable() != DAMAGEABLE_NO)) {
				if (this.m_vecPos.Distance(pEntity.GetPosition()) <= C_CREEPER_REACT_RANGE) {
					this.m_bGotEnemy = true;
					break;
				}
			}
		}
		
		if (this.m_bGotEnemy) {
			if (this.m_fSpeed == C_CREEPER_DEFAULT_SPEED)
				this.m_fSpeed *= 3;
				
			this.m_oSteps.SetDelay(C_CREEPER_DEFAULT_STEPDELAY / 2);
				
			if (pEntity.GetName().length() > 0) {
				this.LookAt(pEntity.GetPosition());
			}

			if (this.m_vecPos.Distance(pEntity.GetPosition()) <= C_CREEPER_ATTACK_RANGE) {
				this.m_bDetonate = true;
			}
			
			if (!this.m_oFuze.IsActive()) {
				S_PlaySound(this.m_hFuseSound, 10);
				
				this.m_oFuze.Reset();
				this.m_oFuze.SetActive(true);
			}
			
			if (!this.m_oFlashing.IsActive()) {
				this.m_oFlashing.Reset();
				this.m_oFlashing.SetActive(true);
			}
		} else {
			if (this.m_fSpeed != C_CREEPER_DEFAULT_SPEED)
				this.m_fSpeed = C_CREEPER_DEFAULT_SPEED;
				
			this.m_oSteps.SetDelay(C_CREEPER_DEFAULT_STEPDELAY);
		
			if (this.m_oFuze.IsActive())
				this.m_oFuze.SetActive(false);
				
			if (this.m_oFlashing.IsActive()) {
				this.m_bFlashColor = false;
				this.m_oFlashing.SetActive(false);
			}
		}
	}
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_fWalkRot = float(Util_Random(1, 360));
		this.m_vecPos = vec;
		this.m_vecPos[0] += 32;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "creeper.png", 1, 74, 111, 1, true);
		this.m_hFootLeft = R_LoadSprite(g_szToolPath + "creeper_foot_left.png", 1, 24, 29, 1, true);
		this.m_hFootRight = R_LoadSprite(g_szToolPath + "creeper_foot_right.png", 1, 24, 29, 1, true);
		this.m_oLifeTime.SetDelay(240000);
		this.m_oLifeTime.Reset();
		this.m_oLifeTime.SetActive(true);
		this.m_oMoveStart.SetDelay(1000);
		this.m_oMoveStart.Reset();
		this.m_oMoveStart.SetActive(true);
		this.m_oSteps.SetDelay(C_CREEPER_DEFAULT_STEPDELAY);
		this.m_oSteps.Reset();
		this.m_oSteps.SetActive(false);
		this.m_oDirChange.SetDelay(10000);
		this.m_oDirChange.Reset();
		this.m_oDirChange.SetActive(true);
		this.m_oEnemyCheck.SetDelay(1);
		this.m_oEnemyCheck.Reset();
		this.m_oEnemyCheck.SetActive(true);
		this.m_oShaking.SetDelay(1000);
		this.m_oShaking.Reset();
		this.m_oShaking.SetActive(true);
		this.m_oFuze.SetDelay(1500);
		this.m_oFuze.Reset();
		this.m_oFuze.SetActive(false);
		this.m_oFlashing.SetDelay(200);
		this.m_oFlashing.Reset();
		this.m_oFlashing.SetActive(false);
		for (int i = 1; i <= 10; i++) {
			this.m_arrSteps.insertLast(S_QuerySound(g_szToolPath + "step" + i + ".wav"));
		}
		this.m_hFuseSound = S_QuerySound(g_szToolPath + "fuse.wav");
		this.m_hPainSound = S_QuerySound(g_szToolPath + "hurt.wav");
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(74, 111));
		this.m_oModel.Alloc();
		this.m_oModel.SetCenter(Vector(37, 55));
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		CBigExplosion @bex = CBigExplosion();
		Ent_SpawnEntity(@bex, this.m_vecPos);
		
		CDamageDecal @mdc = CDamageDecal();
		mdc.SetDamageSize(Vector(64, 64));
		mdc.SetDecalSprite("decal_medium.png");
		mdc.SetOffspringFlag(true);
		mdc.SetDamageValue(50);
		Ent_SpawnEntity(@mdc, this.m_vecPos);
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oLifeTime.Update();
		
		if (this.m_oMoveStart.IsActive()) {
			this.m_oMoveStart.Update();
			if (this.m_oMoveStart.IsElapsed()) {
				this.m_oMoveStart.SetActive(false);
				this.m_bCanMove = true;
				this.m_oSteps.SetActive(true);
			}
		}
		
		if (this.m_oSteps.IsActive()) {
			this.m_oSteps.Update();
			if (this.m_oSteps.IsElapsed()) {
				this.m_oSteps.Reset();
				
				int soundvol = (this.m_bGotEnemy) ? 10 : 8;
				int rndstep = Util_Random(0, this.m_arrSteps.length() - 1);
				S_PlaySound(this.m_arrSteps[rndstep], soundvol);
			}
		}
	
		this.m_oShaking.Update();
		if (this.m_oShaking.IsElapsed()) {
			if (!this.m_bGotEnemy)
				this.m_fShakeRot = -0.25 + float(Util_Random(1, 5)) / 10.0;
		}
		
		this.m_oDirChange.Update();
		if (this.m_oDirChange.IsElapsed()) {
			this.m_oDirChange.Reset();
			if (!this.m_bGotEnemy)
				this.m_fWalkRot = float(Util_Random(1, 360));
		}
		
		if (this.m_oFuze.IsActive()) {
			this.m_oFuze.Update();
			if (this.m_oFuze.IsElapsed()) {
				this.m_oFuze.Reset();
				
				S_PlaySound(this.m_hFuseSound, 10);
			}
		}
		
		if (this.m_oFlashing.IsActive()) {
			this.m_oFlashing.Update();
			if (this.m_oFlashing.IsElapsed()) {
				this.m_oFlashing.Reset();
				
				this.m_bFlashColor = !this.m_bFlashColor;
			}
		}
		
		this.CheckForEnemiesInRange();
		this.Move();
		
		this.m_oHitFlash.Process();
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		color_s sDrawingColor;
		bool bCustomColor = (this.m_bFlashColor) || (this.m_oHitFlash.ShouldDraw());
		if (this.m_oHitFlash.ShouldDraw()) {
			sDrawingColor = this.m_oHitFlash.GetHitColor();
		} else if (this.m_bFlashColor) {
			sDrawingColor.r = 100;
			sDrawingColor.g = 100;
			sDrawingColor.b = 0;
			sDrawingColor.a = 255;
		}
	
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, 0.0f, Vector(-1, -1), 0.0, 0.0, bCustomColor, Color(sDrawingColor.r, sDrawingColor.g, sDrawingColor.b, sDrawingColor.a));
		R_DrawSprite(this.m_hFootLeft, Vector(this.m_vecPos[0] + 15, this.m_vecPos[1] + 83), 0, 0.0f + this.m_fShakeRot, Vector(-1, -1), 0.0, 0.0, bCustomColor, Color(sDrawingColor.r, sDrawingColor.g, sDrawingColor.b, sDrawingColor.a));
		R_DrawSprite(this.m_hFootRight, Vector(this.m_vecPos[0] + 35, this.m_vecPos[1] + 83), 0, 0.0f + this.m_fShakeRot, Vector(-1, -1), 0.0, 0.0, bCustomColor, Color(sDrawingColor.r, sDrawingColor.g, sDrawingColor.b, sDrawingColor.a));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.ShallRemove();
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
		if (dv == 0) return;
		
		this.m_oHitFlash.Start();
		
		if (int(this.m_hvHealth) - int(dv) >= 0) { this.m_hvHealth -= dv; S_PlaySound(this.m_hPainSound, 10); }
		else { this.m_hvHealth = 0; }
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
		return this.m_fWalkRot;
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
		return "Creeper";
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
	CCreeper @obj = CCreeper();
	Ent_SpawnEntity(@obj, Vector(vAtPos[0] - 32, vAtPos[1] - 10));
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
	info.szName = "Creeper";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "cursor.png";
	info.szCategory = "Monsters";
	info.iCursorWidth = 32;
	info.iCursorHeight = 32;
	info.uiTriggerDelay = 125;
	
	g_szToolPath = szToolPath;

	return true;
}