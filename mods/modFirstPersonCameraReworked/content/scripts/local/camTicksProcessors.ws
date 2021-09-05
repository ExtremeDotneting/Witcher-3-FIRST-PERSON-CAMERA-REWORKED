	function GetMyHorse():CNewNPC{	
	    return GetWitcherPlayer().GetHorseWithInventory();
	}
	
	function GetMyHorseComp():W3HorseComponent{	
	    return GetMyHorse().GetHorseComponent();
	}
	
	//FPS Mod main
	function FPS_OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float ) : bool
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
	
	//FPS Mod main
    function FPS_OnGameCameraTick( out moveData : SCameraMovementData, dt : float) : bool
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
				thePlayer.SetHideInGame(false);
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

                if(theGame.IsFocusModeActive()){
				   thePlayer.SetHideInGame(
				      FP_HideGeralt() && FP_HideGeralt_FocusMode()
					  );
				}
				else{
				   thePlayer.SetHideInGame(FP_HideGeralt());
				}
				

				moveData.pivotPositionController.SetDesiredPosition(thePlayer.GetWorldPosition(), 0.0 );
				moveData.pivotRotationController.SetDesiredHeading( thePlayer.GetHeading(), 2.8 );				
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
				
				// if(IsInInterior()){				
				    // mod_InteriorModifier=StringToFloat(Config.GetVarValue('fps_mod_configs', 'Offset_WDTH_INTERIOR'));
					// mod_CamOffser_Width=mod_CamOffser_Width-mod_InteriorModifier;
					// if(mod_CamOffser_Width<0)
						// mod_CamOffser_Width=0;
				// }
				
				//first hight, second width
				DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector(0.0, mod_CamOffser_Width, mod_CamOffser_Height), 0.2, dt);
				return false;
			}		
		}
		else{
			thePlayer.SetHideInGame(false);
		}
		
		// if( substateManager.UpdateCameraIfNeeded( moveData, dt ) )
		// {
			// return true;
		// }	
		return true;
	}
	