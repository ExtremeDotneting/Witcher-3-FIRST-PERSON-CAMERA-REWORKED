exec function ghost_of_the_sun()
{
	if( !thePlayer.inv.HasItem('ghost_of_the_sun') )
		thePlayer.inv.AddAnItem('ghost_of_the_sun', 1);
}

function invisibleweapons2()
{
	var Config 															        : CInGameConfigWrapper;
	var steelid,silverid, xid, bid 												: SItemUniqueId;
	var xbow, swordsteel, swordsilver, effect 									: CEntity;
	var scabbards,swords 														: array<SItemUniqueId>; 
	var sw 																		: int; 
	var n, lenght 																: Float; 
	var weaponSlotMatrix 														: Matrix;
	var weaponTipPosition 														: Vector;
	var Without_Animation, Visual_Effect, Optional_Animation,Left_Hand_Effect 	: Bool;
	var steelcomp, silvercomp, scabbardscomp 									: CDrawableComponent;
	var weaponType 																: EPlayerWeapon;
	var swordst,swordsi 														: CWitcherSword; 

    //YURA MOD
	if(!thePlayer.GetInventory().HasItem( 'ghost_of_the_sun' )) {	return; }
	if(true)// thePlayer.IsInCombat()) 
	{ 
	    thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = thePlayer.GetInventory().GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = thePlayer.GetInventory().GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(silverid)).GetMeshComponent());
	
	    if(theGame.IsDialogOrCutscenePlaying() || theGame.IsCurrentlyPlayingNonGameplayScene())
		{
			silvercomp.SetVisible(true);
			steelcomp.SetVisible(true);
			thePlayer.GetWeaponHolster().OnWeaponDrawReady();
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );
			thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Fists );
		}
	    else if( thePlayer.GetInventory().IsItemHeld(steelid))
	    {	
			silvercomp.SetVisible(false);			
			steelcomp.SetVisible(true);
	    }
	    else if( thePlayer.GetInventory().IsItemHeld(silverid))
	    {	
	        silvercomp.SetVisible(true);
			steelcomp.SetVisible(false);	
	    }
		else
		{
			silvercomp.SetVisible(false);
			steelcomp.SetVisible(false);
		}
		return;
	}
	
	
	
	
	thePlayer.GetInventory().GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	thePlayer.GetInventory().GetItemEquippedOnSlot(EES_Bolt, bid);
	xbow = thePlayer.GetInventory().GetItemEntityUnsafe(xid);
	
	if( !thePlayer.GetInventory().IsItemHeld(xid) )
	{
		xbow.SetHideInGame(false);
		xbow.SetHideInGame(true);
		if( FactsQuerySum("xbow_hidden")<=0 )
		{
			effect_xbow_sheathe2();
			FactsAdd("xbow_hidden");
		}
		FactsRemove("xbow_shown");
		FactsRemove("show_xbow2");
	}
	else
	{
		FactsAdd("draw_xbow2",,1);
		if( FactsQuerySum("xbow_shown")<=0 )
		{
			effect_xbow_draw2();
			FactsAdd("xbow_shown");
		}
		if(FactsQuerySum("show_xbow2")>0)
		{
			xbow.SetHideInGame(false);
		}
		FactsRemove("xbow_hidden");
	}
	
	/////// scabbards   ///////
	
	thePlayer.GetInventory().GetAllItems(scabbards);	
	for(sw=0; sw<scabbards.Size(); sw+=1)
	{	
		if ( thePlayer.GetInventory().GetItemCategory(scabbards[sw]) == 'steel_scabbards' ||  thePlayer.GetInventory().GetItemCategory(scabbards[sw]) == 'silver_scabbards' )
		{
			scabbardscomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(scabbards[sw])).GetMeshComponent());
			if( scabbardscomp.IsVisible() )
			{		
				scabbardscomp.SetVisible(false);
			}
		}
	}
	
	/////// swords   ///////
	
	thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
	swordsteel = thePlayer.GetInventory().GetItemEntityUnsafe(steelid);
	steelcomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
	swordsilver = thePlayer.GetInventory().GetItemEntityUnsafe(silverid);
	silvercomp = (CDrawableComponent)((thePlayer.GetInventory().GetItemEntityUnsafe(silverid)).GetMeshComponent());
	
	swordst = (CWitcherSword)thePlayer.GetInventory().GetItemEntityUnsafe( steelid );
	swordsi = (CWitcherSword)thePlayer.GetInventory().GetItemEntityUnsafe( silverid );
		
		if(	FactsQuerySum("show_steel2")	   >0)  {	steelcomp.SetVisible(true);		FactsRemove("hide_steel2");		}
		if(	FactsQuerySum("hide_steel2")	   >0)  {	steelcomp.SetVisible(false); 	FactsRemove("show_steel2");		}
		if(	FactsQuerySum("show_silver2")   >0)	{	silvercomp.SetVisible(true);	FactsRemove("hide_silver2");		}
		if(	FactsQuerySum("hide_silver2")   >0)	{	silvercomp.SetVisible(false); 	FactsRemove("show_silver2");		}
			
		if(	FactsQuerySum("OnGrab_steel2")  >0)  {	swordst.OnGrab();				FactsRemove("OnGrab_steel2");	}
		if(	FactsQuerySum("OnPut_steel2")   >0)  {	swordst.OnPut();				FactsRemove("OnPut_steel2");		}
		if(	FactsQuerySum("OnGrab_silver2") >0)  {	swordsi.OnGrab();				FactsRemove("OnGrab_silver2");	}
		if(	FactsQuerySum("OnPut_silver2")  >0)  {	swordsi.OnPut();				FactsRemove("OnPut_silver2");	}
	
		//////    steel  ///////
		
		if( thePlayer.GetInventory().IsItemHeld(steelid))
		{	
			if( FactsQuerySum( "steel_shown" )<= 0  )
			{
				FactsAdd("steel_shown");
				FactsAdd("draw_steel2",,1);
				FactsRemove( "steel_hidden");
				effect__draw();	
				anima2();
				thePlayer.GetWeaponHolster().OnWeaponDrawReady();
				thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );
				//theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
			}
		}
		else 
		{	
			steelcomp.SetVisible(false);
			if( FactsQuerySum("steel_hidden")<=0)
			{
				FactsAdd("steel_hidden");
				FactsAdd("sheathe_steel2",,1);
				FactsRemove( "steel_shown");
				//effect__sheathe();
				thePlayer.GetWeaponHolster().OnWeaponHolsterReady()();
			}
		}
	
		//////    silver  ///////
		
		if( thePlayer.GetInventory().IsItemHeld(silverid))
		{	
			if( FactsQuerySum( "silver_shown" )<= 0  )
			{
				FactsAdd("silver_shown");
				FactsAdd("draw_silver2",,1);
				FactsRemove( "silver_hidden");
				effect__draw();	
				anima2();
				thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );
				thePlayer.GetWeaponHolster().OnWeaponDrawReady();
				//theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
			}
		}
		else 
		{	
			silvercomp.SetVisible(false);
			if( FactsQuerySum("silver_hidden")<=0)
			{
				FactsAdd("silver_hidden");
				FactsAdd("sheathe_silver2",,1);
				FactsRemove( "silver_shown");
				//effect__sheathe();
				thePlayer.GetWeaponHolster().OnWeaponHolsterReady()();
			}
		}
	
	//////////////////////////////////////////////  //////////////////////////////////////////////
	
	///////////////		from fists 		///////////////		
	if(!thePlayer.GetInventory().IsItemHeld(silverid) && thePlayer.GetBehaviorVariable( 'isHoldingWeaponR') == 1
		&& !thePlayer.GetInventory().IsItemHeld(steelid) && ( thePlayer.GetWeaponHolster().GetCurrentMeleeWeapon() == PW_Fists ) )
	{
	}
	
	///////////////		silver 		///////////////		
	
	///////////////		draw silver		///////////////		
	if(!thePlayer.GetInventory().IsItemHeld(silverid) && thePlayer.GetBehaviorVariable( 'isHoldingWeaponR') == 1 
		&& !thePlayer.GetInventory().IsItemHeld(steelid) && thePlayer.GetBehaviorVariable( 'SelectedWeapon') == 1 )
	{
		FactsRemove("hide_silver2");
	}
	///////////////		holster silver		///////////////		
	if(thePlayer.GetInventory().IsItemHeld(silverid) && thePlayer.GetBehaviorVariable( 'isHoldingWeaponR') == 0 
		)
	{
		FactsRemove("show_silver2");
	}
	
	////////   change silver to steel  //////////
	if( thePlayer.GetInventory().IsItemHeld(silverid) && thePlayer.GetBehaviorVariable( 'SelectedWeapon') == 0 )
	{
		FactsRemove("show_silver2");
	}
	
	
	///////////////		steel 		///////////////		
	
	///////////////		draw steel		///////////////		
	if(!thePlayer.GetInventory().IsItemHeld(silverid) && thePlayer.GetBehaviorVariable( 'isHoldingWeaponR') == 1 
		&& !thePlayer.GetInventory().IsItemHeld(steelid) && thePlayer.GetBehaviorVariable( 'SelectedWeapon') == 0 )
	{
		FactsRemove("hide_steel2");
	}
	///////////////		holster steel		///////////////		
	if(thePlayer.GetInventory().IsItemHeld(steelid) && thePlayer.GetBehaviorVariable( 'isHoldingWeaponR') == 0 
		)
	{
		FactsRemove("show_steel2");
	}
	
	////////   change steel  to silver  //////////
	if( thePlayer.GetInventory().IsItemHeld(steelid) && thePlayer.GetBehaviorVariable( 'SelectedWeapon') == 1 )
	{
		FactsRemove("show_steel2");
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function effect_xbow_draw2()
{
	var Visual_Effect															: Bool;
	var effect 																	: CEntity;
	var Config 																	: CInGameConfigWrapper;
	
	Config = theGame.GetInGameConfigWrapper();
	Visual_Effect = Config.GetVarValue('invisible_weapons', 'Visual_Effect');

	if ( Visual_Effect )
	{
		effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\invisibleweapons\effects\pc_igni_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		effect.CreateAttachment( thePlayer,'l_weapon',Vector( 0, 0, 0.15f ) );
		effect.PlayEffect('xbow_effect2');
		effect.StopAllEffectsAfter(0.6);
		effect.DestroyAfter(2);
		//xbow.PlayEffect('appear');
	}
}

function effect_xbow_sheathe2()
{
	var Visual_Effect															: Bool;
	var effect 																	: CEntity;
	var Config 																	: CInGameConfigWrapper;
	
	Config = theGame.GetInGameConfigWrapper();
	Visual_Effect = Config.GetVarValue('invisible_weapons', 'Visual_Effect');
	
	if ( Visual_Effect )
	{
		effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\invisibleweapons\effects\pc_igni_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		effect.CreateAttachment( thePlayer,'l_weapon',Vector( 0, 0, 0.15f ) );
		effect.PlayEffect('xbow_effect');
		effect.StopAllEffectsAfter(0.6);
		effect.DestroyAfter(2);
		effect.BreakAttachment();
		
		thePlayer.PlayEffect('generic_spell_lh');
		thePlayer.StopEffect('generic_spell_lh');
		//xbow.PlayEffect('disappear');
	}
}
	
	
function anima2()
{
	var Optional_Animation 													: Bool;
	var Config 																: CInGameConfigWrapper;
	
	Config = theGame.GetInGameConfigWrapper();
	Optional_Animation = Config.GetVarValue('invisible_weapons', 'Optional_Animation');
	if(Optional_Animation)
	{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_sword_sharpening_03',0.5,1);   }
}

function effect__sheathe()
{
	var sword, effect 															: CEntity;
	var weaponTipPosition 														: Vector;
	var lenght, n																	: Float;
	var Visual_Effect															: Bool;
	var Config 																	: CInGameConfigWrapper;
	var weaponSlotMatrix 														: Matrix;
	
	Config = theGame.GetInGameConfigWrapper();
	Visual_Effect = Config.GetVarValue('invisible_weapons', 'Visual_Effect');
	
	if ( Visual_Effect )
	{
			
		//thePlayer.PlayEffectOnBone('generic_spell_lh','r_weapon');
		//thePlayer.StopEffect('generic_spell_lh');
		thePlayer.TimedSoundEvent(1, "magic_geralt_healing_loop", "magic_geralt_healing_loop_end");
		
		for( n=-0.2; n<=1; n+=0.1 )
		{	
			effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\invisibleweapons\effects\pc_igni_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
			effect.CreateAttachment( thePlayer,'r_weapon',Vector( 0, 0, 1*n ));
			effect.BreakAttachment();
			effect.PlayEffect('sword_effect');
			effect.StopAllEffectsAfter(0.5);
			effect.DestroyAfter(2);
		}
		//swordsteel.PlayEffect('disappear');
	}
}

function effect__draw()
{
	var sword, effect 															: CEntity;
	var weaponTipPosition 														: Vector;
	var lenght, n																: Float;
	var Visual_Effect,Left_Hand_Effect											: Bool;
	var Config 																	: CInGameConfigWrapper;
	var weaponSlotMatrix 														: Matrix;
	
	Config = theGame.GetInGameConfigWrapper();
	Visual_Effect = Config.GetVarValue('invisible_weapons', 'Visual_Effect');
	Left_Hand_Effect = Config.GetVarValue('invisible_weapons', 'Left_Hand_Effect');
	
	if ( Visual_Effect )
	{
		if(Left_Hand_Effect )
		{
			thePlayer.PlayEffect('generic_spell_lh');
			thePlayer.StopEffect('generic_spell_lh');	
		}
		
		for( n=-0.2; n<=1; n+=0.1 )
		{	
			effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\invisibleweapons\effects\pc_igni_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
			effect.CreateAttachment( thePlayer,'r_weapon',Vector( 0, 0, 1*n ));
			effect.PlayEffect('sword_effect');
			effect.StopAllEffectsAfter(0.5);
			effect.DestroyAfter(2);
		}
		//swordsteel.PlayEffect('disappear');
	}
}

