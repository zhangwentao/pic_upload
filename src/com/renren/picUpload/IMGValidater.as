package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class IMGValidater 
	{
		public static const IMG_TYPE_JPG:String = "jpg";
		public static const IMG_TYPE_BMP:String = "bmp";
		public static const IMG_TYPE_PNG:String = "png";
		public static const IMG_TYPE_GIF:String = "gif";
		public static const INVALIDATE_IMG_TYPE:String = "invalidate";
		public static function validate(imgData:ByteArray):String
		{
			var imgType:String;
			
			if(validateJPG(imgData))
				imgType = IMG_TYPE_JPG;
			else if(validateBMP(imgData))
				imgType = IMG_TYPE_BMP;
			else if(validateGIF(imgData))
				imgType = IMG_TYPE_GIF;
			else if(validatePNG(imgData))
				imgType = IMG_TYPE_PNG;
			
			return imgType;
		}
		
		private static function validateJPG(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			if (imgData.readUnsignedShort() == 0xFFD8)
				return true;
			else
				return false;
		}
		
		private static function validateBMP(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			var sign:String = imgData.readUTFBytes(2);
			if (sign == "BM")
				return true;
			else
				return false;
		}
		
		private static function validateGIF(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			var sign:String = imgData.readUTFBytes(3);
			if (sign == "GIF")
				return true;
			else
				return false;
		}
		
		private static function validatePNG(imgData:ByteArray):Boolean
		{
			imgData.position = 1;
			var sign:String = imgData.readUTFBytes(3);
			if (sign == "PNG")
				return true;
			else
				return false;
		}
	}
}