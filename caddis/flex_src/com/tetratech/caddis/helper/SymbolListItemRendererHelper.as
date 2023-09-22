//stores the cell data (whatever object is  supposed to
//be passed to the cell for rendering)
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.drawing.CShape;

private var cellData:Object;

/*
NOTE: Override the data	property of the ListItemRenderer
public function get data():Object
public function set data(value:Object):void

The data is the object being passed to the cell
to the displayed
*/
override public function set data(value:Object):void {
    cellData = value;
	if(cellData!=null)
	{
		//cast the shape
		var shape: CShape = value as CShape;
	 	//set the label
	 	shapeLabel.text = shape.label;
	 	//set the symbol
	 	if(shape.labelSymbolType == Constants.SYMBOL_ARROW_UP)
	 		shapeSymbol.source = Constants.SYMBOL_IMAGE_INCREASING;
	 	else if(shape.labelSymbolType == Constants.SYMBOL_DELTA)
	 		shapeSymbol.source = Constants.SYMBOL_IMAGE_CHANGE;
	 	else if(shape.labelSymbolType == Constants.SYMBOL_ARROW_DOWN)
	 		shapeSymbol.source = Constants.SYMBOL_IMAGE_DECREASING;
	 	else
	 		//shapeSymbol.width = 0;
	 		shapeSymbol.source = Constants.SYMBOL_IMAGE_NONE;	
	}else{
		//set to default shape label and symbol
		shapeLabel.text = "";
		//shapeSymbol.width = 0;
		shapeSymbol.source = Constants.SYMBOL_IMAGE_NONE;
	}
}

override public function get data():Object {
    return cellData;
}