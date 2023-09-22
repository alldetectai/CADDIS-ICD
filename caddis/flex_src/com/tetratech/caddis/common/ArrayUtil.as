package com.tetratech.caddis.common
{
	public class ArrayUtil
	{
		public function ArrayUtil()
		{
			throw new Error("This class cannot be created");
		}
		
		/* This method finds the max value in an array of numbers */
		public static function findMaxValue(a:Array):Number
      	{
      		if(a.length == 0)
      			return -1;
      			
      		var max:Number = a[0];
      		var maxIndex:int = 0;
      		for(var i:int=1;i<a.length;i++)
      		{
      			if(a[i] > a[maxIndex])
      			{
      				maxIndex = i;
      				max = a[i];
      			}
      		}
      		
      		return max;
      	}
		
		/* This method finds the max value index in an array of numbers */
		public static function findMaxValueIndex(a:Array):int
      	{
      		if(a.length == 0)
      			return -1;
      			
      		var max:Number = a[0];
      		var maxIndex:int = 0;
      		for(var i:int=1;i<a.length;i++)
      		{
      			if(a[i] > a[maxIndex])
      			{
      				maxIndex = i;
      				max = a[i];
      			}
      		}
      		
      		return maxIndex;
      	}
      	
      		/* This method finds the min value in an array of numbers */
		public static function findMinValue(a:Array):Number
      	{
      		if(a.length == 0)
      			return -1;
      			
      		var min:Number = a[0];
      		var minIndex:int = 0;
      		for(var i:int=1;i<a.length;i++)
      		{
      			if(a[i] < a[minIndex])
      			{
      				minIndex = i;
      				min = a[i];
      			}
      		}
      		
      		return min;
      	}
		
		/* This method finds the max value index in an array of numbers*/
		public static function findMinValueIndex(a:Array):int
      	{
         	if(a.length == 0)
      			return -1;
      			
      		var min:Number = a[0];
      		var minIndex:int = 0;
      		for(var i:int=1;i<a.length;i++)
      		{
      			if(a[i] < a[minIndex])
      			{
      				minIndex = i;
      				min = a[i];
      			}
      		}
      		
      		return minIndex;
      	}
      
	}
}