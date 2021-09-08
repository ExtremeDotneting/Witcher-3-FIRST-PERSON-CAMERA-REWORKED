class FPModClass
{	
    var vsControl : VisibilityControlClass;
	public var boltProjectile : CDrawableComponent;
	
	public function Init(){
		vsControl= new VisibilityControlClass in this;
	}
	
    //FPS Mod main
	public function OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float ) : bool
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
	
	
	public function PreGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var isGeraltVisible: bool;
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
	    var inv : CInventoryComponent;	

		isGeraltVisible =	!FP_IsEnabled()
		        || (!FP_IsEnabled_Swiming() && thePlayer.IsSwimming())
				|| (!FP_IsEnabled_DialogOrCutscene()  && theGame.IsDialogOrCutscenePlaying() )
				|| (!FP_IsEnabled_NonGameplayCutscene() && thePlayer.IsInNonGameplayCutscene())
				|| (!FP_IsEnabled_NonGameplayScene() && theGame.IsCurrentlyPlayingNonGameplayScene())
				|| (!FP_IsEnabled_UsingBoat()  && thePlayer.IsUsingBoat())
				|| (!FP_IsEnabled_Combat() && thePlayer.IsInCombat())
				|| (!FP_IsEnabled_UsingHorse() && thePlayer.IsUsingHorse())
				|| (!FP_HideGeralt_FocusMode() && theGame.IsFocusModeActive());
				
		if(isGeraltVisible)
		{
            vsControl.ShowAll();
			return;
		}	
					
		inv=thePlayer.GetInventory();	 
		inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
		
        if( inv.IsItemHeld(xid) )
		{
			vsControl.HideAllExceptXbow();
		}
		else if (thePlayer.GetCurrentMeleeWeaponType() == PW_Steel)
		//else if(inv.IsItemHeld(steelid))
	    {		
			vsControl.HideAllExceptSteel();
	    }
		else if (thePlayer.GetCurrentMeleeWeaponType() == PW_Silver)
	    //else if(inv.IsItemHeld(silverid))
	    {	
			vsControl.HideAllExceptSilver();
	    }		
		else
		{
			vsControl.HideAll();
		}
	}
	
	//FPS Mod main
    public function OnGameCameraTick( out moveData : SCameraMovementData, dt : float) : bool
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
	
	public function SetBoltProjectile(comp : CDrawableComponent)
	{
		boltProjectile=comp;
	}	
	
	public function SetBoltProjectileVisibility(value : bool)
	{
		if(!boltProjectile)
			return;
		boltProjectile.SetVisible(value);
	}	
	
	function GetMyHorse():CNewNPC{	
	    return GetWitcherPlayer().GetHorseWithInventory();
	}
	
	function GetMyHorseComp():W3HorseComponent{	
	    return GetMyHorse().GetHorseComponent();
	}	
}
