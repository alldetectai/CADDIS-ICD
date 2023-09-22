import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.UploadReferencesResult;
import com.tetratech.caddis.vo.Citation;

import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.net.FileReference;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.DataGrid;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

private var fileRef:FileReference;
private var result:ArrayCollection;
private var resultInfo;

public function init():void
{
	selectFile.addEventListener(MouseEvent.CLICK,handleSelectFile);
	viewResult.addEventListener(MouseEvent.CLICK,handleViewResult);
}

private function handleSelectFile(event:MouseEvent):void
{

	var textTypes:FileFilter = new FileFilter("XML File (*.xml)", "*.xml");
	var fileFilter:Array = new Array(textTypes);
	fileRef = new FileReference();
	fileRef.addEventListener(Event.SELECT, selectHandler);
	fileRef.addEventListener(Event.COMPLETE, completeHandler);
	fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleError);
	fileRef.addEventListener(ProgressEvent.PROGRESS,handleProgress);
    fileRef.browse(fileFilter);
}

private function handleViewResult(event:MouseEvent):void
{
    var s:Service = new Service();
	s.serviceHandler = getUploadInfo;
	s.getLastUploadedReferenceResults();
}

/* GET FILE HANDLER*/
private function selectHandler(event:Event):void
{
	fileProgress.setProgress(0,100);
	fileProgress.label = "Uploaded 0%";
	viewResult.enabled = false;
	var request:URLRequest = new URLRequest("UploadReferences?currUserID="+Model.user.userId);
    fileRef.upload(request);
}
	
/* UPLOAD FILE HANDLERS */
private function completeHandler(event:Event):void
{
    viewResult.enabled = true;
    Alert.show("Your file has been uploaded successfully. Please click on View Results to see the results of the upload.","INFORMATION",Alert.OK,null,null,null,Alert.OK);
}

private function getUploadInfo(event:ResultEvent):void
{
	result = event.result as ArrayCollection;
	resultInfo = new UploadReferencesResult();
	resultInfo.addEventListener(FlexEvent.INITIALIZE,handleUploadInfoCreation);
	//add to manager
	PopUpManager.addPopUp(resultInfo, this, true);
	PopUpManager.centerPopUp(resultInfo);
}

private function handleUploadInfoCreation(event:FlexEvent):void
{
	//add status img to results
	for(var i:int=0;i<result.length;i++){
		var r:Citation = result.getItemAt(i) as Citation;
		if(r.valid)
			r.status = Constants.valid;
		else
			r.status = Constants.invalid;
	}
	//assign results
	resultInfo.addEventListener(CloseEvent.CLOSE,closePanel);
	resultInfo.resultGrid.dataProvider = result;
	resultInfo.resultGrid.addEventListener(FlexEvent.CREATION_COMPLETE,setRelativeWidths);
}

private function setRelativeWidths(event:FlexEvent):void
{
	var grid:DataGrid = event.target as DataGrid;
	grid.columns[0].width = grid.width * 0.2;
	grid.columns[1].width = grid.width * 0.15;
	grid.columns[2].width = grid.width * 0.65;
}

private function closePanel(event:CloseEvent):void
{
	PopUpManager.removePopUp(resultInfo);
	resultInfo = null;
	result = null;
	//set focus 
	this.setFocus();
}

/* PROGRESS HANDLER */
private function handleProgress(event:ProgressEvent):void
{
	var complete:Number = Math.ceil(event.bytesLoaded/event.bytesTotal*100);
	fileProgress.setProgress(complete,100);
	fileProgress.label = "Uploaded "+complete+"%";
}

/* ERROR HANDLING */
public function handleError(event:IOErrorEvent):void
{
	var message:String = "An error has occured: "+ event.toString();
	Alert.show(message,"Error",Alert.OK,null,null,null,Alert.OK);
}

