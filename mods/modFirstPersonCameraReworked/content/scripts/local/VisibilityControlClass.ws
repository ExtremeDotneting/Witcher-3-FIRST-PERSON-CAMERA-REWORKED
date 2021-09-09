class VisibilityControlClass
{		
	function ShowAll()
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;		
	    var inv : CInventoryComponent;	
		
		inv=thePlayer.GetInventory();
					
	    inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = inv.GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = inv.GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = inv.GetItemEntityUnsafe(xid);

        //Set
        SetPlayerHideInGame(false);
		SetHideInGame(xbow,false);
		SetHideInGame(swordsilver,false);
		SetHideInGame(swordsteel,false);		
		myMods().FP().SetBoltProjectileVisibility(true);	
		
		// thePlayer.GetWeaponHolster().OnWeaponDrawReady();
		// thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );
		// thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );
		// thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Fists );
		
		// SetPlayerHideInGame(true);
		// SetPlayerHideInGame(false);
	}
	
	
	function HideAll()
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
		var inv : CInventoryComponent;	
		
		inv=thePlayer.GetInventory();
		
					
	    inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = inv.GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = inv.GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = inv.GetItemEntityUnsafe(xid);

        //Set
        SetPlayerHideInGame(true);
		SetHideInGame(xbow,true);
		SetHideInGame(swordsilver,true);
		SetHideInGame(swordsteel,true);
		myMods().FP().SetBoltProjectileVisibility(false);
	}
	
	function HideAllExceptXbow()
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
		var inv : CInventoryComponent;	
		
		inv=thePlayer.GetInventory();
					
	    inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = inv.GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = inv.GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = inv.GetItemEntityUnsafe(xid);

        //Set
        SetPlayerHideInGame(true);
		SetHideInGame(xbow,false);
		SetHideInGame(swordsilver,true);
		SetHideInGame(swordsteel,true);
		myMods().FP().SetBoltProjectileVisibility(true);
	}
	
	function HideAllExceptSilver()
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
		var inv : CInventoryComponent;	
		
		inv=thePlayer.GetInventory();
					
	    inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = inv.GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = inv.GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = inv.GetItemEntityUnsafe(xid);

        //Set
        SetPlayerHideInGame(true);
		SetHideInGame(xbow,true);
		SetHideInGame(swordsilver,false);
		SetHideInGame(swordsteel,true);	
		myMods().FP().SetBoltProjectileVisibility(false);
		
		//thePlayer.GetWeaponHolster().OnWeaponDrawReady();
		//thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Silver );

	}
	
	function HideAllExceptSteel()
	{
		var steelid,silverid, xid, bid : SItemUniqueId;
		var steelcomp, silvercomp, boltMesh  : CDrawableComponent;
	    var swordsteel, swordsilver, xbow, bolt, bolt2 : CEntity;
		var inv : CInventoryComponent;	
		
		inv=thePlayer.GetInventory();
					
	    inv.GetItemEquippedOnSlot(EES_SteelSword, steelid);
	    swordsteel = inv.GetItemEntityUnsafe(steelid);
	    steelcomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(steelid)).GetMeshComponent());
	
	    inv.GetItemEquippedOnSlot(EES_SilverSword, silverid);
	    swordsilver = inv.GetItemEntityUnsafe(silverid);
	    silvercomp = (CDrawableComponent)((inv.GetItemEntityUnsafe(silverid)).GetMeshComponent());
		
		inv.GetItemEquippedOnSlot(EES_RangedWeapon, xid);
	    inv.GetItemEquippedOnSlot(EES_Bolt, bid);
	    xbow = inv.GetItemEntityUnsafe(xid);

        //Set
        SetPlayerHideInGame(true);
		SetHideInGame(xbow,true);
		SetHideInGame(swordsilver,true);
		SetHideInGame(swordsteel,false);
		myMods().FP().SetBoltProjectileVisibility(false);
		
		//thePlayer.GetWeaponHolster().OnWeaponDrawReady();
		//thePlayer.GetWeaponHolster().OnEquippedMeleeWeapon( PW_Steel );

	}
	
	// function SetHideInGameLazy(ent : CEntity, hideInGame : bool){
		// var savedState : bool;
		// savedState=hideInGameDict.Get(ent);
		// if(savedState!=hideInGame)
		    // ent.SetHideInGame(hideInGame);
		// hideInGameDict.Set(ent, hideInGame);
	// }
	
	function SetHideInGame(ent : CEntity, hideInGame : bool)
	{
		//ent.SetHideInGame(hideInGame);
		//ent.SetHideInGame(!hideInGame);
		ent.SetHideInGame(hideInGame);
	}
	
	function SetPlayerHideInGame( hideInGame : bool)
	{
		var itemL : W3UsableItem;
		
		thePlayer.SetHideInGame(hideInGame);		
		// itemL = thePlayer.GetCurrentlyUsedItemL ();
		// if ( itemL )
		// {
			// itemL.SetVisibility ( true );
			// itemL.OnUsed( thePlayer );
		// }
	}
	
	
}
