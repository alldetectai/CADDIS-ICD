package com.tetratech.caddis.service
{
	import com.tetratech.caddis.common.Constants;
	import com.tetratech.caddis.drawing.CDiagram;
	import com.tetratech.caddis.model.Model;
	import com.tetratech.caddis.vo.Citation;
	import com.tetratech.caddis.vo.Comment;
	import com.tetratech.caddis.vo.DownloadData;
	import com.tetratech.caddis.vo.LookupValue;
	import com.tetratech.caddis.vo.Term;
	import com.tetratech.caddis.vo.User;
	
	import flash.display.Shape;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	/* This class is wrapper for the RemoteObject */
	public class Service
	{
		//reference (pointer) to a service function handler 
		//this is used to assign a function as the handler
		//of the results retrieved from a back-end call
		//through BlaseDS to the services layer
		public var serviceHandler:Function=null;
		//reference to the remove object
		private var remoteObject:RemoteObject=null;
			
		//constructor
		public function Service()
		{
			remoteObject = new RemoteObject();
			remoteObject.destination = Constants.SERVICE_NAME;
			remoteObject.addEventListener(ResultEvent.RESULT,handleResult);
			remoteObject.addEventListener(FaultEvent.FAULT,handleFault);
		}
		
	
		/* GENERAL PURPOSE HANDLERS */
		private function handleResult(event:ResultEvent):void 
		{
			var handler:Function = serviceHandler;
			handler(event);		
		}
			
		private function handleFault(event:FaultEvent):void {
				var message:String = "An error has occured: "+ event.fault.faultString;
				Alert.show(message,"Error",Alert.OK,null,null,null,Alert.OK);
		}
		/* END */
		
		//SERVICE METHODS//
		public function existsDiagramWithName(name:String):void
		{
			remoteObject.existsDiagramWithName(name);
		}
		
		//RETURN ID OF DAIGRAM NEEDED FOR RENAME DIAGRAM
		public function checkDiagram(name:String):void
		{
			remoteObject.checkDiagram(name);
		}
		
		
		public function saveDiagram(d:CDiagram):void
		{
			if(d.id > 0)
			{
				remoteObject.updateDiagram(d);
			}
			else
			{
				remoteObject.saveDiagram(d);
			}
		}
		
		public function saveDiagramAs(d:CDiagram):void
		{
			remoteObject.saveDiagramAs(d);
		}
		
		public  function loadDiagram(id:Number):void
		{
			remoteObject.getDiagram(id);
		}
		
		public  function getAllDiagrams():void
		{
			remoteObject.getAllDiagrams();
		}
		
		public function getPublishedDiagrams():void
		{
			remoteObject.getPublishedDiagrams();
		}
		
		public function getDiagramsByUser(searchTerm:String, sortBy:String, userId:Number):void
		{
			remoteObject.getDiagramsByUser(searchTerm, sortBy, userId);
		}
		
		
//		public function getDiagramsForEPAUser(userId:Number):void
//		{
//			remoteObject.getDiagramsForEPAUser(userId);
//		}
//		
//		public function getDiagramsForRegisteredUser(userId:Number):void
//		{
//			remoteObject.getDiagramsForRegisteredUser(userId);
//		}
		
		public  function searchCitationsNShapes(filterList:ArrayCollection, searchTerm:String):void
		{
			remoteObject.searchCitationsNShapes(filterList, searchTerm);
		}
		
		public  function searchCitationsByCauseNEffect(causeTerm:String, effectTerm:String, sourceType:String):void
		{
			remoteObject.searchCitationsByCauseNEffect(causeTerm, effectTerm, sourceType);
		}
		
		public  function searchCitationsByCauseNEffects(causeTerm:String, effectTerms:ArrayCollection):void
		{
			remoteObject.searchCitationsByCauseNEffects(causeTerm, effectTerms, Model.diagram.id);
		}
		
		public  function searchCitations(searchTerm:String):void
		{
			remoteObject.searchCitations(searchTerm);
		}
		
		public  function saveDiagramAsImage(encodedData:ByteArray):void
		{
			remoteObject.saveDiagramAsPNGImage(Model.diagram.name,encodedData);
		}
		
		public  function saveDiagramEvidencesAsCSV(encodedData:ByteArray):void
		{
			remoteObject.saveDiagramEvidencesAsCSV(Model.diagram.name,encodedData);
		}
		
		public function getLegentType():void
		{
			remoteObject.getLookupByType(Constants.LL_LEGEND_FILTER_VIEW_NAME);
		}
		
		public  function getOrganismFilters():void
		{
			remoteObject.getLookupByType(Constants.LL_ORGANISM_VIEW_NAME);
		}
		
		public  function getAllCitationsWithFilters():void
		{
			remoteObject.getAllCitationsAndFilters();
		}
		
		public  function getCitation(citationId:Number):void
		{
			remoteObject.getCitation(citationId);
		}
		
		public  function getCitationsByIDs(filterList:ArrayCollection, citationIds:ArrayCollection):void
		{
			remoteObject.getCitationsByIDs(filterList, citationIds);
		}
		
		public  function getSelectedLinkages(filterList:ArrayCollection, clickedShapes:ArrayCollection):void
		{
			remoteObject.getSelectedLinkages(filterList, clickedShapes);
		}
		
		public  function getOrganisms():void
		{
			remoteObject.getLookupByType(Constants.LL_ORGANISM_VIEW_NAME);
		}
		
		public  function getAllCitations():void
		{
			remoteObject.getAllCitations();
		}

		public  function getCitationsInReview():void
		{
			remoteObject.getCitationsInReview();
		}
		
		public  function saveCitation(citation:Citation):void
		{
			remoteObject.saveCitation(citation);
		}
		
		public function approveCitations(citationIds:ArrayCollection):void
		{
			remoteObject.approveCitations(citationIds);
		}
		
		public  function updateCitation(citation:Citation):void
		{
			remoteObject.updateCitation(citation);
		}
		
		public  function getLinakgesByCitationIdNDiagramId(citationId:Number, diagramId:Number):void
		{
			remoteObject.getLinakgesByCitationIdNDiagramId(citationId, diagramId);
		}
		
		public  function getDiagramNamesByCitationIdNUser(citationId:Number, userId:Number):void
		{
			remoteObject.getDiagramNamesByCitationIdNUser(citationId, userId);
		}
		
		public  function getDiagramNamesByCitationID(citationId:Number):void
		{
			remoteObject.getDiagramNamesByCitationID(citationId);
		}
		
		public function saveDownloadData(data:DownloadData):void
		{
			remoteObject.saveDownloadData(data);
		}
		
		public function getLastUploadedReferenceResults():void
		{
			remoteObject.getLastUploadedReferenceResults();
		}
		
		public function saveUserToServer(user:User):void
		{
			remoteObject.saveUserToServer(user);
		}
		
		public function sendInfoToServer(diagramId:Number,user:User):void
		{
			remoteObject.sendInfoToServer(diagramId,user);
		}
		
		public function checkoutDiagram(diagramId:Number,user:User):void
		{
			remoteObject.checkoutDiagram(diagramId,user);
		}
		
		public  function saveDiagramComment(comment:Comment):void
		{
			remoteObject.saveDiagramComment(comment);
		}
		
		public  function getCommentsByDiagramId(diagramId:Number, isInternalComments:Boolean):void
		{
			remoteObject.getCommentsByDiagramId(diagramId, isInternalComments);
		}
		
		public  function saveRegisteredUser(user:User):void
		{
			remoteObject.saveRegisteredUser(user);
		}
		
		public function checkExistingUsername(username:String):void
		{
			remoteObject.checkExistingUsername(username);
		}
		
		public function authenticateUser(username:String, password:String):void
		{
			remoteObject.authenticateUser(username, password);
		}
		
		public function getAllUsers():void
		{
			remoteObject.getAllUsers();
		}
		
		public function updateDiagramStatus(diagramId:Number, diagramStatusId:Number,
			goldSeal:Boolean, islocked:Boolean, lockedUserId:Number):void
		{
			remoteObject.updateDiagramStatus(diagramId, diagramStatusId,
					goldSeal, islocked, lockedUserId);
		}
		
		public function updateDiagram(diagram:CDiagram):void
		{
			remoteObject.updateDiagram(diagram);
		}
		
		public function updateDiagramInfo(diagram:CDiagram):void
		{
			remoteObject.updateDiagramInfo(diagram);
		}
		
		public function insertCitation(c:Citation):void
		{
			remoteObject.insertCitation(c);
		}
		
		public function getAllAuthors():void
		{
			remoteObject.getAllAuthors();
		}
		
		public function getAllTitles():void
		{
			remoteObject.getAllTitles();
		}
		
		public function getLookupByType(type:String):void
		{
			remoteObject.getLookupByType(type);
		}

		public function getDuplicateCitations(c:Citation):void
		{
			remoteObject.getDuplicateCitations(c);
		}
		
		public function insertNewLookup(lv:LookupValue, typeEntityId:Number, userId:Number):void
		{
			remoteObject.insertNewLookup(lv, typeEntityId, userId);
		}
		
		public function deleteDiagram(diagramId:Number):void
		{
			remoteObject.deleteDiagram(diagramId);
		}
		
		public function updateDiagramDetails(diagram:CDiagram, userId:Number, diagramId:Number):void
		{
			remoteObject.renameDiagram(diagram, userId, diagramId);
		}
		
		public function getRevisionDiagrams(diagramId:Number):void
		{
			remoteObject.getRevisionDiagrams(diagramId);
		}
		
		public function loadRevisionDiagramById(revDiagramId:Number):void
		{
			remoteObject.loadRevisionDiagramById(revDiagramId);
		}
		
		public function deleteRevisionDiagram(revDiagramId:Number):void
		{
			remoteObject.deleteRevisionDiagram(revDiagramId);
		}
		
		public  function updateUserLogOut(user:User):void
		{
			remoteObject.updateUserLogOut(user);
		}
		
		public function getSessionInfo():void
		{
			remoteObject.getSessionInfo();
		}
		
		public function setSessionInfo(sessionID:String):void
		{
			remoteObject.setSessionInfo( sessionID);
		}
		
		public function checkIfAuthenticated(sessionID:String):void
		{
			remoteObject.checkIfAuthenticated(sessionID);
		}
		
		public function updateSessionLastUpdateTS():void
		{
			remoteObject.updateSessionLastUpdateTS();
		}
		
		public function getConfiguration():void
		{
			remoteObject.getConfiguration();
		}
		
		public function searchTerms(searchTerm:String, exactMatch:Boolean, isStand:Boolean):void
		{
			remoteObject.searchTerms(searchTerm, exactMatch, isStand);
		}
		
		public function saveTerm(newTerm:Term, userId:Number):void
		{
			remoteObject.saveTerm(newTerm, userId);
		}
		
		public function getCauseEffectByCitationID(citationId:Number):void
		{
			remoteObject.getLinakgesByCitationID(citationId);
		}
		
		public function getAllTerms(isStand:Boolean):void
		{
			remoteObject.getAllTerms(isStand);
		}
		
		public function getAllEvidenceForCitation(citationId:Number):void
		{
			remoteObject.getAllEvidenceForCitation(citationId);
		}
		
		public function getDiagramEvidences(diagramId:Number):void
		{
			remoteObject.getDiagramEvidences(diagramId);
		}
		
		public function getEvidencesForAllDiagramByCitationId(citationId:Number):void
		{
			remoteObject.getEvidencesForAllDiagramByCitationId( citationId);
		}
		
		public function searchEvidenceByDaigramShapeFrom(causeTerm:String, effectTerms:ArrayCollection, diagramId:Number)
		{
			remoteObject.searchEvidenceByDaigramShapeFrom(causeTerm, effectTerms, diagramId);
		}
		//* END *//
	}
}