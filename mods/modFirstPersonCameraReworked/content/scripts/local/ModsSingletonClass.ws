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
	var visibilityControlClass : VisibilityControlClass;

	public function Init()
	{
	    fpMod=new FPModClass in this;
		fpMod.Init();
		
		visibilityControlClass = new VisibilityControlClass in this;
	}
	
    public function FP():FPModClass
	{
	    return fpMod;
	}
	
	public function VisibilityControl():VisibilityControlClass
	{
	    return visibilityControlClass;
	}
}