//IS ENABLED
function FP_IsEnabled():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable');
}
function FP_IsEnabled_Combat():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_combat');
}
function FP_IsEnabled_Swiming():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_Swiming');
}
function FP_IsEnabled_NonGameplayScene():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_NonGameplayScene');
}
function FP_IsEnabled_DialogOrCutscene():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_DialogOrCutscene');
}
function FP_IsEnabled_NonGameplayCutscene():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_NonGameplayCutscene');
}
function FP_IsEnabled_UsingBoat():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_UsingBoat');
}
function FP_IsEnabled_UsingHorse():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Enable_in_UsingHorse');
}

//HIDE GERALT
function FP_HideGeralt():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Hide_geralt');
}
function FP_HideGeralt_FocusMode():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Hide_geralt_in_witchersense');
}

//CAM OFFSETS MODIFIERS WIDTH
function FP_CamWidthOffsetModifier_Gallop():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'OffsetModifier_WDTH_HORSEGALLOP')
	    );
}
function FP_CamWidthOffsetModifier_Sprint():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'OffsetModifier_WDTH_SPRINT')
	    );
}

//CAM OFFSETS WIDTH
function FP_CamWidthOffset():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_WDTH')
	    );
}
function FP_CamWidthOffset_InCombat():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_WDTH_INCOMBAT')
	    );
}
function FP_CamWidthOffset_FocusMode():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_WDTH_WITCHERSENSE')
	    );
}
function FP_CamWidthOffset_Horse():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_WDTH_HORSE')
	    );
}
function FP_CamWidthOffset_Boat():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_WDTH_BOAT')
	    );
}

//CAM OFFSETS HEIGHT
// function FP_CamHeightOffset():float{
	// return StringToFloat(
	    // theGame.GetInGameConfigWrapper()
	      // .GetVarValue('fps_mod_configs', 'Camera_height_width')
	    // );
// }
// function FP_CamHeightOffset_InCombat():float{
	// return StringToFloat(
	    // theGame.GetInGameConfigWrapper()
	      // .GetVarValue('fps_mod_configs', 'Offset_HGHT_INCOMBAT')
	    // );
// }
function FP_CamHeightOffset_FocusMode():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Offset_HGHT_WITCHERSENSE')
	    );
}

//CAM Z OFFSET
function FP_CamOffsetZ():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_Z_modifier')
	    );
}
function FP_CamOffsetZ_OnHorse():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_Z_modifier_HORSE')
	    );
}


