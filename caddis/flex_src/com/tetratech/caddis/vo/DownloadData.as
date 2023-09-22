package com.tetratech.caddis.vo
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.DownloadData")]
	public class DownloadData
	{
		public var citationIds:ArrayCollection;
		public var format:String;
		public var includeAbstract:Boolean;
		public var includeLinkage:Boolean;
		public var selectedLinakge:ArrayCollection;
		
		public function DownloadData()
		{
			citationIds = new ArrayCollection();
			selectedLinakge = new ArrayCollection();
		}
	}
}