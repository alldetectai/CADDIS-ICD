package com.tetratech.caddis.common
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	
	public class GraphicsUtil
	{
		public function GraphicsUtil()
		{
		}
		
		/* This method scales (zoom in and out) a display object */
		public static function scale(obj:DisplayObject, scale:Number, originX:Number, originY:Number):void
		{
			// get the transformation matrix of the object
            var affineTransform : Matrix = obj.transform.matrix;
            // move the object to (0/0) relative to the origin
            affineTransform.translate(-originX,-originY); 	  
            // scale
            affineTransform.scale(scale, scale);
            // move the object back to its original position
            affineTransform.translate(originX,originY);
            // apply the new transformation to the object
            obj.transform.matrix = affineTransform;	
		}
 	
 		//this method rotates an object
 		public static function rotate(obj:DisplayObject, angleInRadians:Number, originX:Number, originY:Number):void
 		{
 			// get the transformation matrix of the object
            var affineTransform : Matrix = obj.transform.matrix;
            //important: RESET TO IDENTITY because the object is moving
            affineTransform.identity();
            // move the object to (0/0) relative to the origin
            affineTransform.translate(-originX,-originY); 	  
            // rotate
            affineTransform.rotate(angleInRadians);
            // move the object back to its original position
            affineTransform.translate(originX,originY);
            // apply the new transformation to the object
            obj.transform.matrix = affineTransform;	
 		}
 	
 		//this method set thes transformation to identify
 		public static function resetTransformation(obj:DisplayObject)
 		{
 			obj.transform.matrix.identity();
 		}
 	
 		public static function toDegrees(radians:Number):Number
 		{
 			return radians * 180 / Math.PI;
 		}
 	
 		public static function toRadians(degrees:Number):Number
 		{
 			return degrees * Math.PI / 180;
 		}
 	
 	}
}