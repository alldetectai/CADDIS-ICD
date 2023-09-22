import com.tetratech.caddis.common.Constants;

//private properties 
private var _text:String;
private var _symbolType:int;
private var _textLength:int=-1;

//gettter and setters for properties
public function set symbolType(value:int):void
{
	_symbolType = value;
}

public function get symbolType():int
{
	return _symbolType;
}

public function set text(value:String):void
{
   _text = value;
}

public function get text():String
{
	return _text;
}

public function set textLength(value:int):void
{
	_textLength = value;
}

public function get textLength():int
{
	return _textLength;
}

//initializer
public function init():void
{
	//set the label
	shapeLabel.text = _text;
	//set the symbol type
	if(_symbolType == Constants.SYMBOL_ARROW_UP)
 		shapeSymbol.source = Constants.SYMBOL_IMAGE_INCREASING;
 	else if(_symbolType == Constants.SYMBOL_DELTA)
 		shapeSymbol.source = Constants.SYMBOL_IMAGE_CHANGE;
 	else if(_symbolType == Constants.SYMBOL_ARROW_DOWN)
 		shapeSymbol.source = Constants.SYMBOL_IMAGE_DECREASING;
 	else
 		//shapeSymbol.source = Constants.SYMBOL_IMAGE_NONE;	
		shapeSymbol.width = 0;
	//check if you need to set the text length
	if(_textLength != -1)
	{
		//set the text length to an upper bound
		//if necessary
		if(getTextWidth()>_textLength)
		{
			shapeLabel.width = _textLength;
		}
	}
}

private function getTextWidth():int
{
			//shapeLabel.regenerateStyleCache(false);
			//measure the text length
			var m:TextLineMetrics = shapeLabel.measureText(_text);	
			return m.width;
}