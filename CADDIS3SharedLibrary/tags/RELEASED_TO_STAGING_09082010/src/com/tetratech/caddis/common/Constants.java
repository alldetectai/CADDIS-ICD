package com.tetratech.caddis.common;

public class Constants {
	//Shape type
	public final static String RECTANGLE_TYPE = "RECTANGLE";
	public final static String PENTAGON_TYPE = "PENTAGON";
	public final static String OCTAGON_TYPE = "OCTAGON";
	public final static String ROUND_RECTANGLE_TYPE = "ROUNDRECTANGLE";
	public final static String ELLIPSE_TYPE = "ELIPSE";
	public final static String HEXAGON_TYPE = "HEXAGON";
	public final static String OTHER_TYPE = "UNKNOWN TYPE";

	//LINE TYPE
	public final static String SINGLEARROWLINE_TYPE = "SINGLEARROWLINE";
	public final static String LINE_TYPE = "LINE";
	//LEGEND_TYPE
	public static long HUMAN_ACTIVITY = 20006;//7;
	public static long SOURCE = 20007;//8;
	public static long STRESSOR = 20008;//9;
	public static long BIOLOGICAL_RESPONSE = 20009;//10;
	public static long MODIFIYING_FACTOR = 20010;//11;
	public static long ADDITIONAL_STEP = 20011;//12;
	public static long MODE_OF_ACTION = 20012;//13;
	
	//shape symbol
	public final static long LL_DELTA_ID = 20026;//23;
	public final static long LL_UPWARD_ARROW_ID = 20027;//24;
	public final static long LL_DOWNWARD_ARROW_ID = 20028;//25; 

	
	public static long SHAPE_ATTR_TYPE_DIAGRAM = 20020;//21;
	public static long SHAPE_ATTR_TYPE_DISPLAY = 20021;//22;
	
//	//CITATIONS CONSTANTS
//	public final static long LL_NUM_VOL_ISSUE_PAGES_INFO_ID = 793;
//	public final static long LL_VOLUME_INFO_ID = 800; 
//	public final static long LL_PUBLISHER_INFO_ID = 805; 
//	public final static long LL_VOL_ISSUE_PAGES_INFO_ID = 806;
//	public final static long LL_JOURNAL_INFO_ID = 8632;
//	
//	//CITATION SOURCE LL
//	public final static int LL_ICM_REFERENCE_SOURCE_ID = 8631;
//	public final static int LL_CADLIT_REFERENCE_SOURCE_ID = 8629;
//	public final static int LL_CADDIS_REFERENCE_SOURCE_ID = 8630;
	
	//USE FOLLOWING VIEW NAMES TO RETREIVE LOOKUP VALUES FROM EACH TABLE
	public final static String LL_ORGANISM_VIEW_NAME = "V_ICD_LK_ORGANISM";
	public final static String LL_LEGEND_FILTER_VIEW_NAME = "V_ICD_LK_LEGEND_FILTER";
	public final static String LL_DISPLAY_VIEW_NAME = "V_ICD_LK_DISPLAY";
	public final static String LL_DIAGRAM_FILTER_VIEW_NAME = "V_ICD_LK_DIAGRAM_FILTER";
	public final static String LL_SHAPE_LABEL_SYMBOL_VIEW_NAME = "V_ICD_LK_SHAPE_LABEL_SYMBOL";
	public final static String LL_ROLE_VIEW_NAME = "V_ICD_LK_ROLE";
	public final static String LL_DIAGRAM_STATUS = "V_ICD_LK_DIAGRAM_STATUS";
	public final static String LL_PUBLICATION = "V_PUBLICATION";
	public final static String LL_PUBLICATION_TYPE = "V_PUBLICATION_TYPE";
	
	
	//columns names
	public final static String UPLOAD_REF_AUTHOR = "Author";
	public final static String UPLOAD_REF_YEAR = "Year";
	public final static String UPLOAD_REF_TITLE = "Title";
	public final static String UPLOAD_REF_JOURNAL= "Journal";
	public final static String UPLOAD_REF_VOLUME = "Volume";
	public final static String UPLOAD_REF_ABSTRACT = "Abstract";
	
	//ROLES LOOKUP VALUES
	public final static long LL_ADMIN_USER = 20029;//30;
	public final static long LL_ICD_USER = 20030;//31;
	public final static long LL_CADLIT_USER = 20031;//32;
	
	public final static String CADDIS_ADMINSISTRATOR = "CADDIS_ADMINISTRATOR";//20029
	public final static String CADDIS_ICD_USER = "CADDIS_ICD_USER";//20030;
	public final static String CADDIS_CADLIT_USER = "CADDIS_CADLIT_USER";//20031;
	public final static String CADDIS_ICD_PUBLIC_USER = "CADDIS_ICD_PUBLIC_USER";
	
	//applications in CADDIS System
	public final static String ICD_APPLICATION = "ICD_APPLICATION ";
	public final static String CADLIT_APPLICATION = "CADLIT_APPLICATION";
	public final static String REF_MANGR_APPLICATION = "REF_MANGR_APPLICATION";
	
	//DIAGRAM STATUS  LOOKUP VALUES
	public final static long LL_DRAFT_STATUS = 20022;
	public final static long LL_IN_REVIEW_STATUS = 20023;
	public final static long LL_PUBLISHED_STATUS = 20024;
	public final static long LL_ARCHIVED_STATUS = 20025;
	
	//PUBLICATION TYPE
	public final static long PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE = 1496;
	public final static long PUBLICATION_TYPE_ID_BOOK_CHAPTER = 1489;
	public final static long PUBLICATION_TYPE_ID_BOOK = 1490;
	public final static long PUBLICATION_TYPE_ID_REPORT = 1497;
	public final static long PUBLICATION_TYPE_ID_OTHER = 1500;
	
	//PUBLICATION ENTITY TYPE
	public final static long PUBLICATION_TYPE_ENTITY_ID = 17;
	//CADDIS PAGE ENTITY TYPE
	public final static long CADDIS_PAGE_ENTITY_ID = 65;
	
	public final static String YES = "Y";
	public final static String NO = "N";
	
	public final static String DELETE_CITATION_SUCCESS = "success";
	
	public final static String DIAGRAM_NAME = "DIAGRAM_NAME";
	public final static String DIAGRAM_CREATED_DATE = "CREATED_DT";
	public final static String DIAGRAM_CREATOR = "CREATOR_LAST_NAME";
	public final static String IAMLOCATOR = "IAMLocator";
	public final static int DIAGRAM_CHECK_IN_DAYS = 3;
}
