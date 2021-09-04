/**************************************************************************************************/
/**
/**	 _____ _  ____  ____  _____    ____  _____ ____  ____  ____  _        _      ____  ____  _____
/**	/    // \/  __\/ ___\/__ __\  /  __\/  __//  __\/ ___\/  _ \/ \  /|  / \__/|/  _ \/  _ \/  __/
/**	|  __\| ||  \/||    \  / \    |  \/||  \  |  \/||    \| / \|| |\ ||  | |\/||| / \|| | \||  \  
/**	| |   | ||    /\___ |  | |    |  __/|  /_ |    /\___ || \_/|| | \||  | |  ||| \_/|| |_/||  /_ 
/**	\_/   \_/\_/\_\\____/  \_/    \_/   \____\\_/\_\\____/\____/\_/  \|  \_/  \|\____/\____/\____\
/**                                                                                              
/** 2017 SkacikPL
/**
/** http://www.skacik.pl
/** https://www.nexusmods.com/witcher3/mods/1862/?
/** https://www.youtube.com/user/skacikpl
/** http://steamcommunity.com/id/skacikpl/
/** http://forums.cdprojektred.com/members/2364765-skacikpl
/** https://www.reddit.com/user/SkacikPL/ 
/**
/**************************************************************************************************/

/*=================================================================================================
  __  __       _          _____ _               
 |  \/  |     (_)        / ____| |              
 | \  / | __ _ _ _ __   | |    | | __ _ ___ ___ 
 | |\/| |/ _` | | '_ \  | |    | |/ _` / __/ __|
 | |  | | (_| | | | | | | |____| | (_| \__ \__ \
 |_|  |_|\__,_|_|_| |_|  \_____|_|\__,_|___/___/

/*==================================================================================================*/                                               
statemachine class FirstPersonCamera extends CStaticCamera
{
		var testcomp : CComponent;
		var desiredrot : EulerAngles;
		var camrot : EulerAngles;
		var lastrot : EulerAngles;
		var lastmouseX : float;
		var lastmouseY : float;
		var originalFOV	: float;
		var zoominfinished : bool;	default zoominfinished = true;
		var zoomoutfinished : bool;	default zoomoutfinished = true;
		private var curfov : float;
		editable var zoomspeed	: float; default zoomspeed = 0.01;
		var cameralerp		: float;
		var islerping		: bool;
		public var listenerhook	: FPHookListener;
		var xonlylerp		: float;
		var offsetpos		: Vector;
		var Zcorrect		: bool;		default Zcorrect = true;
		var comprot			: EulerAngles;
		var Ysensitivity	: float;	default Ysensitivity = 	1;
		var Xsensitivity	: float;	default Xsensitivity = 1;
		var storeddofint	: int;
		var controllerYinverted : bool;
		var controllermult	: int;		default controllermult = 25;
		var autowalk		: bool;		default autowalk = false;
		var mouseturn		: bool;		default mouseturn = false;		
		var awspeed			: float;	default awspeed = 0;
		var isexiting		: bool;		default isexiting = false;
		var lookattarget	: CEntity;
		var m_noSaveLock 	: int;
		var focusdoubletap	: bool;		default focusdoubletap = false;
		var isinfocusmode	: bool;		default isinfocusmode = false;
		var haspressedRMBhack :bool;	default haspressedRMBhack = false;
		var storedlightint	: int;
		var originalnearZ	: float;
		var quickstop		: bool;		default quickstop = false;
		var movcomp			: CComponent;
		var allowcombat		: bool;		default allowcombat = false;
		var forcedentry		: bool;		default forcedentry = false;
		var dofneedsreset	: bool;		default dofneedsreset = false;
		var meshcomp		: CComponent;
		var rememberedDOF	: bool;
		var headbonerot		: EulerAngles;
		var shiftedtocsmode	: bool;		default shiftedtocsmode = false;
		var attachvector : Vector;
		var attachangle : EulerAngles;
		var rootindex 	: int;
		var headindex	: int;
		var adaptivedof : bool;
		var environment : CEnvironmentDefinition;
		var m_collisionGroups 				: array<name>;
		var dofoutvec	: Vector;
		var dofoutnorm	: Vector;
		var dofdist		: float;
		var dofintensitymult : float;	default dofintensitymult = 1.0;
		var inventoryheadhack : bool;	default inventoryheadhack = false;
		default solver = CS_None;
		default blockPlayer = false;
		default resetPlayerCamera = true;

//This runs when actual w2ent is spawned in the world
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//Prepare by blocking saving and overriding some of default controls
		m_noSaveLock = 696;
		theGame.CreateNoSaveLock( "FPMODE", m_noSaveLock, true, false ); 
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'Focus' );
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'SteelSword' );		
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'SilverSword' );			
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'CastSign' );			
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'CiriDrawWeapon' );			
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'CiriDrawWeaponAlternative' );		
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'CiriSpecialAttack' );	
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'Debug_TeleportToPin' );
		theInput.UnregisterListener( thePlayer.GetInputHandler(), 'PanelInv' );	

		if(thePlayer.IsCiri())
			theInput.UnregisterListener( thePlayer.GetInputHandler(), 'ThrowItem' );	
		
		//Store original camera near Z just in case
		originalnearZ = ((CGameWorld)theGame.GetWorld()).getnearz();
		
		//Set nearZ as low as possible to avoid clipping
		((CGameWorld)theGame.GetWorld()).setnearz(0);
		//Remove camera dirt texture
		((CGameWorld)theGame.GetWorld()).setcameradirt( (CBitmapTexture)LoadResource("engine\textures\editor\black.xbm", true) );
//		((CGameWorld)theGame.GetWorld()).setcameravignette( (CBitmapTexture)LoadResource("engine\textures\editor\black.xbm", true) ); //Don't really need vignette control - it can be changed in options.
		
		//Start blending view to the FP camera
		this.Run();
		//theGame.FadeOutAsync(0.5);
		this.SetCameraState(CS_AimThrow);
		this.AddTimer( 'DelayedRun', 1.0, false );
		//Declare our actual camera
		testcomp = this.GetComponentByClassName('CCameraComponent');
		//8 milimeters is probably as low as we can go without having engine shit itself on far depths
		((CCameraComponent)testcomp).setclippingplanes(0.008,0);
		((CCameraComponent)testcomp).updateaspect();
		((CCameraComponent)testcomp).setnearplane(8);
		((CCameraComponent)testcomp).setfarplane(5);
		movcomp = thePlayer.GetComponentByClassName('CMovingAgentComponent');
		//Filthy collision ray trace for DOF focus distance, won't ignore transparent objects if they have collision. Probably dumb as fuck to call it for every frame so rip potato CPUs.
		m_collisionGroups.PushBack('Boat');
		m_collisionGroups.PushBack('Character');
		m_collisionGroups.PushBack('Corpse');
		m_collisionGroups.PushBack('Dangles');
		m_collisionGroups.PushBack('Debris');
		m_collisionGroups.PushBack('Destructible');
		m_collisionGroups.PushBack('Door');
		m_collisionGroups.PushBack('Dynamic');
		m_collisionGroups.PushBack('Fence');
		m_collisionGroups.PushBack('Foliage');
		m_collisionGroups.PushBack('Platforms');
		m_collisionGroups.PushBack('Ragdoll');
		m_collisionGroups.PushBack('RigidBody');
		m_collisionGroups.PushBack('Static');
		m_collisionGroups.PushBack('Terrain');
		m_collisionGroups.PushBack('Water');
		//Some looping timed logic
		this.AddTimer( 'CorrectFPCamera', 0, true );
		if(FactsQuerySum("FPTIMESPENT") < 65535)
			this.AddTimer( 'TrackSpentTime', 60.0f, true );	
		
		this.AddTimer( 'RegisterInputListener', 2, false );
		setcrosshair(true);
		
		//Handle persistent settings
		if(FactsDoesExist("FPZCORRECT") && FactsQuerySum("FPZCORRECT") == 0)
		{
			Zcorrect = false;
		}
		
		if(FactsDoesExist("FPFOV"))		
		{
			((CCameraComponent)testcomp).setfov(FactsQuerySum("FPFOV"));
		}
		
		if(FactsDoesExist("FPALLOWCOMBAT") && FactsQuerySum("FPALLOWCOMBAT") == 1)		
		{
			allowcombat = true;
		}		
		
		if(FactsDoesExist("FPXSENS") && FactsDoesExist("FPYSENS"))		
		{
			setsens(FactsQuerySum("FPXSENS"),FactsQuerySum("FPYSENS"));
		}	

		if(FactsDoesExist("FPDOF") && FactsQuerySum("FPDOF") == 1)		
		{
			fpdof(true);
		}
		
		if(FactsDoesExist("FPADOF") && FactsQuerySum("FPADOF") == 1)		
		{
			adaptivedof = true;
		}		
		
		fplighting(true);
		
		if(FactsDoesExist("FPCOL") && FactsQuerySum("FPCOL") == 0)		
		{
			thePlayer.EnableCharacterCollisions( false );
		}		
		
		if(FactsDoesExist("FPDONOTDISTURB") && FactsQuerySum("FPDONOTDISTURB") == 1)		
		{
			((CActor)thePlayer).SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );		
		}		
		
		if(FactsDoesExist("FPINVERTED") && FactsQuerySum("FPINVERTED") == 1)		
		{
			setinvert(true);
		}
		
		if(theGame.GetInGameConfigWrapper().GetVarValue( 'PostProcess', 'AllowDOF' ) == "true")
		{
			rememberedDOF = true;
		}
		else
		{
			rememberedDOF = false;
		}		
		
		SetupLookatTarget();
		meshcomp = thePlayer.GetComponentByClassName('CAnimatedComponent');
		rootindex = thePlayer.GetBoneIndex('Root');
		//USED ROOT
		//headindex = thePlayer.GetBoneIndex('head');
		headindex = thePlayer.GetBoneIndex('Root');
		this.AddTimer( 'DisableFinishers', 0, true );
		
		//theSound.SoundEvent("gui_global_submenu_whoosh");	
		//LogMessage("<font color=\"#C20095\">You have entered first person mode.</font><br><font color=\"#C20095\">Type </font><font color=\"#FF3939\" size=\"30\"><b>fphelp</b></font><font color=\"#C20095\"> in console to view help screen.</font>");	
	}
	
//Unused(publicly)
	function setdofintensity(val : float)
	{
		dofintensitymult = val;
	}
	
//Supporting absolutely brutal entry
	function setforced(val : bool)
	{
		forcedentry = val;
		
		if(val == true)
		{
			activationDuration = 0;
			deactivationDuration = 0;
		}
		else
		{
			activationDuration = 1;
			deactivationDuration = 1;		
		}
	}
	
//Disallow automated leaving
	timer function NoRetreat( time : float, id : int)
	{
		if(theGame.IsDialogOrCutscenePlaying())
		{
			theGame.GetInGameConfigWrapper().SetVarValue('PostProcess', 'AllowDOF', false);
			this.Run();
			dofneedsreset = true;
		}
		else
		{
			if(dofneedsreset)
			{
				theGame.GetInGameConfigWrapper().SetVarValue('PostProcess', 'AllowDOF', rememberedDOF);
				this.Run();
				
				if(FactsDoesExist("FPCOL") && FactsQuerySum("FPCOL") == 0)		
				{
					thePlayer.EnableCharacterCollisions( false );
				}					
				
				dofneedsreset = false;
			}
		}
	}	
	
//Extra detail for extra immersion
	function SetupLookatTarget()
	{
		var template : CEntityTemplate;
		var testcomp : CComponent;

		template = (CEntityTemplate)LoadResource("items\cutscenes\meat_01\meat_01.w2ent", true);
		lookattarget = theGame.CreateEntity(template, this.GetWorldPosition() + theCamera.GetCameraDirection() * 3, this.GetWorldRotation());	
		testcomp = lookattarget.GetComponentByClassName('CMeshComponent');	
		((CMeshComponent)testcomp).SetVisible(false);			
		this.AddTimer( 'UpdateLookAtTarget', 0, true );
		this.AddTimer( 'UpdateLookAtTarget2', 5.001, true );			
	}	
	
//Offload movement to AI
	function automovetomappin()
	{
		var mapManager 		: CCommonMapManager = theGame.GetCommonMapManager();
		var currWorld		: CWorld = theGame.GetWorld();
		var destWorldPath	: string;
		var id				: int;
		var area			: int;
		var type			: int;
		var position		: Vector;
		var goToCurrent		: Bool = false;
		var distance		: String;
		var posstring		: String;
			
		mapManager.GetUserMapPinByIndex( 0, id, area, position.X, position.Y, type );		
		destWorldPath = mapManager.GetWorldPathFromAreaType( area );
			
		if (destWorldPath == "" || destWorldPath == currWorld.GetPath() )
		{
			goToCurrent = true;
		}
		
		
		if ( goToCurrent )
		{
			currWorld.NavigationComputeZ(position, -500.f, 500.f, position.Z);
			currWorld.NavigationFindSafeSpot(position, 0.5f, 20.f, position);
				
			distance = FloatToStringPrec(VecDistance(thePlayer.GetWorldPosition(), position), 0);
			posstring = FloatToStringPrec(position.X, 3) + " " + FloatToStringPrec(position.Y, 3) + " " + FloatToStringPrec(position.Z, 3);
		
			if ( !currWorld.NavigationComputeZ(position, -500.f, 500.f, position.Z) )		
			{
				LogMessage("<font color=\"#C80032\">Waypoint is too far away.</font>");
				theSound.SoundEvent( "gui_global_denied" );
			}
			else
			{
				((CActor)thePlayer).ActionMoveToAsync(position, MT_AbsSpeed, awspeed * 10, 1, MFA_REPLAN);
				awspeed = 0;
				this.RemoveTimer( 'Autowalker' );
				LogMessage("<font color=\"#C20095\">Moving to waypoint at:</font> <font color=\"#224B26\">" + posstring + "</font>.<font color=\"#C20095\"> Distance: </font><font color=\"#897D02\">" + distance + "</font><font color=\"#C20095\">m.</font>");
				theSound.SoundEvent("gui_global_submenu_whoosh");			
			}
		}
		else
		{
			LogMessage("<font color=\"#C80032\">Cannot move to a waypoint in different region.</font>");
			theSound.SoundEvent( "gui_global_denied" );			
		}
	}
	
//Just allowing us to change that from outside
	function setallowcombat(val : bool)
	{
		allowcombat = val;
	}
	
//Makes FP combat less confusing
	timer function DisableFinishers( time : float, id : int)
	{
		var actors : array<CActor>;		
		var i : int;
		
		actors = GetActorsInRange(thePlayer, 30.0f, 1000000, '');
		for(i = 0; i < actors.Size(); i += 1)
		{
			if(actors[i] != thePlayer && actors[i].IsAlive() && (CNewNPC)actors[i])
			{
				actors[i].AddAbility('DisableFinishers', false);
			}
		}		
	}
	
//Move around the lookat target
	timer function UpdateLookAtTarget( time : float, id : int)
	{
		lookattarget.TeleportWithRotation(testcomp.GetWorldPosition() + 3 * ((CCameraComponent)testcomp).GetHeadingVector(), this.GetWorldRotation());
	}
	
//Either way geralt will look whereever the fuck he wants
	timer function UpdateLookAtTarget2( time : float, id : int)
	{
		thePlayer.EnableDynamicLookAt(lookattarget,5.0);
	}	
	
//Are we on a ladder?
	function isonladder() : bool
	{
		var states : CExplorationStateManager;
		states = thePlayer.substateManager;
		
		if(states.GetStateCur() == 'Interaction' && states.m_SharedDataO.GetCurentExplorationType() == ET_Ladder)
			return true;
			
		return false;
	}
	
//Moved to actual FPC class
	function hidehead()
	{
		thePlayer.SetHideInGame(true);
		// var template : CEntityTemplate;
		// var l_comp : CComponent;
		// var inv : CInventoryComponent;
		// var witcher : W3PlayerWitcher;
		// var ids : array<SItemUniqueId>;
		// var size : int;
		// var i : int;
		// var l_actor : CActor;
		
				// l_actor = thePlayer;
	
				// if(!thePlayer.IsCiri())
				// {
						// witcher = GetWitcherPlayer();
						// inv = thePlayer.GetInventory();
		
						// ids = witcher.inv.GetItemsByCategory( 'hair' );
		
						// size = ids.Size();
		
						// if( size > 0 )
						// {
			
							// for( i = 0; i < size; i+=1 )
							// {
								// if(inv.IsItemMounted( ids[i] ) )
									// {
										// inv.DespawnItem(ids[i]);
									// }
							// }
			
						// }
		
					// ids.Clear();
				// }
				// else
				// {
					// l_comp = l_actor.GetComponentByClassName( 'CAppearanceComponent' );
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\c_06_wa__ciri.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\c_01_wa__ciri.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\h_01_wa__ciri.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\h_01_wa__ciri_masked.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\h_01_wa__ciri_wounded.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\h_04_wa__ciri_crying.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);
					// template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\l_01_wa__lingerie_ciri.w2ent", true);
					// ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(template);	
				// }
				// initheadmesh();
	
	}	

//Should look more pro now.
	timer function DelayedRun( time : float, id : int)
	{
		hidehead();
		this.AddTimer( 'DelayedFadeIn', 0.1, false );
	}
	
	timer function DelayedFadeIn( time : float, id : int)
	{
		theGame.FadeInAsync(0.5);
	}
	
//Set Y axis inversion (controller only)
	function setinvert(val : bool)
	{
		controllerYinverted = val;
	}
	
//Are we inverted?
	function getinverted() : bool
	{
		return controllerYinverted;
	}

//Enable FP specific DOF
	function fpdof(enable : bool)
	{
		environment = ( CEnvironmentDefinition )LoadResource( "environment\definitions\custom\fpdof.env", true );

		if(enable)
		{
			storeddofint = ActivateEnvironmentDefinition(environment,10000,1,1.5);
			theGame.SetEnvironmentID(storeddofint);
		}
		else
		{
			DeactivateEnvironment(storeddofint,1.5);
		}
	}
	
//Enable adaptive FP specific DOF
	function fpadaptivedof(enable : bool)
	{
		// adaptivedof = enable;
		
		// if(enable == false && FactsDoesExist("FPDOF") && FactsQuerySum("FPDOF") == 1)
		// {
			// DeactivateEnvironment(storeddofint,0);
			// environment.envParams.m_depthOfField.intensity.dataCurveValues[0].lue = 2.628435;		
			// environment.envParams.m_depthOfField.nearBlurDist.dataCurveValues[0].lue = 0;
			// environment.envParams.m_depthOfField.nearFocusDist.dataCurveValues[0].lue = 4;
			// environment.envParams.m_depthOfField.farBlurDist.dataCurveValues[0].lue = 179.6091;
			// environment.envParams.m_depthOfField.farFocusDist.dataCurveValues[0].lue = 4;				
			// storeddofint = ActivateEnvironmentDefinition(environment,10000,1,0);
			// theGame.SetEnvironmentID(storeddofint);		
		// }
	}	
	
//Enable FP specific player lighting a.k.a no artificial light around player
	function fplighting(enable : bool)
	{
		var environment : CEnvironmentDefinition;

		environment = ( CEnvironmentDefinition )LoadResource( "environment\definitions\custom\fpplayerlighting.env", true );

		if(enable)
		{
			storedlightint = ActivateEnvironmentDefinition(environment,20000,1,1.5);
			theGame.SetEnvironmentID(storedlightint);
		}
		else
		{
			DeactivateEnvironment(storedlightint,1.5);
		}
	}	

//Get whether DOF is enabled
	function getdof() : bool
	{
		if(storeddofint != 0)
		{
			return true;
		}
		else
		{
			return false;	
		}

	}
	
//Get whether DOF is enabled
	function getadof() : bool
	{
		if(adaptivedof)
		{
			return true;
		}
		else
		{
			return false;	
		}

	}	
	
//Call to set sensitivity values	
	function setsens(Xval, Yval : int)
	{
		Xsensitivity = StringToFloat(Xval);
		Ysensitivity = StringToFloat(Yval);
	
		lastmouseX = 0;
		lastmouseY = 0;
	}
	
//Print to log
	public function LogMessage(m : string)
	{
		var str : string;	
	
		str = ReplaceTagsToIcons(m);
	
		theGame.GetGuiManager().ShowNotification(str, 4000);
	}
	
//Display crosshair
	function setcrosshair(enabled : bool)
	{
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleCrosshair;
	

		hud = (CR4ScriptedHud)theGame.GetHud();
		module = (CR4HudModuleCrosshair)hud.GetHudModule("CrosshairModule");
		module.ShowElement( enabled, false );	
	}
	
//Just make sure we know who's our listener
	function setlistener(val : FPHookListener)
	{
		listenerhook = val;
	}
	
//Registering input listeners for custom controls
	timer function RegisterInputListener( time : float, id : int)
	{
		//Shared
		//theInput.RegisterListener( this, 'OnLeaveFP', 'DebugInput' );
		theInput.RegisterListener( this, 'OnStartMoving', 'GI_AxisLeftY' );
		theInput.RegisterListener( this, 'OnAIMove', 'Debug_TeleportToPin' );		
	
		//Geralt
		theInput.RegisterListener( this, 'OnTurn180', 'SteelSword' );
		theInput.RegisterListener( this, 'OnCenterView', 'SilverSword' );
		theInput.RegisterListener( this, 'OnMoveFWD', 'CastSign' );	
		theInput.RegisterListener( this, 'OnInvProxy', 'PanelInv' );
		
		//Ciri
		theInput.RegisterListener( this, 'OnTurn180', 'CiriDrawWeapon' );
		theInput.RegisterListener( this, 'OnCenterView', 'CiriDrawWeaponAlternative' );
		theInput.RegisterListener( this, 'OnMoveFWD', 'CiriSpecialAttack' );
		
		if(thePlayer.IsCiri())
		{
			theInput.RegisterListener( this, 'OnZoomView', 'ThrowItem' );
		}
		else
		{
			theInput.RegisterListener( this, 'OnZoomView', 'Focus' );
		}
	}

//Dirty inventory head hack
	event OnInvProxy( action : SInputAction )
	{
		if( IsReleased( action ) )
		{
			removeheadmesh();

			if ( theGame.IsBlackscreenOrFading() )
			{
			}
			if( thePlayer.IsActionAllowed(EIAB_OpenInventory) )		
			{
				theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenInventory);
			}			
			
			inventoryheadhack = true;
		}
	}
	
//AI autowalk
	event OnAIMove( action : SInputAction )
	{
			if( IsPressed( action ) )
		{
			if(!thePlayer.IsInCombat())
			{
				if(autowalk)
				{
					automovetomappin();
				}
				else
				{
					LogMessage("<font color=\"#C20095\">Firstly set up a map pin in your region within 600 meter distance and enable autowalk via </font>" + GetIconForKey(IK_Q) + " <font color=\"#C20095\">key.</font>");
					theSound.SoundEvent( "gui_global_denied" );	
				}
			}
		}
	}
	
//Autowalk
	event OnMoveFWD( action : SInputAction )
	{
		var	singlehack : bool;
			
		quickstop = true;
	
		if( IsPressed( action ) )
		{
			//Make sure we do our stuff only outside combat - otherwise we call default combat input event for this key
			if(!thePlayer.IsInCombat())
			{
				if(awspeed == 0 && !singlehack)
				{
					autowalk = true;
					awspeed = 0.001;
					this.AddTimer( 'Autowalker', 0, true );
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">STROLLING</font>");	
					singlehack = true;
				}		
				if(awspeed == 0.001 && !singlehack)
				{
					autowalk = true;
					awspeed = 0.4;
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">WALKING</font>");
					singlehack = true;
				}
				if(awspeed == 0.4 && !singlehack)
				{
					autowalk = true;				
					awspeed = 0.6;
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">FAST WALKING</font>");	
					singlehack = true;
				}		
				if(awspeed == 0.6 && !singlehack)
				{
					autowalk = true;				
					awspeed = 0.9;
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">JOGGING</font>");	
					singlehack = true;
				}
				if(awspeed == 0.9 && !singlehack)
				{
					autowalk = true;				
					awspeed = 1.4;
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">RUN</font>");	
					singlehack = true;
				}
				if(awspeed == 1.4 && !singlehack)
				{
					autowalk = true;				
					awspeed = 4.0;
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">SPRINT</font>");	
					singlehack = true;
				}
				if(awspeed == 4.0 && !singlehack)
				{
					awspeed = 0.0;
					autowalk = false;
					this.RemoveTimer( 'Autowalker' );
					((CMovingAgentComponent)movcomp).ForceSetRelativeMoveSpeed(0);					
					theSound.SoundEvent("gui_global_submenu_whoosh");
					LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">DISABLED</font>");		
				}
				singlehack = false;
				this.AddTimer( 'AutowalkerStop', 0.2, false );
			}
			else
			{
				thePlayer.GetInputHandler().OnCastSign(action);
			}
		}
		
		if( IsReleased(action))
		{
			if(!thePlayer.IsInCombat())
			{
				this.RemoveTimer( 'AutowalkerStop' );
				quickstop = false;
			}
		}
	}

	timer function AutowalkerStop( time : float, id : int)
	{			
		if(quickstop)
		{
			awspeed = 0.0;
			autowalk = false;
			this.RemoveTimer( 'Autowalker' );
			((CMovingAgentComponent)movcomp).ForceSetRelativeMoveSpeed(0);					
			theSound.SoundEvent("gui_global_submenu_whoosh");
			LogMessage("<font color=\"#C20095\">Autowalk mode: </font>" + "<font color=\"#6D6169\">DISABLED</font>");
		}
	}
	
	timer function Autowalker( time : float, id : int)
	{			
		((CMovingAgentComponent)movcomp).ForceSetRelativeMoveSpeed(awspeed);
	}

//Match moving direction
	event OnStartMoving( action : SInputAction )
	{
		if( IsPressed( action ) && !thePlayer.IsUsingVehicle() && thePlayer.GetPlayerAction() == PEA_None && !isonladder() && !thePlayer.IsInCombat() && !theGame.IsDialogOrCutscenePlaying() )
		{
			MatchMovementDirectionWithCamera();
		}
	}

	function MatchMovementDirectionWithCamera()
	{
		var adjustangles : EulerAngles;
			
		adjustangles = thePlayer.GetWorldRotation();
		adjustangles.Yaw = theCamera.GetCameraHeading();
		lastmouseX = 0;
		thePlayer.TeleportWithRotation(thePlayer.GetWorldPosition(),adjustangles);				
	}
	
	function MatchMovementDirectionWithCameraCont()
	{
		var adjustangles : EulerAngles;
		var mpac : CMovingPhysicalAgentComponent;
		
		mpac = (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
		adjustangles = thePlayer.GetWorldRotation();
		adjustangles.Yaw = theCamera.GetCameraHeading();
		lastmouseX = 0;
		mpac.SetRotation(adjustangles);	
	}	
	
//Fired when player leaves first person
	event OnLeaveFP( action : SInputAction )
	{
		if( IsPressed( action ) && !isexiting )
		{
			ExitFP();
		}
	}
	
//Zoom in input event
	event OnZoomView( action : SInputAction )
	{
		//If we click and hold RMB
		if( IsPressed( action ) )
		{
			//Make sure we do our stuff only outside combat - otherwise we call default combat input event for this key
			if(!thePlayer.IsInCombat())
			{		
		
			ToggleFocus();
		
			//Zoom in from the beginning
			if(zoominfinished && zoomoutfinished)
			{											
				//We better make sure we know what was our original FOV that we need to (eventually) come back to
				originalFOV = FactsQuerySum("FPFOV");
				
				if(FactsQuerySum("FPFOV") == 0)
					originalFOV = ((CCameraComponent)testcomp).getfov();
					
				this.AddTimer( 'ZoomIn', zoomspeed * ((1 / theTimer.timeDeltaUnscaled) / 60), true );	
			}			
			
			//We were zooming out but now we have to zoom in again
			if(zoominfinished && !zoomoutfinished)
			{
				this.RemoveTimer( 'ZoomOut' );
				zoomoutfinished = true;
				this.AddTimer( 'ZoomIn', zoomspeed * ((1 / theTimer.timeDeltaUnscaled) / 60), true );			
			}
			haspressedRMBhack = true;
			}
			else
			{
				thePlayer.GetInputHandler().OnExpFocus(action);
			}
		}
		//If we release RMB
		else if( IsReleased( action ) && haspressedRMBhack )
		{
			if(!thePlayer.IsInCombat())
			{
			//We were fully zoomed in but player released RMB - time to zoom out
			if(zoominfinished && zoomoutfinished)
			{
				this.AddTimer( 'ZoomOut', zoomspeed * ((1 / theTimer.timeDeltaUnscaled) / 60), true );
			}
			
			//Player released RMB while we were zooming in, cancel the process and zoom out
			if(!zoominfinished && zoomoutfinished)
			{
				this.RemoveTimer( 'ZoomIn' );
				zoominfinished = true;
				this.AddTimer( 'ZoomOut', zoomspeed * ((1 / theTimer.timeDeltaUnscaled) / 60), true );
			}
				if(!focusdoubletap)
				{
					focusdoubletap = true;
					this.AddTimer( 'ResetDoubleTap', 0.5, false );	
				}
			}
			else
			{
				thePlayer.GetInputHandler().OnExpFocus(action);
			}			
		}
	}
	
	function ToggleFocus(optional act : bool)
	{
		var focusModeController : CFocusModeController;
		
		focusModeController = theGame.GetFocusModeController();

		if(!thePlayer.IsCiri() && focusdoubletap)
		{
		
			if(!isinfocusmode)
			{
				focusModeController.Activate();
				isinfocusmode = true;
				focusdoubletap = false;
			}
			else
			{
				focusModeController.Deactivate();	
				isinfocusmode = false;
				focusdoubletap = false;
			}
		
		}
		
		if(act)
		{
			focusModeController.Deactivate();
			isinfocusmode = false;
		}		
		
	}
	
	timer function ResetDoubleTap( time : float, id : int)
	{
		focusdoubletap = false;
	}	

	timer function ZoomIn( time : float, id : int)
	{
		zoominfinished = false;
		curfov = ((CCameraComponent)testcomp).getfov();		
		
		//We always provide player with 4.5x zoom in regards to his original FOV
		if(curfov > (originalFOV / 4.5) && zoomoutfinished)
		{
			((CCameraComponent)testcomp).setfov(((CCameraComponent)testcomp).getfov() - 2);
		}
		
		if(curfov == (originalFOV / 4.5) && zoomoutfinished)
		{
			this.RemoveTimer( 'ZoomIn' );	
			zoominfinished = true;		
		}
	}
	
	timer function ZoomOut( time : float, id : int)
	{
		zoomoutfinished = false;
		curfov = ((CCameraComponent)testcomp).getfov();		
		
		if(curfov < originalFOV && zoominfinished)
		{
			((CCameraComponent)testcomp).setfov(((CCameraComponent)testcomp).getfov() + 2);
		}

		if(curfov == originalFOV && zoominfinished)
		{
			this.RemoveTimer( 'ZoomOut' );	
			zoomoutfinished = true;		
		}		
	}
	
//When we need to turn around in place - PLAYS ANIMATION FROM B&W!
	event OnTurn180( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			//We also call an event to reset the view so player won't get disoriented
			OnCenterView(action);

			//Only turn if player has B&W installed as that animation is from ep2 dlc\fpcamfix\data\gameplay\camera\firstperson
				if(!thePlayer.IsCiri())
				{
					thePlayer.PlayerStartAction( 1,'high_standing_proud_turn180_left' );					
				}
				else
				{
					thePlayer.PlayerStartAction( 1, 'high_standing_determined_turn180_left' );
				}

		}
	}	
	
//Center view so player will know what's the forward direction
	event OnCenterView( action : SInputAction )
	{
		var resetrot : EulerAngles;
		
		if( IsPressed( action ) && !islerping )
		{
			cameralerp = 0;
			this.AddTimer( 'LerpCamera', 0, true );			
		}
	}
	
//Actual view reset logic - timed linear interpolation from current position to center (0;0)
	timer function LerpCamera( time : float, id : int)
	{
		if(lastmouseX != 0 && lastmouseY != 0)
		{
			islerping = true;
			lastmouseY = LerpF( cameralerp, lastmouseY, 0 );
			lastmouseX = LerpF( cameralerp, lastmouseX, 0 );	
		
			//For some reason we have to clamp or we'll miss 0, looping the logic.
			cameralerp = ClampF(cameralerp + 0.05, 0, 1);
		}
		else
		{
				//Once view has been reset logic can be removed
				this.RemoveTimer( 'LerpCamera' );
				islerping = false;	
		}
	}
	
//Same as above but only for Yaw, useful for allowing player walk forward with mouse look
		timer function LerpCameraXonly( time : float, id : int)
	{
		if(lastmouseX != 0)
		{
			lastmouseX = LerpF( xonlylerp, lastmouseX, 0 );	
			xonlylerp = ClampF(xonlylerp + 0.01, 0, 1);
		}
		else
		{
				this.RemoveTimer( 'LerpCameraXonly' );
				xonlylerp = 0;
		}	
	}
	
//Just for keks (though it's probably a shitty idea to do it this way)
	timer function TrackSpentTime( time : float, id : int )
	{
		//let's limit it to Uint16, it's 1092 hours either way
		if(FactsQuerySum("FPTIMESPENT") < 65535)
			FactsSet( "FPTIMESPENT", FactsQuerySum("FPTIMESPENT") + 1);		
	}
	
//Pretty much handles head bob compensation and basic mouse controls
	timer function CorrectFPCamera( time : float, id : int)
	{
		
		if(controllerYinverted)
		{
			controllermult = -25;
		}
		else
		{
			controllermult = 25;
		}
		
		//Up/down axis, active if we're moving the mouse and not centering the view
		if(theInput.GetActionValue( 'GI_MouseDampY' ) != 0 && !islerping || theInput.GetActionValue( 'GI_AxisRightY' ) != 0 && !islerping)
		{
			lastmouseY = ClampF(lastmouseY + theInput.GetActionValue( 'GI_MouseDampY' ) * -1 + (theInput.GetActionValue( 'GI_AxisRightY' ) * controllermult),(-850 / Ysensitivity),(800 / Ysensitivity));
		}
		
		//Left/Right axis, also only active when we're moving the mouse whilst view is not being centered
		if(theInput.GetActionValue( 'GI_MouseDampX' ) != 0 && !islerping || theInput.GetActionValue( 'GI_AxisRightX' ) != 0 && !islerping)
		{
			this.RemoveTimer( 'LerpCameraXonly' );
			xonlylerp = 0;			
			lastmouseX = ClampF(lastmouseX + theInput.GetActionValue( 'GI_MouseDampX' ) * -1 + (theInput.GetActionValue( 'GI_AxisRightX' ) * -25),(-1200 / Xsensitivity),(1300 / Xsensitivity));
		}	
		
		
		camrot = this.GetWorldRotation();
		
		desiredrot = thePlayer.GetWorldRotation();
		//Make sure camera is actually heading in the right direction (TODO: We also need a deadzone)
		desiredrot.Yaw = (thePlayer.GetHeading() - this.GetHeading());			
		lastrot = desiredrot;
		//apply mouse controls
		lastrot.Pitch = lastrot.Pitch + lastmouseY * (0.1 * Ysensitivity);
		lastrot.Yaw = lastrot.Yaw + lastmouseX * (0.05 * Xsensitivity);
		
		//Camera is bound to the root for stability so we need to manually adjust Z/Y positions to match head bone
		offsetpos = Vector(0,0,0,1);
		if(Zcorrect)
		{
			if(!thePlayer.IsCiri())
			{
				offsetpos.Z = VecDistance(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head')) - 1.73;			
			}
			else
			{
				offsetpos.Z = VecDistance(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head')) - 1.8;	
			}
		
		}
		offsetpos.X = 0;
		
		//Filthy dirty hack
		if(!isonladder() && !thePlayer.IsSwimming () )
		{
			offsetpos.Y = 0.35 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));
			
			if ( thePlayer.IsCiri() ){
				offsetpos.Y = 0.25 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));}
			
		if( thePlayer.GetIsWalking() && !mouseturn || awspeed == 0.001 && thePlayer.IsMoving() && !mouseturn || awspeed ==  0.4 && thePlayer.IsMoving() && !mouseturn )
		{
			offsetpos.Y = 0.50 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));
			
			if ( thePlayer.IsCiri() ){
				offsetpos.Y = 0.35 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));}			
		}
		
		if( thePlayer.GetIsRunning() && !mouseturn || awspeed == 0.6 && thePlayer.IsMoving() && !mouseturn || awspeed == 0.9 && thePlayer.IsMoving() && !mouseturn)
		{
			offsetpos.Y = 0.60 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));
			
			if ( thePlayer.IsCiri() ){
				offsetpos.Y = 0.60 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));}			
		}

		if( thePlayer.GetIsSprinting() && !mouseturn || awspeed == 1.4 && thePlayer.IsMoving() && !mouseturn || awspeed == 4.0 && thePlayer.IsMoving() && !mouseturn )
		{
			offsetpos.Y = 0.75 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));
			
			if ( thePlayer.IsCiri() ){
				offsetpos.Y = 0.65 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));}			
		}		

		}
		else
		{
			offsetpos.Y = 0.30 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));
			if ( thePlayer.IsCiri() ){
				offsetpos.Y = 0.20 + VecDistance2D(thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetBoneWorldPosition('head'));}			
		}
		
		//offset roll
		comprot = thePlayer.GetWorldRotation();
		lastrot.Roll = comprot.Roll * -1;
		
		//Override for dialogues/cutscenes
		// if(theGame.IsDialogOrCutscenePlaying() && forcedentry)
		// {
			// if(this.GetWorldPosition() != thePlayer.GetBoneWorldPosition('head') && !shiftedtocsmode)
			// {
				// this.BreakAttachment();
				// CreateAttachmentAtBoneWS( thePlayer, 'head', thePlayer.GetBoneWorldPosition('head') + Vector(0,0,0.15,1), thePlayer.GetBoneWorldRotationByIndex(rootindex) );
			// }
			// offsetpos = VecFromHeading( theCamera.GetCameraHeading() - meshcomp.GetHeading() ) * 0.2;
			// headbonerot = this.GetWorldRotation();
			// //offset roll
			// if(headbonerot.Roll != 0)
			// {
				// lastrot.Roll = headbonerot.Roll * -1;				
			// }
			// shiftedtocsmode = true;			
		// }
		// if(!theGame.IsDialogOrCutscenePlaying() && forcedentry)
		// {
			// if(shiftedtocsmode)
			// {
				// attachvector = thePlayer.GetBoneWorldPosition('Root');
				// attachvector.Z = attachvector.Z + 1.85;
				// attachangle = thePlayer.GetWorldRotation();
				// attachangle.Pitch = 0;	
				// attachangle.Roll = 0;		
				// this.BreakAttachment();
				// CreateAttachmentAtBoneWS( thePlayer, 'Root', attachvector, attachangle );			
				// this.AddTimer( 'UpdateCSDAttachment', 0.5, false );		
				// shiftedtocsmode = false;
			// }
		// }
		if(forcedentry){
				attachvector = thePlayer.GetBoneWorldPosition('Root');
				attachvector.Z = attachvector.Z + 1.85;
				attachangle = thePlayer.GetWorldRotation();
				attachangle.Pitch = 0;	
				attachangle.Roll = 0;		
				this.BreakAttachment();
				CreateAttachmentAtBoneWS( thePlayer, 'Root', attachvector, attachangle );			
				this.AddTimer( 'UpdateCSDAttachment', 0.5, false );		
				shiftedtocsmode = false;
		}
		
		//Apply final controls and offsets for the tick	
		testcomp.SetRotation(lastrot);
		testcomp.SetPosition(offsetpos);
		
		//Yaw centering logic when player is moving and not moving his mouse - TESTREMOVED
		if(theInput.GetActionValue( 'GI_MouseDampX' ) == 0 && !islerping && thePlayer.GetMovingAgentComponent().GetSpeed() > 0 && !autowalk && !mouseturn)
		{
			this.AddTimer( 'LerpCameraXonly', 0, true );
		}	

		//Setup automated exit points
		if(!forcedentry)
		{
			if(theGame.IsDialogOrCutscenePlaying() && !isexiting || thePlayer.IsInCombat() && !allowcombat || thePlayer.GetIsHorseMounted() && !isexiting || thePlayer.GetActivePoster() && !isexiting )
			{
				ExitFP();
			}
		}
		else
		{
		}
		
		mouseturn = false;
		
		//Turning player in place when end of dead zone is reached from left or right side
		if(lastmouseX == -1200 && !autowalk && !thePlayer.IsUsingVehicle() && thePlayer.GetPlayerAction() == PEA_None && !isonladder() && theGame.IsDialogOrCutscenePlaying())
		{
			comprot.Yaw = comprot.Yaw - (Xsensitivity * 3) * ( 60 / (1 / theTimer.timeDeltaUnscaled) );
			thePlayer.TeleportWithRotation(thePlayer.GetWorldPosition(),comprot);
			lastmouseX = lastmouseX + 1;
		}
		
		if(lastmouseX == 1300 && !autowalk && !thePlayer.IsUsingVehicle() && thePlayer.GetPlayerAction() == PEA_None && !isonladder() && theGame.IsDialogOrCutscenePlaying())
		{
			comprot.Yaw = comprot.Yaw + (Xsensitivity * 3) * ( 60 / (1 / theTimer.timeDeltaUnscaled) );
			thePlayer.TeleportWithRotation(thePlayer.GetWorldPosition(),comprot);
			lastmouseX = lastmouseX - 1;	
		}

		if(lastmouseX == -1200 && !autowalk || lastmouseX == -1199 && !autowalk || lastmouseX == 1300 && !autowalk || lastmouseX == 1299 && !autowalk && theGame.IsDialogOrCutscenePlaying())
		{
			mouseturn = true;
		}
		
		//Manage adaptive DOF probably really heavy due to constant env reloading and firing a trace for each frame
		if(FactsDoesExist("FPDOF") && FactsQuerySum("FPDOF") == 1 && adaptivedof && theGame.GetInGameConfigWrapper().GetVarValue( 'PostProcess', 'AllowDOF' ) == "true")
		{
			DeactivateEnvironment(storeddofint,0);
			theGame.GetWorld().StaticTrace( testcomp.GetWorldPosition(), testcomp.GetWorldPosition() + ((CCameraComponent)testcomp).GetWorldForward() * 50000, dofoutvec, dofoutnorm, m_collisionGroups );
			dofdist = VecDistance2D(testcomp.GetWorldPosition(), dofoutvec);
			//Clamp minimal distance so we don't get short sightedness simulator when looking at our own feet
			if(dofdist < 0.85)
			{
				dofdist = 0.85;
			}
			// environment.envParams.m_depthOfField.intensity.dataCurveValues[0].lue = 3 * dofintensitymult;		
			// environment.envParams.m_depthOfField.nearBlurDist.dataCurveValues[0].lue = dofdist * 1.3;
			// environment.envParams.m_depthOfField.nearFocusDist.dataCurveValues[0].lue = dofdist * 1.8;
			// environment.envParams.m_depthOfField.farBlurDist.dataCurveValues[0].lue = dofdist * 4.5;
			// environment.envParams.m_depthOfField.farFocusDist.dataCurveValues[0].lue = dofdist * 2;				
			// storeddofint = ActivateEnvironmentDefinition(environment,10000,1,0);
			// theGame.SetEnvironmentID(storeddofint);			
		}
		
		//Dirty hack to restore fp head when exiting inventory
		if(inventoryheadhack)
		{
			this.AddTimer( 'ExitInvFPHead', 0.016, false );
			inventoryheadhack = false;
		}
	}
	
	function getadofist() : float
	{
		return dofdist;
	}
	
//Needs to be delayed or we call it same tick as we restore the head	
	timer function ExitInvFPHead( time : float, id : int)
	{
		initheadmesh();
	}	
	
//Crappy hack - won't be accurate if player body starts scene rotated or tilted.
	timer function UpdateCSDAttachment( time : float, id : int)
	{
		if(theGame.IsDialogOrCutscenePlaying() && forcedentry)
		{
			attachvector = thePlayer.GetBoneWorldPosition('Root');
			attachvector.Z = attachvector.Z + 1.85;
			attachangle = thePlayer.GetWorldRotation();
			attachangle.Pitch = 0;	
			attachangle.Roll = 0;		
			this.BreakAttachment();
			CreateAttachmentAtBoneWS( thePlayer, 'Root', attachvector, attachangle );
		}
	}
	
	function setzcorrect(val : bool)
	{
		Zcorrect = val;
	}
	
	function getzcorrect() : bool
	{
		return Zcorrect;
	}
	
//Grouped logic fired when leaving FP mode
	function ExitFP()
	{	
		isexiting = true;
		this.RemoveTimer( 'ExitInvFPHead' );
		
		if(isinfocusmode)
			ToggleFocus(true);
		
		//theGame.FadeOutAsync(0.2);
		
		((CMovingAgentComponent)movcomp).ForceSetRelativeMoveSpeed(0);			
		
		//For some weird reason that's the only way how it works as intended
		if(!theGame.IsDialogOrCutscenePlaying())
		{
			if(!thePlayer.GetIsHorseMounted())
			{
				if(!thePlayer.GetActivePoster())
				{
					this.RemoveTimer( 'NoRetreat' );
					theGame.GetGameCamera().Activate( 1 );					
				}			
			}
		}
		this.AddTimer( 'DelayedRestore', 1, false );
		//Shared
		//theInput.UnregisterListener( this, 'DebugInput' );
		theInput.UnregisterListener( this, 'GI_AxisLeftY' );	
		theInput.UnregisterListener( this, 'Debug_TeleportToPin' );		

		//Geralt
		theInput.UnregisterListener( this, 'SteelSword' );
		theInput.UnregisterListener( this, 'SilverSword' );	
		theInput.UnregisterListener( this, 'Focus' );
		theInput.UnregisterListener( this, 'CastSign' );
		theInput.UnregisterListener( this, 'PanelInv' );
		
		//Ciri
		theInput.UnregisterListener( this, 'CiriDrawWeapon' );
		theInput.UnregisterListener( this, 'CiriDrawWeaponAlternative' );
		theInput.UnregisterListener( this, 'CiriSpecialAttack' );		
		
		if(thePlayer.IsCiri())
			theInput.UnregisterListener( this, 'ThrowItem' );		

		thePlayer.GetInputHandler().Initialize(false);
		setcrosshair(false);
		if(FactsDoesExist("FPDOF") && FactsQuerySum("FPDOF") == 1)		
		{
			adaptivedof = false;
			fpdof(false);
		}
		if(FactsDoesExist("FPDONOTDISTURB") && FactsQuerySum("FPDONOTDISTURB") == 1)		
		{
			((CActor)thePlayer).SetTemporaryAttitudeGroup( 'player', AGP_Default );		
		}
		
		fplighting(false);
		
		this.RemoveTimer( 'CorrectFPCamera' );			
		this.RemoveTimer( 'TrackSpentTime' );
		this.RemoveTimer( 'Autowalker' );
		this.RemoveTimer( 'LerpCameraXonly' );		
		this.RemoveTimer( 'ZoomIn' );			
		this.RemoveTimer( 'ZoomOut' );		
		this.RemoveTimer( 'LerpCamera' );		
		this.RemoveTimer( 'UpdateLookAtTarget' );		
		this.RemoveTimer( 'UpdateLookAtTarget2' );
		this.RemoveTimer( 'DisableFinishers' );
		thePlayer.DisableLookAt();
		this.AddTimer( 'DelayedDestroy', 3.01, false );
		this.AddTimer( 'DelayedFadeIn', 1.05 );
		
		thePlayer.EnableCharacterCollisions( true );
		
		//Set nearZ back to original value
		((CGameWorld)theGame.GetWorld()).setnearz(originalnearZ);
		//Restore camera dirt texture
		((CGameWorld)theGame.GetWorld()).setcameradirt( (CBitmapTexture)LoadResource("fx\textures\flares\fullscreen_flare01.xbm", true) );
//		((CGameWorld)theGame.GetWorld()).setcameravignette( (CBitmapTexture)LoadResource("fx\vignette\vignette.xbm", true) ); //Don't really need vignette control - it can be changed in options.
		
		theGame.ReleaseNoSaveLock(m_noSaveLock);
		
		//theSound.SoundEvent("gui_global_submenu_whoosh");
		
		//LogMessage("<font color=\"#C20095\">You have left first person mode.</font>");		
	}
	
//Spawn invisible head model
	function initheadmesh()
	{
		var l_actor : CActor;
		var l_comp : CComponent;
		var acs : array< CComponent >;		


		l_actor = thePlayer;
		l_comp = l_actor.GetComponentByClassName( 'CAppearanceComponent' );	
		
		if(!thePlayer.IsCiri())
		{
			acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( 'head_firstperson' );					
		}
		else
		{
			((CAppearanceComponent)l_comp).IncludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri1.w2ent", true));
			((CAppearanceComponent)l_comp).IncludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri2.w2ent", true));
			((CAppearanceComponent)l_comp).IncludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri3.w2ent", true));				
		}

	}
	
//Remove invisible head model
	function removeheadmesh()
	{
		var l_actor : CActor;
		var l_comp : CComponent;
		var acs : array< CComponent >;
		var barberHead : name;		


		l_actor = thePlayer;
		l_comp = l_actor.GetComponentByClassName( 'CAppearanceComponent' );	
		
		if(!thePlayer.IsCiri())
		{
			acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );		
			barberHead = thePlayer.GetRememberedCustomHead();
		
			if( IsNameValid(barberHead) )
			{
				( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( barberHead );
			}
			else
			{
				( ( CHeadManagerComponent ) acs[0] ).RemoveCustomHead();
			}
		}
		else
		{
			((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri1.w2ent", true));
			((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri2.w2ent", true));
			((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate((CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstpersonheadCiri3.w2ent", true));			
		}
	}	
	
//We also need to restore actual player head and hair when leaving FP
	timer function DelayedRestore( time : float, id : int)
	{
		if(!thePlayer.IsCiri())
		{
			removeheadmesh();
			CheckHairItem();
		}
		else
		{
			RestoreCiri();
		}
	}
	
//Restore head and hair for Ciri
	function RestoreCiri()
	{
		var l_comp : CComponent;
		var template : CEntityTemplate;	
		
		l_comp = thePlayer.GetComponentByClassName( 'CAppearanceComponent' );		
		
		template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\c_01_wa__ciri.w2ent", true);
		((CAppearanceComponent)l_comp).IncludeAppearanceTemplate(template);
		template = (CEntityTemplate)LoadResource("characters\models\main_npc\ciri\h_01_wa__ciri.w2ent", true);
		((CAppearanceComponent)l_comp).IncludeAppearanceTemplate(template);		
	}

//Restore Hair
	private function CheckHairItem()
	{
		var ids : array<SItemUniqueId>;
		var i   : int;
		var itemName : name;
		var hairApplied : bool;
		
		ids = thePlayer.inv.GetItemsByCategory('hair');
		
		for(i=0; i<ids.Size(); i+= 1)
		{
			itemName = thePlayer.inv.GetItemName( ids[i] );
			
			if( itemName != 'Preview Hair' )
			{
				if( hairApplied == false )
				{
					thePlayer.inv.MountItem( ids[i], false );
					hairApplied = true;
				}
				else
				{
					thePlayer.inv.RemoveItem( ids[i], 1 );
				}
				
			}
		}
		
		if( hairApplied == false )
		{
			ids = thePlayer.inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
			thePlayer.inv.MountItem( ids[0], false );
		}
		
	}	
	
//Restore head
	private function CheckHeadItem()
	{
		var ids : array<SItemUniqueId>;
		var i   : int;
		var itemName : name;
		var headApplied : bool;
		
		ids = thePlayer.inv.GetItemsByCategory('head');
		
		for(i=0; i<ids.Size(); i+= 1)
		{
			itemName = thePlayer.inv.GetItemName( ids[i] );
			
				if( headApplied == false )
				{
					thePlayer.inv.MountItem( ids[i], false );
					headApplied = true;
				}
				else
				{
					thePlayer.inv.RemoveItem( ids[i], 1 );
				}
				
			
		}
		
		if( headApplied == false )
		{
			ids = thePlayer.inv.AddAnItem('head_0', 1, true, false);
			thePlayer.inv.MountItem( ids[0], false );
		}
		
	}	
	
//Once we're entirely done with exiting logic - commit suicide
	timer function DelayedDestroy( time : float, id : int)
	{
		listenerhook.StartListener(true);
		lookattarget.Destroy();
		this.Destroy();
	}
}

/*=================================================================================================
   _____                      _      
  / ____|                    | |     
 | |     ___  _ __  ___  ___ | | ___ 
 | |    / _ \| '_ \/ __|/ _ \| |/ _ \
 | |___| (_) | | | \__ \ (_) | |  __/
  \_____\___/|_| |_|___/\___/|_|\___|
                                                                       

/*==================================================================================================*/

//Set camera FOV through console
	exec function fpsetfov(val : float)
	{
		var ent : CEntity;
		var l_comp : CComponent;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		l_comp = ent.GetComponentByClassName('CCameraComponent');
	
		if(val > 110)
			val = 110;
		
		if(val <= 0)
			val = 1;
	
		theSound.SoundEvent("gui_global_clock_tick_stop");	
		((CCameraComponent)l_comp).setfov(val);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FOV set to: </font>" + "<font color=\"#6D6169\">" + RoundF(((CCameraComponent)l_comp).getfov()) + "</font>");	
		FactsSet("FPFOV",RoundF(val));	
	}

//Enable do-not-disturb mode
	exec function fpdonotdisturb(val : bool)
	{
		var ent : CEntity;
		var booltoint : int;
	
	//REALLY?
		if(val)
		{
			booltoint = 1;
			((CActor)thePlayer).SetTemporaryAttitudeGroup( 'q104_avallach_friendly_to_all', AGP_Default );		
		}
		else
		{
			booltoint = 0;
			((CActor)thePlayer).SetTemporaryAttitudeGroup( 'player', AGP_Default );			
		}
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		theSound.SoundEvent("gui_global_clock_tick_stop");	
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">Do not disturb mode enabled: </font>" + "<font color=\"#6D6169\">" + val + "</font>");
		FactsSet("FPDONOTDISTURB",booltoint);	
	}

//Enable disable Z correction
	exec function fpzcorrect(val : bool)
	{
		var ent : CEntity;
		var booltoint : int;
	
	//REALLY?
		if(val)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}

		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		theSound.SoundEvent("gui_global_clock_tick_stop");		
		((FirstPersonCamera)ent).setzcorrect(booltoint);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">Head bobbing enabled: </font>" + "<font color=\"#6D6169\">" + ((FirstPersonCamera)ent).getzcorrect() + "</font>");
		FactsSet("FPZCORRECT",booltoint);	
	}

//FP DOF
	exec function fpsetdof(val : bool)
	{
		var ent : CEntity;
		var booltoint : int;
	
	//REALLY?
		if(val)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		theSound.SoundEvent("gui_global_clock_tick_stop");		
		((FirstPersonCamera)ent).fpdof(val);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP DOF enabled: </font>" + "<font color=\"#6D6169\">" + ((FirstPersonCamera)ent).getdof() + "</font>");
		FactsSet("FPDOF",booltoint);	
	}
	
//FP ADAPTIVE DOF
	exec function fpsetdofadaptive(val : bool)
	{
		var ent : CEntity;
		var booltoint : int;
	
	//REALLY?
		if(val)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		theSound.SoundEvent("gui_global_clock_tick_stop");		
		((FirstPersonCamera)ent).fpadaptivedof(val);
		
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP adaptive DOF enabled: </font>" + "<font color=\"#6D6169\">" + ((FirstPersonCamera)ent).getadof() + "</font>");
		FactsSet("FPADOF",booltoint);	
	}	
	
//FP Inverted Y axis
	exec function fpinverty(val : bool)
	{
		var ent : CEntity;
		var booltoint : int;
	
	//REALLY?
		if(val)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		theSound.SoundEvent("gui_global_clock_tick_stop");		
		((FirstPersonCamera)ent).setinvert(val);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP Controller vertical axis inverted: </font>" + "<font color=\"#6D6169\">" + ((FirstPersonCamera)ent).getinverted() + "</font>");
		FactsSet("FPINVERTED",booltoint);	
	}	

//Initialize input listener
	exec function fphook()
	{
		var listener	: FPHookListener;
		var ent : CEntity;	
	
		listener = new FPHookListener in thePlayer.GetInputHandler();
		listener.StartListener();
	}

//show settings
	exec function fpsettings()
	{
		var title : string;
		var fovmess : string;
		var headbob : string;
		var headbobval : string;
		var mouseXval	: string;
		var mouseYval	: string;
		var dofmess		: string;
		var dofval		: string;
		var disturbmess	: string;
		var disturbval	: string;
		var invertmess	: string;
		var invertval	: string;
		var noentmess	: string;
		var colval		: string;
		var colmess		: string;
		var combval		: string;
		var combmess	: string;
		var adofval		: string;
		var adofmess	: string;
		var ent : CEntity;
		var l_comp : CComponent;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		l_comp = ent.GetComponentByClassName('CCameraComponent');

		if(FactsQuerySum("FPZCORRECT") == 1)
			headbobval = "true";
	
		if(FactsQuerySum("FPZCORRECT") == 0)
			headbobval = "false";
	
		if(FactsQuerySum("FPDOF") == 1)
			dofval = "true";
	
		if(FactsQuerySum("FPDOF") == 0)
			dofval = "false";	
	
		if(FactsQuerySum("FPDONOTDISTURB") == 1)
			disturbval = "true";
	
		if(FactsQuerySum("FPDONOTDISTURB") == 0)
			disturbval = "false";		
			
		if(FactsQuerySum("FPINVERTED") == 1)
			invertval = "true";
	
		if(FactsQuerySum("FPINVERTED") == 0)
			invertval = "false";	
			
		if(FactsQuerySum("FPCOL") == 1)
			colval = "true";
	
		if(FactsQuerySum("FPCOL") == 0)
			colval = "false";			

		if(FactsQuerySum("FPALLOWCOMBAT") == 1)
			combval = "true";
	
		if(FactsQuerySum("FPALLOWCOMBAT") == 0)
			combval = "false";

		if(FactsQuerySum("FPADOF") == 1)
			adofval = "true";
	
		if(FactsQuerySum("FPADOF") == 0)
			adofval = "false";				
			
		noentmess = "<font color=\"#FF0000\" size=\"26\" ><br><br><center><b>No first person camera entity found!</b></center></font>";

		if(ent)
			noentmess = "";

		title = "<font color=\"#FAAC34\" size=\"28\" ><u>First person mode settings</u></font>";
		fovmess = "<font color=\"#40E0D0\">FOV: " + RoundF(FactsQuerySum("FPFOV")) + "</font>";
		headbob = "<font color=\"#C8A2C8\">Head bobbing enabled: " + headbobval + "</font>";
		mouseXval = "<font color=\"#FD9E81\">Mouse X axis sensitivity(horizontal): " + RoundF(FactsQuerySum("FPXSENS")) + "</font>";
		mouseYval = "<font color=\"#9692B2\">Mouse Y axis sensitivity(vertical): " + RoundF(FactsQuerySum("FPYSENS")) + "</font>";
		dofmess = "<font color=\"#95C200\">First person depth of field enabled: " + dofval + "</font>";
		disturbmess = "<font color=\"#C047AD\">Do not disturb mode enabled: " + disturbval + "</font>";
		invertmess = "<font color=\"#9F86FF\">Controller Y axis inverted: " + invertval + "</font>";
		colmess = "<font color=\"#0F4D86\">First person character collision enabled: " + colval + "</font>";
		combmess = "<font color=\"#AB4621\">First person combat allowed: " + combval + "</font>";		
		adofmess = "<font color=\"#088DA5\">First person adaptive depth of field enabled: " + adofval + "</font>";

		theSound.SoundEvent("gui_global_panel_open");
		theGame.GetGuiManager().ShowUserDialogAdv(0, title, "<br><p align=\"justify\">" + fovmess + "<br>" + headbob + "<br>" + mouseXval + "<br>" + mouseYval + "<br>" + dofmess + "<br>" + disturbmess + "<br>" + invertmess + "<br>" + colmess + "<br>" + combmess + "<br>" + adofmess + "<br>" + noentmess + "<br></p>", false, UDB_Ok);
	}

//show time spent in first person mode
	exec function fptime()
	{
		var title : string;
		var timemess : string;
		var rank	: string;
		var conj	: string;

		conj = "s.";

		if(FactsQuerySum("FPTIMESPENT") == 1)
			conj = ".";

		title = "<font color=\"#FAAC34\" size=\"28\" ><u>Time spent in first person mode</u></font>";
		timemess = "Time spent in first person mode: " + FactsQuerySum("FPTIMESPENT") + " minute" + conj;

		if(FactsQuerySum("FPTIMESPENT") >= 65535)
			timemess = "Time spent in first person mode: 65535+ minutes.";

		//Setup the ranks
		if(FactsQuerySum("FPTIMESPENT") <= 14)
			rank = "<font color=\"#F6546A\"><b>A TOURIST</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 15)
			rank = "<font color=\"#FD7D5F\"><b>AN OBSERVER</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 30)
			rank = "<font color=\"#839D57\"><b>AN EXPLORER</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 45)
			rank = "<font color=\"#00A386\"><b>A DISCOVERER</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 60)
			rank = "<font color=\"#00c6d2\"><b>FAN OF NEW EXPERIENCES</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 90)
			rank = "<font color=\"#41E9A8\"><b>HOOKED ON THE NEW PERSPECTIVE</b></font>";

		if(FactsQuerySum("FPTIMESPENT") >= 120)
			rank = "<font color=\"#FDD8C5\"><b>RELENTLESS CURIOSITY</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 180)
			rank = "<font color=\"#FDEBB9\"><b>EXPERIENCING THE WORLD ANEW</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 240)
			rank = "<font color=\"#AE991E\"><b>EVERYWHERE ON FOOT</b></font>";
	
		if(FactsQuerySum("FPTIMESPENT") >= 300)
			rank = "<font color=\"#F9DB2B\"><b>PROBABLY AFK</b></font>";


		theSound.SoundEvent("gui_global_panel_open");
		theGame.GetGuiManager().ShowUserDialogAdv(0, title, "<br><p align=\"justify\">" + timemess + "</p><br><br><p align=\"center\">" + rank + "</p>", false, UDB_Ok);
	}

//Ingame help
	exec function fphelp()
	{
		var title : string;
		var message : string;
		var userpart : string;
		var mousepart : string;
		var mmbpart		: string;
		var bracketOpeningSymbol : string;
		var bracketClosingSymbol : string;

		userpart = theGame.GetActiveUserDisplayName();
		if(userpart != "")
		{
			userpart = ", <font color=\"#FFFFFF\"><i>" + theGame.GetActiveUserDisplayName() + "</i></font>.";
		}
		else
		{
			userpart = "!";
		}

		GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);

		title = "<font color=\"#FAAC34\" size=\"28\" ><u>First person mode help</u></font>";
		mousepart = " " + bracketOpeningSymbol + "<font color=\"" + theGame.params.KEYBOARD_KEY_FONT_COLOR + "\">Right Mouse Button</font>" + bracketClosingSymbol + " ";
		mmbpart = " " + bracketOpeningSymbol + "<font color=\"" + theGame.params.KEYBOARD_KEY_FONT_COLOR + "\">Middle Mouse Button</font>" + bracketClosingSymbol + " ";
		message = "Hello and welcome to the <font color=\"#FF3939\"> First Person Mod</font>" + userpart + "<br>Mod is hooked by using <font color=\"#FF3939\">fphook</font> command. To change your field of view use <font color=\"#FF3939\">fpsetfov(x)</font> command (replace x with your desired FOV value). You can toggle head bobbing on or off with <font color=\"#FF3939\">fpzcorrect(0/1)</font>, your current FP settings can be checked by using <font color=\"#FF3939\">fpsettings</font> command. Mouse sensitivity can be adjusted via <font color=\"#FF3939\">fpsens(X,Y)</font> command. Entering/exiting first person mode is done by pressing" + GetIconForKey(IK_P) + "key on the keyboard. Additionally, first person specific DOF can be enabled or disabled by using <font color=\"#FF3939\">fpsetdof(0/1)</font> command (and changed to adaptive focus mode through <font color=\"#FF3939\">fpsetdofadaptive(0/1)</font> command), combat avoidance mode can be enabled by using <font color=\"#FF3939\">fpdonotdisturb(0/1)</font> command, vertical axis can be inverted for controller by using <font color=\"#FF3939\">fpinverty(0/1)</font> command. When in first person mode, you can press" + GetIconForKey(IK_1) + "to do a 180 degree turn," + GetIconForKey(IK_2) + "to center your view and" + mousepart + "to zoom in the view (" + mmbpart + "If you're currently playing as Ciri). Collison with other characters can be enabled or disabled via <font color=\"#FF3939\">fpcollision(0/1)</font> command, press " + GetIconForKey(IK_Q) + " to enable autowalk/free look mode.<br>Combat can be enabled in first person mode through the <font color=\"#FF3939\">fpallowcombat(0/1)</font> command.<br>Autopilot is enabled by pressing " + GetIconForKey(IK_NumPad4) + ".<br>You can bring the help screen back at any time by writing <font color=\"#FF3939\">fphelp</font> in console.";

		theSound.SoundEvent("gui_global_panel_open");
		theGame.GetGuiManager().ShowUserDialogAdv(0, title, "<p align=\"justify\">" + message + "</p>" + "<br><br><br><p align=\"right\"> <font color=\"#003466\" alpha=\"#1B\">Created by: SkacikPL</font></p>", false, UDB_Ok);
	}

//Change mouse sensitivty for FP
	exec function fpsens(Xval, Yval : int)
	{
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );

		//Clamp that shit, bro
		Xval = Clamp(Xval,0,100);
		Yval = Clamp(Yval,0,100);

		theSound.SoundEvent("gui_global_clock_tick_stop");
		((FirstPersonCamera)ent).setsens(Xval,Yval);
		FactsSet("FPXSENS",Xval);
		FactsSet("FPYSENS",Yval);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP mouse sensitivity set to : </font>" + "<font color=\"#6D6169\">" + FactsQuerySum("FPXSENS") + " on X axis, and " + FactsQuerySum("FPYSENS") + " on Y axis." + "</font>");
	}
	
//Change adaptive dof intensity multiplier
	exec function fpsetadofintensity(intensity : float)
	{
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );

		theSound.SoundEvent("gui_global_clock_tick_stop");
		((FirstPersonCamera)ent).setdofintensity(intensity);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP adaptive DOF intensity set to : </font>" + "<font color=\"#6D6169\">" + FloatToString(intensity) + "</font>");
	}
	
//Debug get dof distance
	exec function fpgetadofdist()
	{
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );

		theSound.SoundEvent("gui_global_clock_tick_stop");
		((FirstPersonCamera)ent).LogMessage( FloatToString( ((FirstPersonCamera)ent).getadofist() ) );
	}		
	
//Change player character collision preference
	exec function fpcollision(enable : bool)
	{
		var booltoint : int;
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );	
	//REALLY?
		if(enable)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}	
		
		theSound.SoundEvent("gui_global_clock_tick_stop");
		FactsSet("FPCOL",booltoint);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">FP player character collison enabled : </font>" + "<font color=\"#6D6169\">" + enable + "</font>");
		thePlayer.EnableCharacterCollisions( enable );
	}	

//Allow player to enter combat in first person
	exec function fpallowcombat(enable : bool)
	{
		var booltoint : int;
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );	
	//REALLY?
		if(enable)
		{
			booltoint = 1;
		}
		else
		{
			booltoint = 0;
		}	
		
		theSound.SoundEvent("gui_global_clock_tick_stop");
		FactsSet("FPALLOWCOMBAT",booltoint);
		((FirstPersonCamera)ent).setallowcombat(enable);
		((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">First person combat allowed : </font>" + "<font color=\"#6D6169\">" + enable + "</font>");
	}

	exec function fpnoautoleaving(val : bool)
	{
		var ent : CEntity;
		
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		if(ent)
		{
			if(val == true)
			{
				((FirstPersonCamera)ent).setforced(true);	
				((FirstPersonCamera)ent).AddTimer( 'NoRetreat', 0, true );
				theGame.GetGuiManager().ShowUserDialogAdv(0, "Auto leaving disabled", "This mode is NOT officially supported, it may cause more issues than it's worth and as such this setting will not be remembered.", false, UDB_Ok);
			}
			else
			{
				((FirstPersonCamera)ent).setforced(false);	
				((FirstPersonCamera)ent).RemoveTimer( 'NoRetreat' );
				theSound.SoundEvent("gui_global_clock_tick_stop");
				((FirstPersonCamera)ent).LogMessage("<font color=\"#C20095\">Auto leaving enabled.</font>");
			}
		}
	}	
	
/*=================================================================================================
   _____          _                  
  / ____|        | |                 
 | |    _   _ ___| |_ ___  _ __ ___  
 | |   | | | / __| __/ _ \| '_ ` _ \ 
 | |___| |_| \__ \ || (_) | | | | | |
  \_____\__,_|___/\__\___/|_| |_| |_|
                                     
/*==================================================================================================*/	
	
//Listener class
class FPHookListener extends CPlayerInput
{
	//Initialization function - register listener
	function StartListener(optional notrigger : bool)
	{
		//FPS MOD.
		//theInput.RegisterListener( this, 'OnHook', 'DebugInput' );
		
		if(!notrigger)
		{
			theSound.SoundEvent("gui_ingame_wheel_open");
			LogMessage("<font color=\"#C20095\">First person mode hooked, press " + GetIconForKey(IK_P) + " on keyboard to enter/exit first person mode.</font>");
		}

	}
	
	event OnHook( action : SInputAction )
	{
		var ent : CEntity;
		var template : CEntityTemplate;
		var attachvector : Vector;
		var attachangle : EulerAngles;	
		var l_comp : CComponent;	
		var initialrotation : EulerAngles;
	
		//Entire spawning logic fired when player presses P
			if( IsPressed( action ) )
			{
				OnHookToggle();
			}
	}
	
	function OnHookToggle()
	{
		var ent : CEntity;
		var template : CEntityTemplate;
		var attachvector : Vector;
		var attachangle : EulerAngles;	
		var l_comp : CComponent;	
		var initialrotation : EulerAngles;
	
				if(!thePlayer.GetIsHorseMounted() && !thePlayer.IsInCombat() || !thePlayer.GetIsHorseMounted() && thePlayer.IsInCombat() && IsCombatAllowed())
				{
					template = (CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstperson.w2ent", true);
					ent = theGame.CreateEntity(template, thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetWorldRotation());	
					((FirstPersonCamera)ent).setlistener(this);	
	
					attachvector = thePlayer.GetBoneWorldPosition('Root');
					attachvector.Z = attachvector.Z + 1.85;
					attachangle = thePlayer.GetWorldRotation();
					attachangle.Pitch = 0;	
					attachangle.Roll = 0;	
	
					ent.CreateAttachmentAtBoneWS( thePlayer, 'Root', attachvector, attachangle );
					ent.AddTag('FPSCAMERA');	
					initialrotation.Pitch = initialrotation.Pitch * -1;
					initialrotation.Yaw = 0;	
					initialrotation.Roll = initialrotation.Roll * -1;
			
					l_comp = ent.GetComponentByClassName('CCameraComponent');
					((CComponent)l_comp).SetPosition(Vector(0,0.05,0,1));	
					((CComponent)l_comp).SetRotation(initialrotation);
				}
				else
				{
					LogMessage("<font color=\"#C20095\">Cannot enter first person mode right now.</font>");
					theSound.SoundEvent("gui_global_denied");
				}
			
	}
	
	function IsCombatAllowed() : bool
	{
		if(FactsDoesExist("FPALLOWCOMBAT") && FactsQuerySum("FPALLOWCOMBAT") == 1)		
		{
			return true;
		}
		else
		{
			return false;
		}
	}

//Print to log
	public function LogMessage(m : string)
	{
		var str : string;	
	
		str = ReplaceTagsToIcons(m);
	
		theGame.GetGuiManager().ShowNotification(str, 4000);
	}	
}

//Trigger item (Mysterious Monocle item)
class FPTriggerItem extends CItemEntity
{
	var listener	: FPHookListener;
	var ent 		: CEntity;
	var testcomp : CComponent;
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.AddTimer( 'DelayedRun', 1.0, false );
		testcomp = this.GetComponentByClassName('CMeshComponent');
		((CMeshComponent)testcomp).SetVisible(false);
	}
	
	timer function DelayedRun( time : float, id : int)
	{
		if(GetParentEntity() == thePlayer)
		{
			if(!((FPHookListener)thePlayer.GetInputHandler()))
			{
				listener = new FPHookListener in thePlayer.GetInputHandler();
				listener.StartListener(true);
			}
		}
	}	
}

/*=================================================================================================
  _____                            _       
 |_   _|                          | |      
   | |  _ __ ___  _ __   ___  _ __| |_ ___ 
   | | | '_ ` _ \| '_ \ / _ \| '__| __/ __|
  _| |_| | | | | | |_) | (_) | |  | |_\__ \
 |_____|_| |_| |_| .__/ \___/|_|   \__|___/
                 | |                       
                 |_|                       
				 
/*==================================================================================================*/	

//Needed for FOV controls
import class CCameraComponent extends CSpriteComponent
{
	import var fov	:	float;
	import var nearPlane : ENearPlaneDistance;
	import var farPlane : EFarPlaneDistance;
	import var customClippingPlanes : SCustomClippingPlanes;
	import var aspect : float;
	
public function updateaspect()
{
	var currentWidth, currentHeight : int;
	
	theGame.GetCurrentViewportResolution( currentWidth, currentHeight );
	aspect = ( (float)currentWidth ) / currentHeight;	
}	
	
public function setfov(val : float)
{
	fov = val;
}

public function getfov() : float
{
	return fov;
}

public function setnearplane(val : int)
{
	nearPlane = val;
}

public function setfarplane(val : int)
{
	farPlane = val;
}

public function setclippingplanes(val1 : float, val2 : float)
{
	customClippingPlanes.nearPlaneDistance =val1;
	customClippingPlanes.farPlaneDistance =val2;
}

}

import struct SCustomClippingPlanes
{
	import var nearPlaneDistance : float;
	import var farPlaneDistance : float;
}

import struct SWorldEnvironmentParameters
{
	import var renderSettings : SWorldRenderSettings;
	import var cameraDirtTexture : CBitmapTexture;
	import var vignetteTexture	: CBitmapTexture;
}

import struct SWorldRenderSettings
{
	import var cameraNearPlane : float;
	import var cameraFarPlane : float;
	import var enableEnvProbeLights : bool; default enableEnvProbeLights = true;
}
 
import struct CAreaEnvironmentParams
{
    import var m_depthOfField   : CEnvDepthOfFieldParameters;
}
 
import struct SCurveDataEntry{

    import var lue : float;
}
 
import struct CEnvDepthOfFieldParameters
{
    import var nearBlurDist 			: 	SSimpleCurve;
    import var farBlurDist 				: 	SSimpleCurve;
    import var nearFocusDist 			:	SSimpleCurve;
    import var farFocusDist 			: 	SSimpleCurve;
    import var intensity    			:	SSimpleCurve;
    import var activated    			: 	bool;
	import var activatedSkyThreshold	:	bool;
	import var activatedSkyRange		:	bool;
	import var skyRange					:	Float;
}
 
import struct SSimpleCurve
{
    import var dataCurveValues : array<SCurveDataEntry>;
}

import class CGameWorld extends CWorld
{
	import var environmentParameters	: SWorldEnvironmentParameters;
	
	function setnearz(val : float)
	{
		environmentParameters.renderSettings.cameraNearPlane = val;
	}	
	
	function setfarz(val : float)
	{
		environmentParameters.renderSettings.cameraFarPlane = val;
	}

	function getnearz() : float
	{
		return environmentParameters.renderSettings.cameraNearPlane;
	}
	
	function getfarz() : float
	{
		return environmentParameters.renderSettings.cameraFarPlane;
	}
	
	function getcameradirt() : CBitmapTexture
	{
		return environmentParameters.cameraDirtTexture;
	}	
	
	function setcameradirt(val : CBitmapTexture)
	{
		environmentParameters.cameraDirtTexture = val;
	}
	
	function getcameravignette() : CBitmapTexture
	{
		return environmentParameters.vignetteTexture;
	}	
	
	function setcameravignette(val : CBitmapTexture)
	{
		environmentParameters.vignetteTexture = val;
	}	
}