//Fast access
function myMods() : ModsSingletonClass
{
	if(!thePlayer.ModsSingleton)
	{
		thePlayer.ModsSingletonInit();
		thePlayer.ModsSingleton.Init();
	}
	return thePlayer.ModsSingleton;
}

function FPMod() : FPModClass{
	return myMods().FP();
}
	
//Class
class ModsSingletonClass
{   
    var fpMod : FPModClass;

	public function Init()
	{
	    fpMod=new FPModClass in this;
		fpMod.Init();
	}
	
    public function FP():FPModClass
	{
	    return fpMod;
	}
}