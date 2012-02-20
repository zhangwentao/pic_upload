package com.renren.picUpload
{
	public class GIFValidater
	{
		public static function validateGIF(imgData:ByteArray):Boolean
		{
			imgData.position = 0;
			var sign:String = imgData.readUTFBytes(3);
			if (sign == "GIF")
				return true;
			else
				return false;
		}
	}
}