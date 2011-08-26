package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class IMGValidater 
	{
		public static function validate(imgData:ByteArray):Boolean
		{
			return (validateBMP(imgData)||validateGIF(imgData)||validateJPG(imgData)||validatePNG(imgData))
		}
		
		private static function validateJPG(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			if (imgData.readUnsignedShort() == 0xFFD8)
			{
				return true;
			}
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