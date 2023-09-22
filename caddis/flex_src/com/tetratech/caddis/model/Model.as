package com.tetratech.caddis.model
{
	import com.tetratech.caddis.common.Constants;
	import com.tetratech.caddis.drawing.CDiagram;
	import com.tetratech.caddis.view.Menu;
	import com.tetratech.caddis.vo.User;
	
	import mx.collections.ArrayCollection;
	
	public class Model
	{
		
		//mode
		public static var mode:String = MODE_NONE;
		public static const MODE_NONE:String = "none";
		public static const MODE_NEW:String = "new";
		public static const MODE_EXISTING:String = "existing";
		
		//diagram
		public static var diagram:CDiagram=null;
		
		//selected diagram in drop down list of edithome poopup
		public static var selectedDiagram:CDiagram=null;
		public static var selectedDiagramStatus:String = "";
		public static var icdUserGuideUrl:String = "";
		
		public static var sourceDB:ArrayCollection=null;
		public static var selectedSourceDB:String;
		
		//citations
		public static var citations:ArrayCollection=null;
		
		//board
		public static var BOARD_WIDTH:int=Constants.DEFAULT_BOARD_WIDTH;
		public static var BOARD_HEIGHT:int=Constants.DEFAULT_BOARD_HEIGHT;
		
		//inset
		public static var INSET_TO_BOARD_RATIO:Number=Constants.INSET_WIDTH/Constants.DEFAULT_BOARD_WIDTH;
		
		//zooom
		public static var INITIAL_ZOOM_SCALE:Number=1;
		
		//dashed lines
		public static var DASHED_LINES_VERTICAL_GAP:Number=0;
		
		//a pointer to the menu
		//public static var menu:Menu;
		
		//list of new citations added
		public static var addedNewCitation:Boolean = false;
		public static var newCitations:ArrayCollection;
		
		//current user of the app
		public static var user:User;
		
		public function Model()
		{
			 throw new Error("This class cannot be created");
		}
		
	}
}