// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.vo.User;

import flash.events.MouseEvent;

import mx.events.FlexEvent;
import mx.rpc.events.ResultEvent;

private var registerUser:RegisterUserPopUp=null;

private function handleRegisterUser(event:MouseEvent):void
{
	//create pop up panel
	registerUser = new RegisterUserPopUp();
	registerUser.addEventListener(FlexEvent.INITIALIZE, handleRegisterUserInit);
	registerUser.addEventListener(CloseEvent.CLOSE, closeRegisterUserCloseEvent);

	//add to manager
	PopUpManager.addPopUp(registerUser, this.parent.parent, true);
	PopUpManager.centerPopUp(registerUser);
	registerUser.y = 100;	
}

private function handleRegisterUserInit(event:FlexEvent):void
{
	registerUser.saveb.addEventListener(MouseEvent.CLICK, handleSaveRegisterUser);
	registerUser.cancelb.addEventListener(MouseEvent.CLICK, closeRegisterUserMouseEvent);
}

private function handleSaveRegisterUser(event:MouseEvent):void
{
	registerUser.password.errorString = "";
	//validate errors 
	var valArray:Array = new Array();
	
	valArray.push(registerUser.valFName);
	if(registerUser.mname.text.length > 0) {
		valArray.push(registerUser.valMName);
	}
	valArray.push(registerUser.valLName);
	valArray.push(registerUser.valUName);
	valArray.push(registerUser.valPassword);
	valArray.push(registerUser.valConfirmPassword);
	valArray.push(registerUser.valEmail);
	var validatorErrorArray:Array = Validator.validateAll(valArray);

	if(validatorErrorArray.length == 0)
	{
		if(registerUser.password.text != registerUser.confirmPassword.text) {
			registerUser.password.errorString = "Passowrd Mismatch.";
		}
		else {
			var s:Service = new Service();
			s.serviceHandler = handleCheckExistingUserResponse;
			s.checkExistingUsername(registerUser.uname.text);
		}
	}
	else
	{
		registerUser.error.visible = true;
	}
}

private function handleCheckExistingUserResponse(event:ResultEvent):void
{
	var userExists:Boolean = event.result as Boolean;
	if(!userExists) {
		var newUser:User = new User();
		newUser.firstName = registerUser.fname.text;
		newUser.lastName = registerUser.lname.text;
		newUser.middleName = registerUser.mname.text;
		newUser.userName = registerUser.uname.text;
		newUser.password =  registerUser.password.text;
		newUser.email = registerUser.email.text;
		newUser.roleId = Constants.LL_REGISTERED_USER;
		var s:Service = new Service();
		s.serviceHandler = handleSaveRegisterUserResponse;
		s.saveRegisteredUser(newUser);
	} else
		Alert.show("Same username exists in the application, please choose another username.", "INFORMATION", Alert.OK);
}

private function handleSaveRegisterUserResponse(event:ResultEvent):void
{
	closeRegisterUser();
	Alert.show("You have successfully registered.", "INFORMATION", Alert.OK);
}

private function closeRegisterUser():void
{
	PopUpManager.removePopUp(registerUser);
	registerUser = null;
	//set focus 
	this.setFocus();
}

private function closeRegisterUserCloseEvent(event:CloseEvent):void
{
	closeRegisterUser();
}

private function closeRegisterUserMouseEvent(event:MouseEvent):void
{
	closeRegisterUser();
}
