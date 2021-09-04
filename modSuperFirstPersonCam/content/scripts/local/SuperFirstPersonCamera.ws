quest function testms()
{
	getModsSingleton().Get();
}
exec function testms2()
{
	getModsSingleton().Get();
}
function getModsSingleton():ModsSingletonClass
{	
    var singleton : ModsSingletonClass;
    var template : CEntityTemplate;
    var tags: array<CName>;

    singleton = (ModsSingletonClass)theGame.GetEntityByTag('MODS_SINGLETON');

    if (!singleton) {
        template = (CEntityTemplate)LoadResource("dlc/modtemplates/bootstrap/modstorage.w2ent", true);
        tags.PushBack('MODS_SINGLETON');
        singleton = (ModsSingletonClass) theGame.CreateEntity(
            template, thePlayer.GetWorldPosition(), , , , , PM_Persist, tags);
		singleton.Init();
    }

    return singleton;
	

	// if( FactsQuerySum( "fpcam_init" ) > 0 && false)
	// {
		// singleton = (new ModsSingletonClass in theGame);//.globalExemplar;
	// }
	// else
	// {
	    // singleton = new ModsSingletonClass in theGame;
		// singleton.globalExemplar=singleton;
		// singleton.Init();
		// FactsAdd( "fpcam_init" );
	// }
    // return singleton;	
}   
   
class ModsSingletonClass extends CPeristentEntity 
{
    public var globalExemplar : ModsSingletonClass;
    var num : float;

    public function Init()
	{  
	    num=RandF();
	}

    public function Get()
	{
		//theGame.GetGuiManager().ShowNotification('Work' , 2000);
	    theGame.GetGuiManager().ShowNotification('Work' + FloatToString(num), 2000);
	}
}

