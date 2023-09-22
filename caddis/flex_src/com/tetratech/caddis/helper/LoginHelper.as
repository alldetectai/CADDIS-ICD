
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.Login;
import com.tetratech.caddis.vo.User;

import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.rpc.events.ResultEvent;

private var loginPopUp:Login=null;

private function handleLoginPopUpCreation(event:MouseEvent):void
{
	//create pop up panel
	loginPopUp = new Login();
	loginPopUp.addEventListener(FlexEvent.INITIALIZE, handleLoginInit);
	loginPopUp.addEventListener(CloseEvent.CLOSE, closeLoginCloseEvent);

	//add to manager
	PopUpManager.addPopUp(loginPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(loginPopUp);
	loginPopUp.y = 100;	
}

public function startLogin(parentContainer:DisplayObject):void
{
	//create pop up panel
	loginPopUp = new Login();
	loginPopUp.addEventListener(FlexEvent.CREATION_COMPLETE, handleLoginInit);
	//add to manager
	PopUpManager.addPopUp(loginPopUp,parentContainer,true);
	PopUpManager.centerPopUp(loginPopUp);
	loginPopUp.y=100;
}

private function handleLoginInit(event:FlexEvent):void
{
	loginPopUp.loginb.addEventListener(MouseEvent.CLICK, handleLogin);
	loginPopUp.cancelb.addEventListener(MouseEvent.CLICK, closeLoginMouseEvent);
	loginPopUp.username.setFocus();
}

private function handleLogin(event:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(loginPopUp.valUserName);
	valArray.push(loginPopUp.valPassword);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//close the pop up if user can log in
	if(validatorErrorArray.length == 0)
	{
		//update the model
		var username:String = loginPopUp.username.text;
		var password:String = loginPopUp.password.text;
		var s:Service = new Service();
		s.serviceHandler = handleAuthenticateUserResponse;
		s.authenticateUser(username, password);
		loginPopUp.loginb.enabled = false;
		loginPopUp.cancelb.enabled = false;
	}
	else
	{
		loginPopUp.error.visible = true;
	}
}

private function handleAuthenticateUserResponse(event:ResultEvent):void
{
	var user:User = event.result as User;
	if(user != null) {
		Model.user = user;
		resetLoginButton();
		closeLoginPopUp();
		Alert.show("Authentication successful.", "INFORMATION", Alert.OK);
		
	} else {
		loginPopUp.loginb.enabled = true;
		loginPopUp.cancelb.enabled = true;
		Alert.show("Authentication Failed. Please try again.", "WARNING", Alert.OK);
	}
}

private function closeLoginPopUp():void 
{
	//remove pop up
	PopUpManager.removePopUp(loginPopUp);
	loginPopUp = null;	
	//set focus 
	this.setFocus();	
}

private function closeLoginCloseEvent(event:CloseEvent):void
{
	closeLoginPopUp();
}

private function closeLoginMouseEvent(event:MouseEvent):void
{
	closeLoginPopUp();
}