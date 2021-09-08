	//FPS Mod main
	function FP_OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float ) : bool
	{
		var ent : CEntity;
		var playerPos : Vector;
		var angles : EulerAngles;
		
		var distance : float;

		//YURA MOD
		if(FP_IsEnabled()){	   
            if(thePlayer.IsUsingHorse() )
				moveData.pivotPositionController.offsetZ = FP_CamOffsetZ_OnHorse();		
            else				
		        moveData.pivotPositionController.offsetZ = FP_CamOffsetZ();			
		}
		return true;
	}
	
	
	function FP_PreGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
		var modMastBeDisabled : bool;
		var isGeraltVisible: bool;

		modMastBeDisabled =	!FP_IsEnabled()
		        || (!FP_IsEnabled_Swiming() && thePlayer.IsSwimming())
				|| (!FP_IsEnabled_DialogOrCutscene()  && theGame.IsDialogOrCutscenePlaying() )
				|| (!FP_IsEnabled_NonGameplayCutscene() && thePlayer.IsInNonGameplayCutscene())
				|| (!FP_IsEnabled_NonGameplayScene() && theGame.IsCurrentlyPlayingNonGameplayScene())
				|| (!FP_IsEnabled_UsingBoat()  && thePlayer.IsUsingBoat())
				|| (!FP_IsEnabled_Combat() && thePlayer.IsInCombat())
				|| (!FP_IsEnabled_UsingHorse() && (thePlayer.IsUsingHorse()));
		if(modMastBeDisabled)				
		{			
			isGeraltVisible=true;
		}
		else{
			if(theGame.IsFocusModeActive()){
		        isGeraltVisible=!(FP_HideGeralt() && FP_HideGeralt_FocusMode());
			}
			else{
				isGeraltVisible=!FP_HideGeralt();
			}			
		}
					
	    thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = thePlayer.GetInventory().GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = thePlayer.GetInventory().GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = thePlayer.GetInventory().GetItemEntityUnsafe(xid);
		bolt = thePlayer.GetInventory().GetItemEntityUnsafe(bid);
		bolt2 = thePlayer.GetInventory().GetItemEntityUnsafe(thePlayer.GetInventory().GetItemFromSlot( 'r_weapon' ) );
		//boltMesh = (CDrawableComponent)(thePlayer.GetInventory().GetItemEntityUnsafe(bid).GetMeshComponent());
	
	    if(isGeraltVisible || theGame.IsDialogOrCutscenePlaying() || theGame.IsCurrentlyPlayingNonGameplayScene())
		{
			thePlayer.SetHideInGame(false);
			SetObjHideInGame(xbow,false);
			SetObjHideInGame(bolt,false);
			SetObjHideInGame(bolt2,false);
			SetObjHideInGame(swordsilver,false);
			SetObjHideInGame(swordsteel,false);
			thePlayer.GetWeaponHolster().OnWeaponDrawReady();
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Fists );
		}	
		else{
			thePlayer.SetHideInGame(true);
			SetObjHideInGame(xbow,true);
			SetObjHideInGame(bolt,true);
			SetObjHideInGame(bolt2,true);
			SetObjHideInGame(swordsilver,true);
			SetObjHideInGame(swordsteel,true);
		}

	    
		if( thePlayer.GetInventory().IsItemHeld(steelid))
	    {		
			SetObjHideInGame(swordsteel,false);
			thePlayer.GetWeaponHolster().OnWeaponDrawReady();
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );
	    }
	    if( thePlayer.GetInventory().IsItemHeld(silverid))
	    {	
			SetObjHideInGame(swordsilver,false);
			thePlayer.GetWeaponHolster().OnWeaponDrawReady();
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );
	    }
		if( thePlayer.GetInventory().IsItemHeld(xid) )
		{
			SetObjHideInGame(xbow,false);
			SetObjHideInGame(bolt,false);
			SetObjHideInGame(bolt2,false);
		}	
	}
	
	//FPS Mod main
    function FP_OnGameCameraTick( out moveData : SCameraMovementData, dt : float) : bool
	{
		var targetRotation	: EulerAngles;
		var dist : float;
		var Speed : float;	
		//YURA MOD
		var mod_InteriorModifier : float;
		var mod_CamOffser_Width : float;
		var mod_CamOffser_Height: float;	
		var Config : CInGameConfigWrapper;		
		var ent : CEntity;
		var playerPos : Vector;
		var angles : EulerAngles;		
		var distance : float;
        var camDist 	: float;
		var camOffset 	: float;
		var rotMultDest	: float;
		var rotMult	: float;	
	    var horseComp : W3HorseComponent;
		
		Speed = thePlayer.GetMovingAgentComponent().GetRelativeMoveSpeed();

		//YURA MOD
		Config = theGame.GetInGameConfigWrapper();
		if(FP_IsEnabled())
		{	
			
			if(
				(!FP_IsEnabled_Swiming() && thePlayer.IsSwimming())
				|| (!FP_IsEnabled_DialogOrCutscene()  && theGame.IsDialogOrCutscenePlaying() )
				|| (!FP_IsEnabled_NonGameplayCutscene() && thePlayer.IsInNonGameplayCutscene())
				|| (!FP_IsEnabled_NonGameplayScene() && theGame.IsCurrentlyPlayingNonGameplayScene())
				|| (!FP_IsEnabled_UsingBoat()  && thePlayer.IsUsingBoat())
				|| (!FP_IsEnabled_Combat() && thePlayer.IsInCombat())
				|| (!FP_IsEnabled_UsingHorse() && (thePlayer.IsUsingHorse()))
				)				
			{
			}
			else {			
				moveData.pivotRotationController.maxPitch = 89.0;
				moveData.pivotRotationController.minPitch = -89.0;	
			
				theGame.GetGameCamera().ChangePivotRotationController('Exploration');
				theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
				theGame.GetGameCamera().ChangePivotPositionController( 'Default' );

				moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
				moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
				moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();

				moveData.pivotPositionController.SetDesiredPosition(thePlayer.GetWorldPosition(), 0.0 );
				//moveData.pivotRotationController.SetDesiredHeading( thePlayer.GetHeading(), 2.8 );				
				moveData.pivotDistanceController.SetDesiredDistance( 0.0 );	
		
		        mod_CamOffser_Height = 0;
				if(theGame.IsFocusModeActive()){
					mod_CamOffser_Width = FP_CamWidthOffset_FocusMode();
					mod_CamOffser_Height = FP_CamHeightOffset_FocusMode();
				}
				else if(thePlayer.IsInCombat()){
					mod_CamOffser_Width = FP_CamWidthOffset_InCombat() ;
				}
				else if(thePlayer.IsUsingHorse()){			
                    horseComp = GetMyHorseComp();					
					mod_CamOffser_Width = FP_CamWidthOffset_Horse() ;
					
					if(horseComp.inCanter){
						mod_CamOffser_Width+=FP_CamWidthOffsetModifier_Gallop();
						moveData.pivotRotationController.minPitch = -12.0;
					}
					if(horseComp.inGallop){
						mod_CamOffser_Width+=FP_CamWidthOffsetModifier_Gallop()/2;
						moveData.pivotRotationController.minPitch = -15.0;
					}
					else{
						moveData.pivotRotationController.minPitch = -30.0;
					}
				}
				else if(thePlayer.IsUsingBoat()){
					mod_CamOffser_Width = FP_CamWidthOffset_Boat() ;
				}
				else {
					mod_CamOffser_Width = FP_CamWidthOffset() ;
				}
				
				//first hight, second width
				DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector(0.0, mod_CamOffser_Width, mod_CamOffser_Height), 0.2, dt);
				return false;
			}		
		}
		
		return true;
	}
	
	function SetObjHideInGame(ent : CEntity, hideInGame : bool){
		ent.SetHideInGame(hideInGame);
		ent.SetHideInGame(!hideInGame);
		ent.SetHideInGame(hideInGame);
	}
	
	
	function GetMyHorse():CNewNPC{	
	    return GetWitcherPlayer().GetHorseWithInventory();
	}
	
	function GetMyHorseComp():W3HorseComponent{	
	    return GetMyHorse().GetHorseComponent();
	}	