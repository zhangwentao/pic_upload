package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class BMPValidater 
	{
				
		public static function validate(picData:ByteArray):Boolean
		{
			picData.position = 0;
			var sign:String = picData.readUTFBytes(2);
			if (sign == "BM")
			return true;
			else
			return false;
		}
	}

}