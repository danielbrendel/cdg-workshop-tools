/*
	Casual Desktop Game (dnycasualDeskGame) v1.0 developed by Daniel Brendel
	
	(C) 2018 - 2022 by Daniel Brendel
	
	Tool: Frogator (developed by Daniel Brendel)
	Version: 0.1
	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

/*
	API documentation
	*****************

	Basic data types:
	-----------------
	size_t: Can be used as entity iterator (64 Bit)
	HostVersion: A 16-bit value containing a version number (high and low)
	SpriteHandle: A handle to a sprite (64 Bit)
	SoundHandle: A handle to a sound (64 Bit)
	DamageValue: Value containing a damage value. 0 - 255 (1 Byte)
	
	Enums:
	------
	DamageType:
		- DAMAGEABLE_NO: Specifies a non-damageable entity
		- DAMAGEABLE_ALL: Specifies an entity that can be damaged by all
		- DAMAGEABLE_NOTSQUAD: Specifies an entity that cannot be damaged by entities with the same name
	FileSeekWay:
		- SEEKW_BEGIN: Start from the begin of a file
		- SEEKW_CURRENT: Start from current file offset
		- SEEKW_END: Start from the end of a file
		
	Callbacks:
	----------
	//Called for every file object in list
	bool FuncFileListing(const string& in);
	
	Structs:
	--------
	ToolInfo:
		- string szName //The name of the tool
		- string szVersion //The tool version
		- string szAuthor //The author identifier
		- string szContact //Contact information
		- string szPreviewImage //Preview image file relative to the directory of the tool
		- string szCursor //Cursor sprite file relative to the directory of the tool
		- int iCursorWidth //The desired width of the cursor
		- int iCursorHeight //The desired height of the cursor
		- uint32 uiTriggerDelay //Using the tool via the trigger button is available when this time in milliseconds has elapsed
	GameKeys:
		- int vkTrigger //Virtual key code of the trigger mouse button
		- int vkClearn //Virtual key code of the clean mouse button
		- int vkMenu //Virtual key code of the menu button
		- int vkScrollUp //Virtual key code of the mouse button to scroll up (defaulted to wheel up)
		- int vkScrollDown //Virtual key code of the mouse button to scroll down (defaulted to wheel down)
		- int vkTeamSelect //Virtual key code of the team selection button
		- int vkTakeScreen //Virtual key code of the button to take screenshots
		- int vkKey0 - vkKey9 //Virtual key code of a bound tool
		- int vkExit //Virtual key code of the exit button
		
	Classes:
	--------
	Color (Used to define colors for sprites, boxes, strings, etc.):
		- Color() //Default constructor
		- Color(uint8 r, uint8 g, uint8 b, uint8 a) //Construct with default values
		- uint8 R() //Getter for red channel
		- uint8 G() //Getter for green channel
		- uint8 B() //Getter for blue channel
		- uint8 A() //Getter for alpha channel
	ConColor (Used to define colors when printing to the console):
		- ConColor() //Default constructor
		- ConColor(uint8 r, uint8 g, uint8 b) //Construct with default values
		- uint8 R() //Getter for red channel
		- uint8 G() //Getter for green channel
		- uint8 B() //Getter for blue channel
	Vector (Screen positions and resolutions are defined as 2D vectors):
		- Vector() //Default constructor
		- Vector(Vector &in) //Construct from a different Vector
		- Vector(int x, int y) //Construct from x and y coordinates
		- Vector[0/1] //Getter and setter for a specific dimension
		- Vector=Vector //Assign the values of a Vector to a different Vector
		- Vector==Vector //Compare two Vectors of equality
		- Vector[0/1]++ //Increment Vector dimension value
		- Vector[0/1]-- //Decrement Vector dimension value
		- Vector+Vector //Perform addition of two Vectors
		- Vector-Vector //Substract a Vector from another
		- int GetX() const //Get X dimension value
		- int GetY() const //Get Y dimension value
		- int Distance(const Vector &in) //Calculate the distance between two Vectors
		- void Zero() //Fill the Vector with zero
	SpriteInfo (Useful for obtaining information about a sprite before loading it):
		- SpriteInfo() //Default constructor
		- Vector& GetResolution() //Get resolution of the sprite
		- int GetDepth() //Get color depth of the sprite
		- int GetFormat() //Get format of the sprite
	BoundingBox (Used to define the bounding box of a model):
		- BoundingBox() //Default constructor
		- bool Alloc() //Allocate memory needed for using the object instance
		- void AddBBoxItem(const Vector& in, const Vector& in) //Add a bbox item. 
			First Vector is the relative position of the item and the second Vector 
			is the dimensions of the item
		- bool IsCollided(const Vector& in, const Vector& in, const BoundingBox& in) //Check for collision. 
			First Vector is the absolute screen position of the owner entity, second Vector is the absolute screen
			position of the reference entity. Last parameter is the BoundingBox object instance of the reference entity
		- bool IsInside(const Vector &in, const Vector &in) //Check if a Vector is inside the BoundingBox.
			First argument is the absolute position of the owner entity, second argument is the position to be checked.
		- bool IsEmpty() //Returns true if there are no items added to the BoundingBox
		- void Clear() //Remove all added items
	TempSprite (Useful for creating non-specific temporary sprites which do only have a visual relevance):
		- TempSprite() //Default constructor
		- TempSprite(const string &in, uint32 dwSwitchDelay, bool bInfinite, int iFrameCount, int iFrameWidth, int iFrameHeight, int iFramesPerLine, bool bForceCustomSize)
			//Instantiate with the given data. First argument is the sprite file name relative to the directory of the tool. 
			Second argument defines the delay between each frame change. Third argument defines whether this entity shall last permanently.
			iFrameCount defines the amount of frames in the sprite sheet. iFrameWidth and iFrameHeight are for the dimensions of the sprite. 
			If the sprite sheet has multiple lines then you can define the amount of frames per each line with iFramesPerLine. bForceCustomSize is used to
			determine if the sprite shall be loaded with a custom size instead of the original size
		- bool Initialize(const string &in, uint32 dwSwitchDelay, bool bInfinite, int iFrameCount, int iFrameWidth, int iFrameHeight, int iFramesPerLine, bool bForceCustomSize)
			//Used if not constructed with the custom initialization constructor. For the arguments see the custom constructor definition above.
		- void Draw(const Vector &in, float fRotation) //Draw the sprite at the given position using the given rotation
		- void Release() //Release the temp sprite. Use this when you don't need the sprite anymore or when the game shuts down
	Model (Useful for associating a model with a scripted entity. Used by the game engine to process collisions):
		- Model() //Default constructor
		- Model(const string &in) //Construct with providing a relative file name to the model file
		- Model(const string &in, bool b) //Same as above, but you can define if a custom size shall be used
		- Model=Model //Basically used to copy the entire data to a new Model object instance
		- bool Initialize(const string&in szMdlFile, bool bForceCustomSize) //Initialize the model. Same as the second custom constructor above.
		- bool Initialize2(const BoundingBox& in, SpriteHandle hSprite) //This is to be used with an already existing sprite file and a Bounding Box.
		- void Release() //Release the Model data. Use this when shutting down or not using the Model anymore
		- bool IsCollided(const Vector& in mypos, const Vector& in refpos, const Model& in mdl) //Check if a reference model collides with this model using the given absolute coordinates
		- bool IsValid() //Returns true if the model has been initialized successfully and can be used
		- bool Alloc() //Allocate memory for the model. Call this before Initialize()/Initialize2()
		- void SetCenter(const Vector &in) //This can be used to define the center of a model
		- SpriteHandle Handle() //Returns the handle to the loaded sprite associated with the model
		- const Vector& GetCenter() const //Getter for the center of the model
		- BoundingBox& GetBBox() //Returns the associated bounding box
	Timer (Useful for processing stuff after a period of time):
		- Timer() //Default constructor
		- Timer(uint32 delay) //Construct with a given delay value. Also sets the timer in active state
		- void Reset() //Resets the internal timing values. Call this when IsElapsed() returns true in order to run the timer again
		- void Update() //Perform internal update calculations
		- void SetActive(bool bStatus) //Set the activation state of the timer
		- void SetDelay(uint32 delay) //Set the delay of the timer
		- bool IsActive() //Indicate activation state
		- uint32 GetDelay() //Get delay value
		- bool IsElapsed() //Indicates whether the time has elapsed
	FileReader (can be used to read from files, e.g. custom configs):
		- FileReader() //Default constructor
		- FileReader(const string& in) //Construct object and open the given file
			for reading. Note that you can only read files relative to the directory of your tool
		- bool Open(const string &in) //Open a file for reading. 
		- bool IsOpen() //Indicate whether the file has been successfully opened 
		- bool Eof() //Returns true if the internal file pointer has reached the end of the file
		- void Seek(FileSeekWay from, int offset) //Jump "offset" bytes from the seek way inside the file
		- string GetLine() //Get line at current file pointer
		- string GetEntireContent(bool bSkipNLChar = false) //Read the entire file. The boolean argument
			specifies whether no newline char shall be appended to each read line
		- void Close() //Closes the file
	FileWriter (can be used to write to files):
		- FileWriter() //Default constructor
		- FileWriter(const string& in) //Construct and opens a file for writing. Using the constructor it defaults to append to the file
		- bool Open(const string &in, bool bAppend = true)
			//Opens a file for writing. The boolean parameter can be used to define whether to append to the file 
			if it already exists. Otherwise the file is overwritten.
		- bool Eof() //Returns true if the internal file pointer has reached the end of the file
		- void Seek(FileSeekWay from, int offset) //Jump "offset" bytes from the seek way inside the file
		- void Write(const string &in) //Write a string to the file
		- void WriteLine(const string &in) //Write a line to the file
		- void Close() //Close the file
	
	Interface:
	----------
		IScriptedEntity:
			- Used to implement entities related to the tool
			- See example in this demo script file
			//Default constructor
			IScriptedEntity()
			//Called when the entity gets spawned. The position on the screen is passed as argument
			void OnSpawn(const Vector& in vec)
			//Called when the entity gets released
			void OnRelease()
			//Process entity stuff
			void OnProcess()
			//Entity can draw everything in default order here
			void OnDraw()
			//Entity can draw on-top stuff here
			void OnDrawOnTop()
			//Indicate whether the user is allowed to clean this entity
			bool DoUserCleaning()
			//Indicate whether this entity shall be removed by the game
			bool NeedsRemoval()
			//Indicate whether this entity is damageable. Damageable entities can collide with other
			//entities (even with entities from other tools) and recieve and strike damage. 
			//0 = not damageable, 1 = damage all, 2 = not damaging entities with same name
			DamageType IsDamageable()
			//Called when the entity recieves damage
			void OnDamage(DamageValue dv)
			//Called for recieving the model data for this entity. This is only used for
			//damageable entities. 
			Model& GetModel()
			//Called for recieving the current position. This is useful if the entity shall move.
			Vector& GetPosition()
			//Return the rotation. This is actually not used by the host application, but might be useful to other entities
			float GetRotation()
			//Called for querying the damage value for this entity
			DamageValue GetDamageValue()
			//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
			//Indicate if this entity is movable
			bool IsMovable()
			//This vector is used for drawing the selection box
			Vector& GetSelectionSize()
			//This method is used to set the movement destination position
			void MoveTo(const Vector& in vec)

	Available API functions:
	------------------------
	//Print a text to the console
	void Print(const string& in)
	//Print text to the console with the given color
	void PrintClr(const string& in, const ConColor &in)
	//Set an offset to the cursor in order to draw it on a different position
	void SetCursorOffset(const Vector& in)
	//Set the cursor rotation
	void SetCursorRotation(float fRotation)
	//Load a font
	FontHandle R_LoadFont(const string& in, uint8 ucFontSizeW, uint8 ucFontSizeH)
	//Get information about a sprite file. Path is relative to the directory of the tool
	bool R_GetSpriteInfo(const string &in, SpriteInfo &out)
	//Load a sprite into memory. First argument is the sprite file name relative to the directory of the tool. 
			iFrameCount defines the amount of frames in the sprite sheet. iFrameWidth and iFrameHeight are for the dimensions of the sprite. 
			If the sprite sheet has multiple lines then you can define the amount of frames per each line with iFramesPerLine. bForceCustomSize is used to
			determine if the sprite shall be loaded with a custom size instead of the original size.
			The szFile path is relative to the directory of the tool
	SpriteHandle R_LoadSprite(const string& in szFile, int iFrameCount, int iFrameWidth, int iFrameHeight, int iFramesPerLine, bool bForceCustomSize)
	//Release a sprite if not used anymore
	bool R_FreeSprite(SpriteHandle hSprite)
	//Draw a box on the screen. It is not filled. You can define the line thickness of the box with iThickness.
	bool R_DrawBox(const Vector& in pos, const Vector&in size, int iThickness, const Color&in color)
	//Draw a filled box on the screen.
	bool R_DrawFilledBox(const Vector&in pos, const Vector&in size, const Color&in color)
	//Draw a line on the screen.
	bool R_DrawLine(const Vector&in start, const Vector&in end, const Color&in color)
	//Draw a loaded sprite on the screen. iFrame specifies the frame of the sprite sheet if the sprite is loaded from a sheet.
		You can define a vertical and horizontal scaling value. Also you can define a rotation vector which is used for
		rotating the sprite from. Also you can define a custom color which the sprite shall be rendered with.
	bool R_DrawSprite(const SpriteHandle hSprite, const Vector&in pos, int iFrame, float fRotation, const Vector &in vRotPos, float fScale1, float fScale2, bool bUseCustomColorMask, const Color&in color)
	//Draw a string on the screen.
	bool R_DrawString(const FontHandle font, const string&in szText, const Vector&in pos, const Color&in color)
	//Get the handle to the default loaded game engine font
	FontHandle R_GetDefaultFont()
	//Query a sound file located on the disk. Path is relative to the directory of the tool
	SoundHandle S_QuerySound(const string&in szSoundFile)
	//Play a sound with the given volume (1-10)
	bool S_PlaySound(SoundHandle hSound, int32 lVolume)
	//Get the center of the width of the screen
	int Wnd_GetWindowCenterX()
	//Get the center of the height of the screen
	int Wnd_GetWindowCenterY()
	//Spawn a scripted entity. Every IScriptedEntity class instance must be registered with the game engine using this method
	bool Ent_SpawnEntity(IScriptedEntity @obj, const Vector& in)
	//Get the amount of all existing entities. This includes entities from other tools
	size_t Ent_GetEntityCount()
	//Get a handle to a given entity using it's ID. You can also obtain entity handles of entities from other tools
	IScriptedEntity@+ Ent_GetEntityHandle(size_t uiEntityId)
	//Perform a trace line calculation from one point to another. The first found entity inside the trace line is returned.
		You can specify an entity that shall be skipped by the search
	IScriptedEntity@+ Ent_TraceLine(const Vector&in vStart, const Vector&in vEnd, IScriptedEntity@+ pIgnoredEnt)
	//Check if an entity is still valid. This is useful for validating if an entity has not yet been disposed
	bool Ent_IsValid(IScriptedEntity@ pEntity)
	//Get the ID of an entity by the entity handle
	size_t Ent_GetId(IScriptedEntity@ pEntity)
	//List all sprites of a directory relative to the directory of the tool.
	bool Util_ListSprites(const string& in, FuncFileListing @cb)
	//List all sounds of a directory relative to the directory of the tool
	bool Util_ListSounds(const string& in, FuncFileListing @cb)
	//Return a random number between the given values
	int Util_Random(int start, int end)
	
	AngelScript internals:
	----------------------
		You can use all things from
		- AngelScript std string
		- AngelScript script array
		- AngelScript script math
		
	In order to learn how AngelScript generally
	works visit the official AngelScript website.
*/

string g_szToolPath;

/* 
	Scripted entity 
	
	A scripted entity is a dynamic interface class for implementing
	custom entities such as explosions, decals, etc
	
	It is derived from the IScriptedEntity interface and must define
	all the following interface functions. Also it must have at least
	one Vector and Model which are returned in certain methods. Tho
	you don't need to use them. A scripted entity is passed to the 
	game engine via the Ent_SpawnEntity(<object handle>, <spawn position>) function. 
*/
class CBloodSplash : IScriptedEntity
{
	Vector m_vecPos;
	Model m_oModel;
	Timer m_oLifeTime;
	SpriteHandle m_hSprite;
	
	CBloodSplash()
    {
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "blood.png", 1, 64, 64, 1, false);
		this.m_oLifeTime.SetDelay(120000);
		this.m_oLifeTime.Reset();
		this.m_oLifeTime.SetActive(true);
		this.m_oModel.Alloc();
		SoundHandle hSound = S_QuerySound(g_szToolPath + "splash.wav");
		S_PlaySound(hSound, 10);
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
		R_DrawSprite(this.m_hSprite, this.m_vecPos, 0, 0.0, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return true;
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
	
	//Return the rotation. This is actually not used by the host application, but might be useful to other entities
	float GetRotation()
	{
		return 0.0;
	}
	
	//Called for querying the damage value for this entity
	DamageValue GetDamageValue()
	{
		return 1;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "";
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

class CBoltEntity : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecTarget;
	Model m_oModel;
	Timer m_oFrameTime;
	SpriteHandle m_hSprite;
	int m_iFrameCounter;
	float m_fRotation;
	float m_fRange;
	
	CBoltEntity()
    {
		this.m_iFrameCounter = 0;
		this.m_fRotation = 0.0;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_fRange = float(Vector(this.m_vecPos[0] + 10, this.m_vecPos[1] + 5).Distance(this.m_vecTarget)) / 300;
		this.m_hSprite = R_LoadSprite(g_szToolPath + "lightning.png", 8, 32, 256, 8, false);
		this.m_oFrameTime.SetDelay(10);
		this.m_oFrameTime.Reset();
		this.m_oFrameTime.SetActive(true);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oFrameTime.Update();
		if (this.m_oFrameTime.IsElapsed()) {
			this.m_oFrameTime.Reset();
			this.m_iFrameCounter++;
			if (this.m_iFrameCounter >= 8)
				this.m_oFrameTime.SetActive(false);
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw everything on top here
	void OnDrawOnTop()
	{
		R_DrawSprite(this.m_hSprite, this.m_vecPos, this.m_iFrameCounter, this.m_fRotation, Vector(16, 0), 0.75, this.m_fRange, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether the user is allowed to clean this entity
	bool DoUserCleaning()
	{
		return false;
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_iFrameCounter >= 8;
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
	
	//Return the rotation. This is actually not used by the host application, but might be useful to other entities
	float GetRotation()
	{
		return this.m_fRotation;
	}
	
	//Called for querying the damage value for this entity
	DamageValue GetDamageValue()
	{
		return 0;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "TeslaLightning";
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
	
	//Custom methods
	
	void SetRotation(float fRotation)
	{
		this.m_fRotation = fRotation;
	}
	
	void SetTarget(const Vector &in vTarget)
	{
		this.m_vecTarget = vTarget;
	}
}

const int C_FROGATOR_REACT_RANGE = 300;
const int C_FROGATOR_ATTACK_RANGE = 250;
const float C_FROGATOR_DEFAULT_SPEED = 2.3;
class CFrogator : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	float m_fRotation;
	Model m_oModel;
	SpriteHandle m_hMove;
	SpriteHandle m_hAttack;
	int m_iSpriteIndex;
	Timer m_tmrSpriteChange;
	Timer m_tmrMayDamage;
	Timer m_tmrAttack;
	Timer m_tmrDirChange;
	Timer m_tmrStand;
	Timer m_tmrMove;
	Timer m_tmrAttackAnim;
	Timer m_tmrFlicker;
	bool m_bGotEnemy;
	float m_fSpeed;
	SoundHandle m_hAttackSound;
	int m_iSpriteAttackIndex;
	bool m_bLastGotEnemy;
	bool m_bInAttackRange;
	DamageValue m_uiHealth;
	uint m_uiFlickerCount;
	
	void LookAt(const Vector &in vPos)
	{
		//Look at position

		float flAngle = atan2(float(vPos[1] - this.m_vecPos[1]), float(vPos[0] - this.m_vecPos[0]));
		this.m_fRotation = flAngle + 6.30 / 4;
	}

	float GetAimRotation(const Vector &in vPos)
	{
		//Get aim rotation
		
		float fAngle = atan2(float(vPos[1] - this.m_vecPos[1]), float(vPos[0] - this.m_vecPos[0]));
		return fAngle - 6.30 / 4;
	}

	void Fire(IScriptedEntity@ pEntity)
	{
		//Fire lightning
		
		if ((@pEntity == null) || (!Ent_IsValid(pEntity)))
			return;
		
		CBoltEntity@ obj = CBoltEntity();
		
		Vector vTargetPos = pEntity.GetPosition();
		Vector vTargetCenter = pEntity.GetModel().GetCenter();
		Vector vAbsTargetPos = Vector(vTargetPos[0] + vTargetCenter[0], vTargetPos[1] + vTargetCenter[1]);
		
		obj.SetRotation(this.GetAimRotation(vAbsTargetPos));
		obj.SetTarget(vAbsTargetPos);
		
		Ent_SpawnEntity(@obj, this.m_vecPos);

		S_PlaySound(this.m_hAttackSound, 10);
		
		pEntity.OnDamage(45);
	}
	
	void CheckForEnemiesInRange()
	{
		//Check for enemies in close range and act accordingly
		
		this.m_bGotEnemy = false;
		this.m_bInAttackRange = false;
		IScriptedEntity@ pEntity = null;

		for (size_t i = 0; i < Ent_GetEntityCount(); i++) {
			@pEntity = Ent_GetEntityHandle(i);
			if ((pEntity.GetName() != "") && (pEntity.GetName() != this.GetName()) && (pEntity.IsDamageable() != DAMAGEABLE_NO)) {
				if (this.m_vecPos.Distance(pEntity.GetPosition()) <= C_FROGATOR_REACT_RANGE) {
					this.m_bGotEnemy = true;
					break;
				}
			}
		}
		
		if (this.m_bGotEnemy) {
			if (this.m_fSpeed == C_FROGATOR_DEFAULT_SPEED)
				this.m_fSpeed *= 2;
				
			this.LookAt(pEntity.GetPosition());

			if (this.m_vecPos.Distance(pEntity.GetPosition()) <= C_FROGATOR_ATTACK_RANGE) {
				this.m_bInAttackRange = true;
				this.m_tmrMove.SetActive(false);
				this.m_tmrAttack.Update();
				if (this.m_tmrAttack.IsElapsed()) {
					this.m_tmrAttackAnim.Reset();
					this.m_tmrAttackAnim.SetActive(true);
					this.m_iSpriteAttackIndex = 0;
					this.Fire(pEntity);
					this.m_tmrAttack.Reset();
				}
			} else {
				if ((!this.m_tmrStand.IsActive()) && (!this.m_tmrMove.IsActive())) {
					this.m_tmrStand.Reset();
					this.m_tmrStand.SetActive(true);
					this.m_iSpriteIndex = 0;
				}
			}

			this.m_bLastGotEnemy = true;
		} else {
			if (this.m_bLastGotEnemy) {
				this.m_bLastGotEnemy = false;

				this.m_tmrStand.Reset();
				this.m_tmrStand.SetActive(true);
				this.m_iSpriteIndex = 0;

				if (this.m_fSpeed != C_FROGATOR_DEFAULT_SPEED)
					this.m_fSpeed = C_FROGATOR_DEFAULT_SPEED;
			}
		}
	}
	
	void Move(void)
	{
		//Update position according to speed
		this.m_vecPos[0] += int(sin(this.m_fRotation) * this.m_fSpeed);
		this.m_vecPos[1] -= int(cos(this.m_fRotation) * this.m_fSpeed);
		
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
	
	CFrogator()
    {
		this.m_uiHealth = 25;
		this.m_fSpeed = C_FROGATOR_DEFAULT_SPEED;
		this.m_bGotEnemy = false;
    }
	
	//Called when the entity gets spawned. The position on the screen is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_fRotation = float(Util_Random(1, 360));
		this.m_hMove = R_LoadSprite(g_szToolPath + "frogator_move.png", 6, 80, 80, 6, false);
		this.m_hAttack = R_LoadSprite(g_szToolPath + "frogator_attack.png", 4, 80, 80, 4, false);
		this.m_hAttackSound = S_QuerySound(g_szToolPath + "attack.wav");
		this.m_tmrStand.SetDelay(1000);
		this.m_tmrStand.Reset();
		this.m_tmrStand.SetActive(true);
		this.m_tmrMove.SetDelay(1000);
		this.m_tmrMove.Reset();
		this.m_tmrMove.SetActive(false);
		this.m_tmrDirChange.SetDelay(5000);
		this.m_tmrDirChange.Reset();
		this.m_tmrDirChange.SetActive(true);
		this.m_tmrSpriteChange.SetDelay(50);
		this.m_tmrSpriteChange.Reset();
		this.m_tmrSpriteChange.SetActive(false);
		this.m_tmrAttack.SetDelay(1500);
		this.m_tmrAttack.Reset();
		this.m_tmrAttack.SetActive(true);
		this.m_tmrAttackAnim.SetDelay(500);
		this.m_tmrAttackAnim.Reset();
		this.m_tmrAttackAnim.SetActive(false);
		this.m_tmrFlicker.SetDelay(250);
		this.m_tmrFlicker.Reset();
		this.m_tmrFlicker.SetActive(false);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), Vector(32, 32));
		this.m_oModel.Alloc();
		this.m_oModel.SetCenter(Vector(16, 16));
		this.m_oModel.Initialize2(bbox, this.m_hMove);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
		CBloodSplash @obj = CBloodSplash();
		Ent_SpawnEntity(@obj, this.m_vecPos);
		
		SoundHandle hSplash = S_QuerySound(g_szToolPath + "splash.wav");
		S_PlaySound(hSplash, 10);
	}
	
	//Process entity stuff
	void OnProcess()
	{
		if (this.m_tmrStand.IsActive()) {
			this.m_tmrStand.Update();
			if (this.m_tmrStand.IsElapsed()) {
				this.m_tmrStand.SetActive(false);
				this.m_tmrMove.Reset();
				this.m_tmrMove.SetActive(true);
				this.m_tmrSpriteChange.Reset();
				this.m_tmrSpriteChange.SetActive(true);
				this.m_iSpriteIndex = 0;
			}
		}

		if (this.m_tmrMove.IsActive()) {
			this.m_tmrMove.Update();

			this.Move();

			if (this.m_tmrMove.IsElapsed()) {
				this.m_tmrMove.SetActive(false);
				this.m_tmrStand.Reset();
				this.m_tmrStand.SetActive(true);
				this.m_iSpriteIndex = 0;
			}
		}

		if (!this.m_tmrMove.IsActive()) {
			this.m_tmrDirChange.Update();
			if (this.m_tmrDirChange.IsElapsed()) {
				this.m_tmrDirChange.Reset();
				if (!this.m_bGotEnemy)
					this.m_fRotation = float(Util_Random(1, 360));
			}
		}

		if (this.m_tmrMove.IsActive()) {
			this.m_tmrSpriteChange.Update();
			if (this.m_tmrSpriteChange.IsElapsed()) {
				this.m_tmrSpriteChange.Reset();

				if (this.m_iSpriteIndex < 5) {
					this.m_iSpriteIndex++;
				}
			}
		}

		if (this.m_tmrAttackAnim.IsActive()) {
			this.m_tmrAttackAnim.Update();
			if (this.m_tmrAttackAnim.IsElapsed()) {
				this.m_tmrAttackAnim.Reset();

				this.m_iSpriteAttackIndex++;
				if (this.m_iSpriteAttackIndex >= 4) {
					this.m_tmrAttackAnim.SetActive(false);
				}
			}
		}

		this.CheckForEnemiesInRange();

		if (this.m_tmrFlicker.IsActive()) {
			this.m_tmrFlicker.Update();
			if (this.m_tmrFlicker.IsElapsed()) {
				this.m_tmrFlicker.Reset();
				
				this.m_uiFlickerCount++;
				if (this.m_uiFlickerCount >= 6) {
					this.m_tmrFlicker.SetActive(false);
					this.m_uiFlickerCount = 0;
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
		int red, green, blue, alpha;
		if (this.m_tmrFlicker.IsActive()) {
			red = 255;
			green = 0;
			blue = 0;
			alpha = 150;
		} else {
			red = 0;
			green = 0;
			blue = 0;
			alpha = 0;
		}
		
		bool bCustomColor = (this.m_tmrFlicker.IsActive()) && (this.m_uiFlickerCount % 2 == 0);
		
		if (this.m_bInAttackRange) {
			R_DrawSprite(this.m_hAttack, this.m_vecPos, this.m_iSpriteAttackIndex, this.m_fRotation, Vector(-1, -1), 1.5f, 1.5f, bCustomColor, Color(red, green, blue, alpha));
		} else {
			R_DrawSprite(this.m_hMove, this.m_vecPos, this.m_iSpriteIndex, this.m_fRotation, Vector(-1, -1), 1.5f, 1.5f, bCustomColor, Color(red, green, blue, alpha));
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
		return this.m_uiHealth == 0;
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
		if (this.m_uiHealth < dv) {
			this.m_uiHealth = 0;
		} else {
			this.m_uiHealth -= dv;
		}
		
		this.m_tmrFlicker.Reset();
		this.m_tmrFlicker.SetActive(true);
		this.m_uiFlickerCount = 0;
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
	
	//Return the rotation. This is actually not used by the host application, but might be useful to other entities
	float GetRotation()
	{
		return this.m_fRotation;
	}
	
	//Called for querying the damage value for this entity
	DamageValue GetDamageValue()
	{
		return 0;
	}
	
	//Return a name string here, e.g. the class name or instance name. This is used when DAMAGE_NOTSQUAD is defined as damage-type, but can also be useful to other entities
	string GetName()
	{
		return "Frogator";
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
	CFrogator @obj = CFrogator();
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
	info.szName = "Frogator";
	info.szAuthor = "Daniel Brendel";
	info.szVersion = "0.1";
	info.szContact = "dbrendel1988<at>gmail<dot>com";
	info.szPreviewImage = "preview.png";
	info.szCursor = "cursor.png";
	info.szCategory = "Monsters";
	info.iCursorWidth = 50;
	info.iCursorHeight = 50;
	info.uiTriggerDelay = 125;
	
	g_szToolPath = szToolPath;

	return true;
}