package com.tetratech.caddis.common
{
	import mx.collections.ArrayCollection;
	
	public class Constants
	{
		public static const SEARCH_EPA_SOURCE:String = "EPA";
		public static const SEARCH_OTHER_SOURCE:String = "Other";
		
		//mode constants
		public static const MODE_VIEW:String = "view";
		public static const MODE_EDIT:String = "edit";
		public static const MODE_NONE:String = "none";
		public static const MODE_HOME:String = "home";
		public static const MODE_LINK:String = "link";
		public static const MODE_SEARCH:String = "search";
			
		
		//board constants
		public static const DEFAULT_BOARD_WIDTH:int = 1024;
		public static const DEFAULT_BOARD_HEIGHT:int = 768;
		//menu constants
		public static const MENU_WIDTH:int=1024;
		public static const MENU_HEIGHT:int=60;
		//inset constants
		public static const INSET_WIDTH:int = 256;
		public static const INSET_HEIGHT:int = 192;
		//board control constants
		public static const SLIDER_MIN_VALUE:int = 0;
		public static const SLIDER_MAX_VALUE:int = 100;
		public static const SLIDER_INTERVAL_VALUE:int = 10;
		public static const BOARD_CONTROL_WIDTH:int = 50;
		public static const BOARD_CONTROL_HEIGHT:int = 250;
		//accordion constants
		public static const ACCORDION_WIDTH:int = 250;
		public static const ACCORDION_HEIGHT:int = DEFAULT_BOARD_HEIGHT;
		public static const ACCORDION_TAB_MIN_HEIGHT:int = 20;
		public static const ACCORDION_TAB_DEFAULT_HEIGHT:int = DEFAULT_BOARD_HEIGHT/3;
		//diagram filter
		public static const DIAGRAM_FILTER_WIDTH:int = 150;
		public static const DIAGRAM_FILTER_HEIGHT:int = 230;
		//zoom constants
		public static const ZOOM_LEVEL_MIN:int = 0;
		public static const ZOOM_LEVEL_MAX:int = 10;
		public static const ZOOM_SCALE_INC:Number = 6/5;
		public static const ZOOM_SCALE_DEC:Number = 5/6;
		public static const ZOOM_ORIGIN_X:int = 512;
		public static const ZOOM_ORIGIN_Y:int = 384;
		//pan constants
		public static const PAN_DELTA_VALUE:int = 10;
		//sliding time constant
		public static const SLIDE_TIME_INTERVAL:int = 1;
		//tier constant
		//public static const NUMBER_OF_TIERS:int = 4;
		//public static const NUMBER_OF_SUB_TIERS:int = 3;
		public static const TIER_HEIGHT:int = 48;
		//collapse constants
		public static const COLLAPSE_HORIZONTAL_GAP:int = 30;
		//service
		public static const SERVICE_NAME:String = "caddisService";
		
		//images for diagram management
		[Embed(source="../../../../../images/help.png")]
		public static const help:Class;
		[Embed(source="../../../../../images/inset.png")]
		public static const inset:Class;
		[Embed(source="../../../../../images/refs.png")]
		public static const refs:Class;
		[Embed(source="../../../../../images/search.png")]
		public static const search:Class;
		[Embed(source="../../../../../images/comments.png")]
		public static const comment:Class;
		
		//board control images
		[Embed(source="../../../../../images/arrow_up.png")]
		public static const up:Class;
		[Embed(source="../../../../../images/arrow_down.png")]
		public static const down:Class;
		[Embed(source="../../../../../images/arrow_left.png")]
		public static const left:Class;
		[Embed(source="../../../../../images/arrow_right.png")]
		public static const right:Class;
		[Embed(source="../../../../../images/arrow_in.png")]
		public static const center:Class;
		[Embed(source="../../../../../images/zoom_in.png")]
		public static const zoom_in:Class;
		[Embed(source="../../../../../images/zoom_out.png")]
		public static const zoom_out:Class;
		
	
		//accordion
		[Embed(source="../../../../../images/triangle_right.png")]
		public static const closed:Class;
		[Embed(source="../../../../../images/triangle_down.png")]
		public static const opened:Class;
		
		//shapes
		[Embed(source="../../../../../images/additional_step.png")]
		public static const addStep:Class;
		[Embed(source="../../../../../images/human_activity.png")]
		public static const humanAct:Class;
		[Embed(source="../../../../../images/mode_action.png")]
		public static const modeAct:Class;
		[Embed(source="../../../../../images/modify_factor.png")]
		public static const modFac:Class;
		[Embed(source="../../../../../images/response.png")]
		public static const resp:Class;
		[Embed(source="../../../../../images/source.png")]
		public static const source:Class;
		[Embed(source="../../../../../images/stressor.png")]
		public static const stressor:Class;
		[Embed(source="../../../../../images/line.png")]
		public static const line:Class;
		[Embed(source="../../../../../images/arrow_line.png")]
		public static const arrowline:Class;
		
		//shape symbol images
		[Embed(source="../../../../../images/increasing.png")]
		public static const SYMBOL_IMAGE_INCREASING:Class;
		[Embed(source="../../../../../images/decreasing.png")]
		public static const SYMBOL_IMAGE_DECREASING:Class;
		[Embed(source="../../../../../images/change.png")]
		public static const SYMBOL_IMAGE_CHANGE:Class;
		[Embed(source="../../../../../images/blank.png")]
		public static const SYMBOL_IMAGE_NONE:Class;
		
		//parent-child relationship
		[Embed(source="../../../../../images/parent_child_close.png")]
		public static const PARENT_CHILD_CLOSE:Class;
		[Embed(source="../../../../../images/parent_child_open.png")]
		public static const PARENT_CHILD_OPEN:Class;
		[Embed(source="../../../../../images/child_open.png")]
		public static const CHILD_OPEN:Class;
		
		//other
		[Embed(source="../../../../../images/info.png")]
		public static const info:Class;
		[Embed(source="../../../../../images/tab.png")]
		public static const tab:Class;
		[Embed(source="../../../../../images/tab2.png")]
		public static const tab2:Class;
		[Embed(source="../../../../../images/tick.png")]
		public static const valid:Class;
		[Embed(source="../../../../../images/cross.png")]
		public static const invalid:Class;
		
		[Embed(source="../../../../../images/delete.png")]
		public static const deleteIcon:Class;
		
		[Embed(source="../../../../../images/save.png")]
		public static const saveIcon:Class;
		
		[Embed(source="../../../../../images/open_diagram.png")]
		public static const openDiagramIcon:Class;
		
		[Embed(source="../../../../../images/folder_page.png")]
		public static const diagramHistoryIcon:Class;
		
		[Embed(source="../../../../../images/p-c.png")]
		public static const parentChildIcon:Class;
		
		[Embed(source="../../../../../images/edit16.png")]
		public static const editIcon:Class;
		
		//fonts
		[Embed(source='../../../../../assets/arial.ttf', 
        fontName='myArialFont', 
        mimeType='application/x-font', 
        advancedAntiAliasing='false')] 
     	public static const EMBEDDED_ARIAL:Class;
		
		//LEGEND_TYPE
		public static const HUMAN_ACTIVITY:int = 20006;//7;
		public static const SOURCE:int = 20007;//8;
		public static const STRESSOR:int = 20008;//9;
		public static const BIOLOGICAL_RESPONSE:int = 20009;//10;
		public static const MODIFIYING_FACTOR:int = 20010;//11;
		public static const ADDITIONAL_STEP:int = 20011;//12;
		public static const MODE_OF_ACTION:int = 20012;//13;
		
		//symbol types
		public static const SYMBOL_DELTA:int = 20026;//23;
		public static const SYMBOL_ARROW_UP:int = 20027;//24;
		public static const SYMBOL_ARROW_DOWN:int = 20028;//25;
		
		//shape type attribute constants
		public static const SHAPE_ATTR_TYPE_DIAGRAM:int= 20020;//21;
		public static const SHAPE_ATTR_TYPE_DISPLAY:int = 20021;//22;
		
		//highlighting colors
		public static const VIEW_CLICK_COLOR:Number = 0x97DDFF;//0x71F377;//0xFCF97C;
		public static const VIEW_HIGHLIGHT_COLOR:Number = 0xB7ABCD;//0xAEAAF4;
		
		public static const KEYCODE_DELETE:int = 46;
		public static const KEYCODE_ESCAPE:int = 27;
		
		//USE FOLLOWING VIEW NAMES TO RETREIVE LOOKUP VALUES FROM EACH TABLE
		public static const LL_ORGANISM_VIEW_NAME:String = "V_ICD_LK_ORGANISM";
		public static const LL_LEGEND_FILTER_VIEW_NAME:String = "V_ICD_LK_LEGEND_FILTER";
		public static const LL_DISPLAY_VIEW_NAME:String = "V_ICD_LK_DISPLAY";
		public static const LL_DIAGRAM_FILTER_VIEW_NAME:String = "V_ICD_LK_DIAGRAM_FILTER";
		public static const LL_ROLE_VIEW_NAME:String = "V_ICD_LK_ROLE";
		public static const LL_DIAGRAM_STATUS:String = "V_ICD_LK_DIAGRAM_STATUS";
		public static const LL_PUBLICATION:String = "V_PUBLICATION";
		public static const LL_PUBLICATION_TYPE:String = "V_PUBLICATION_TYPE";
		
		public static const PUBLICATION_TYPE_JOURNAL_ARTICLE:int = 1496;
		public static const PUBLICATION_TYPE_BOOK_CHAPTER:int = 1489;
		public static const PUBLICATION_TYPE_BOOK:int = 1490;
		public static const PUBLICATION_TYPE_REPORT:int = 1497;
		public static const PUBLICATION_TYPE_OTHER:int = 1500;
		
		public static const LOOKUP_PUBLICATION_TYPE:String = "V_PUBLICATION_TYPE";
		public static const LOOKUP_JOURNAL:String = "V_PUBLICATION";
		
		public static const SINGLEARROWLINE_TYPE:String = "SINGLEARROWLINE";
		public static const LINE_TYPE:String = "LINE";
		
		public static const CADDIS_PAGE_ENTITY_ID:int = 65;
		//ROLE
		public static const LL_EPA_USER:Number = 20029;//30;
		public static const LL_REGISTERED_USER:Number = 20030;// 31;
		public static const LL_PUBLIC_USER:Number = 20031;//32;
	
		//DIAGRAM STATUS  LOOKUP VALUES
		public static const LL_DRAFT_STATUS:Number = 20022;
		public static const LL_IN_REVIEW_STATUS:Number = 20023;
		public static const LL_PUBLISHED_STATUS:Number = 20024;
		public static const LL_ARCHIVED_STATUS:Number = 20025;
	
		//sort by constants for diagram filter
		public static const DIAGRAM_NAME:String = "DIAGRAM_NAME";
		public static const DIAGRAM_CREATED_DATE:String = "CREATED_DT";
		public static const DIAGRAM_CREATOR:String = "CREATOR_LAST_NAME";
		
		public static const ICD_USER_GUIDE:String = "ICDUserGuide";
		
		public static const SYMBOL_INCREASING:String = "Increasing";
		
		public static const SYMBOL_DECREASING:String = "Decreasing";
	
		public static const SYMBOL_CHANGE:String = "Change in";
		
		//delta zero
		public static const DELTA_ZERO:Number = 0.001;
		
		//list of symbols
		public static const SYMBOLS:ArrayCollection = new ArrayCollection(
                [{label:"", value: 0},
                 {label:"Change in", value: Constants.SYMBOL_DELTA}, 
                 {label:"Increasing", value: Constants.SYMBOL_ARROW_UP}, 
                 {label:"Decreasing", value: Constants.SYMBOL_ARROW_DOWN}]);
		
		public static const SHAPE_SYMBOLS:ArrayCollection = new ArrayCollection(
			[ { label:"", icon:"", value: 0},
				{ label:"Human Activity", icon:Constants.humanAct, value:Constants.HUMAN_ACTIVITY },
				{ label:"Source", icon:Constants.source, value:Constants.SOURCE},
				{ label:"Stressor", icon:Constants.stressor, value:Constants.STRESSOR},
				{ label:"Response", icon:Constants.resp, value:Constants.BIOLOGICAL_RESPONSE},
				{ label:"Modifying Factor", icon:Constants.modFac, value:Constants.MODIFIYING_FACTOR },
				{ label:"Mode of Action", icon:Constants.modeAct, value:Constants.MODE_OF_ACTION},
				{ label:"Addition Step", icon:Constants.addStep, value:Constants.ADDITIONAL_STEP} ]);
					
		public static const INTRO_TEXT_P1:String =
		"Interactive Conceptual Diagrams (ICDs) are visual tools which use conceptual model diagrams as structural frameworks for organizing and accessing information about specific stressors. Information relevant to individual stressors is linked to diagrams illustrating relationships among stressors and their potential sources and biological effects. By clicking on the diagram you can access stressor-specific information on particular shapes and linkages, to gain a better understanding of how that stressor may be operating in you stream."
		
		public static const INTRO_TEXT_P2:String =
		"An ICM that provides supporting literature information currently is available for phosphorus – you can click on two or more shapes in the diagram to view citation information for references supporting the selected linkage (download the ICM instructions (PDF) (6 pp, 490K, About PDF) for detailed descriptions of the ICM structure and how to use it). The purpose of this ICM is to quickly and efficiently provide you with scientific papers relevant to specific linkages that interest you, which you can then apply in your own casual assessment.";
		
		public static const INTRO_TEXT_P3:String =
		"We are developing ICMs for additional stressors, and incorporating additional types of information into each ICM. Please contact us with your suggestions for the ICM project."
		
		public function Constants()
		{
			throw new Error("This class cannot be created");
		}
		
		//list of database(s)
		public static const DATABASE_SOURCES:ArrayCollection = new ArrayCollection(
			[{label:"", value: ""},
				{label:"All", value: "All"}, 
				{label:"EPA", value: "EPA"}, 
				{label:"Eco Evidence", value: "Eco"}]);
		
		public static const ACCESS_ARRAY:ArrayCollection = new ArrayCollection(
			[{label:"", value: ""},
				{label:"Open", value: "Open"}, 
				{label:"Private", value: "Private"}
				]);
	}
}