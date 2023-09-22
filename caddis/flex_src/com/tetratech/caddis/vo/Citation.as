package com.tetratech.caddis.vo
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Citation")]
	public class Citation
	{
		public var id:Number;
		public var title:String;
		public var author:String;
		//public var date:Number;
		public var keyword:String;
		public var createdBy:Number;
		public var created:Date;
		public var lastUpdate:Date;
    	public var lastUpdateBy:Number;
    	public var citationAbstract:String;
		public var citationUrl:String;
		public var journal:String;
		public var volumeIssuePagesInfo:String;
		public var displayTitle:String;
		public var cadlitSource:Boolean;
		public var filterValues:ArrayCollection;
		public var approved:Boolean;
		public var citationAnnotation:String;
		public var effectTerm:String;
		//these 3 fields are needed to upload refs
		public var errorMessage:String;
		public var valid:Boolean;
		public var status:Class;
		
		public var pubTypeId:Number;
		public var pubTypeCode:String;
		public var pubTypeDesc:String;
		public var pubId:Number;
		public var pubCode:String;
		public var pubDesc:String;
		public var year:String;
		public var doi:String;
		public var volume:Number;
		public var issue:String;
		public var startPage:String;
		public var endPage:String;
		public var book:String;
		public var editors:String;
		public var publishers:String;
		public var reportNum:String;
		public var pages:Number;
		public var source:String;
		public var type:String;
		public var inICD:Boolean;
		public var inCADDIS:Boolean;
		public var inCADLIT:Boolean;
		public var caddisPageName:String;
		public var caddisPageURL:String;
		public var exitDisclaimer:Boolean;
		public var evidenceList:ArrayCollection;
		
		public var causeEffectLinkage:ArrayCollection;
		
		public function Citation()
		{
			filterValues = new ArrayCollection();
			evidenceList = new ArrayCollection();
			causeEffectLinkage = new ArrayCollection();
		}
	}
}