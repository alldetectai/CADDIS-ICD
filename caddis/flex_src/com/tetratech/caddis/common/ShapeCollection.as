package com.tetratech.caddis.common
{
	import com.tetratech.caddis.drawing.CShape;
	
	import mx.collections.ArrayCollection;
	
	/*
		This class is a wrapper for an Array Collection
		and uses the add item method of the 
		Array Collection to sorts items (shapes) based on the 
		tier index and the horizontal (x) position of a shape
		inside of the tier
	*/
	public class ShapeCollection
	{
		public var _shapes:ArrayCollection;
		
		public function ShapeCollection()
		{
			_shapes = new ArrayCollection();
		}
		
		/* 
			This methods adds an array collection to be 
			monitored by the shape collection 
		*/
		public function addCollection(ac:ArrayCollection):void
		{
			//remove previous items
			removeAll();
			//set _shapes to point to ac
			_shapes = ac;
			//clone shapes list - IMPORTANT: Need to do this to avoid a the
			//issue of grabbing the same item twice or more from the _shapes collection
			var _shapesClone:ArrayCollection = ArrayCollectionUtil.copyArrayCollection(_shapes);
			//re-add all times to make sure they are order correctly
			for(var i:int=0;i<_shapesClone.length;i++)
			{
				reAddItem(_shapesClone[i]);
			}
			//clear shapes clones
			_shapesClone.removeAll();
			_shapesClone = null;
		}
		
		/* This method adds an item to the collection */
		public function addItem(item:CShape):void
		{
			trace('processing '+item.label);
			var foundPosition:Boolean = false;
			//find index where to insert new item
			for(var i:int=0;i<_shapes.length;i++)
			{	
				//get current shape in the list
				var s:CShape = _shapes[i]; 
				//found position
				if(item.binIndex < s.binIndex)
				{
					foundPosition = true;
					break;
				}
				//bubble down - compare with next one
				else if(item.binIndex > s.binIndex)
				{
					continue;
				}
				//if tier index is the same
				//compare the horizontal coordinates 
				else
				{
					if(item.origin.x < s.origin.x)
					{
						foundPosition = true;
						break;
					}
					//skip to next item if x position is 
					//greater or equal
					else if(item.origin.x > s.origin.x || item.origin.x == s.origin.y)
					{
						continue;
					}
				
				}
			
			}
			//insert new item and shift additional items
			//down the list if necessary
			if(!foundPosition)
				_shapes.addItem(item);
			else
				_shapes.addItemAt(item,i);
		}
		
		/* This method adds the item back to the collection */
		public function reAddItem(item:CShape):void
		{
			//first remove the item from the collection
			_shapes.removeItemAt(_shapes.getItemIndex(item));
			//try to add it back
			addItem(item);
		}
		
		public function getItemIndex(s:CShape):int
		{
			return _shapes.getItemIndex(s);
		}
		
		public function getItemAt(index:int):CShape
		{
			return _shapes[index];
		}
		
		public function removeItemAt(index:int):void
		{
			_shapes.removeItemAt(index);
		}
		
		public function removeAll():void
		{
			_shapes.removeAll();
		}
		
		/* This method returns the original reference to the shapes array collection */
		public function toArrayCollection():ArrayCollection
		{
			return _shapes;
		}
		
		public function toArray():Array
		{
			return _shapes.toArray();
		}
		
		public function length():int
		{
			return _shapes.length;
		}
		
		public function print():void
		{
			for(var i:int=0;i<_shapes.length;i++)
			{
				trace(i+" label: "+_shapes[i].label+" bin: "+_shapes[i].binIndex);
			}
		}
	}
}