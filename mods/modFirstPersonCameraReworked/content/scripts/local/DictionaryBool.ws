class NullableBool extends IScriptable
{
    public var boolValue : bool;	
}

class DictionaryBool
{
	var dict : Dictionary;	
	
	public function Remove(key: IScriptable)
	{
		dict.Remove(key);
	}
	
	public function Set(key: IScriptable, value: bool)
	{
		var nullableBool: NullableBool;
		nullableBool=new NullableBool in this;
		nullableBool.boolValue=value;
		dict.Set(key, nullableBool);
	}
	
	public function Get(key: IScriptable) : bool
	{
		var nullableBool: NullableBool;
		nullableBool=(NullableBool)dict.Get(key);
		return nullableBool.boolValue;
	}
}
