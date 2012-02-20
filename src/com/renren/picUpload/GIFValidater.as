package com.renren.picUpload
{
	import flash.utils.ByteArray;
	public class GIFValidater
	{
		public static function validateGIF(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			var sign:String = imgData.readUTFBytes(3);
			if (sign == "GIF")
			{
				log("is gif");
				return true;
			}
			else
				return false;
		}
	}
}