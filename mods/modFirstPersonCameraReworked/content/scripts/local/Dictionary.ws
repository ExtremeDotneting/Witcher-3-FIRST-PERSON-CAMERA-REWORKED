class DictionaryItem
{
	public var key : IScriptable;	
	public var value : IScriptable;	
}

class Dictionary
{
	var arr : array<DictionaryItem>;	
	var objNull : IScriptable;
		
	function FindKeyIndex(key : IScriptable) : int
	{
		var i, s : int;
		var val : float;	
		
		s = arr.Size();
		if( s > 0 )
		{			
			for( i=0; i<s; i+=1 )
			{
				if(arr[i].key = key)
				{
					return i;
				}
			};
		}
		return -1;					
	}
	
	public function Remove(key: IScriptable)
	{
		Set(key, objNull);
	}
	
	
	public function Set(key: IScriptable, value: IScriptable)
	{
		var index : int;
		var item : DictionaryItem;
		
		index = FindKeyIndex(key);
		if(index<0){
			item=new DictionaryItem in this;
			item.key=key;
			item.value=value;
			arr.PushBack(item);
		}
		arr[index].value=value;
	}
	
	public function Get(key: IScriptable) : IScriptable
	{
		var index : int;
		
		index = FindKeyIndex(key);
		if(index<0){
			return objNull;
		}
		return arr[index].value;
	}
}
