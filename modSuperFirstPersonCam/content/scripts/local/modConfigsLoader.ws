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

//HIDE GERALT
function FP_HideGeralt():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Hide_geralt');
}

function FP_HideGeralt_FocusMode():bool{
	return theGame.GetInGameConfigWrapper().GetVarValue('fps_mod_configs', 'Hide_geralt_in_witchersense');
}

//CAM OFFSETS WIDTH
function FP_CamWidthOffset():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_offset_width')
	    );
}
function FP_CamWidthOffset_InCombat():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_offset_width_INCOMBAT')
	    );
}
function FP_CamWidthOffset_FocusMode():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_offset_width_WITCHERSENSE')
	    );
}

//CAM OFFSETS HEIGHT
function FP_CamHeightOffset():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_height_width')
	    );
}
function FP_CamHeightOffset_InCombat():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_offset_height_INCOMBAT')
	    );
}
function FP_CamHeightOffset_FocusMode():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_offset_height_WITCHERSENSE')
	    );
}

//CAM Z OFFSET
function FP_CamOffsetZ():float{
	return StringToFloat(
	    theGame.GetInGameConfigWrapper()
	      .GetVarValue('fps_mod_configs', 'Camera_Z_modifier')
	    );
}

