package com.renren.picUpload 
{
	import flash.display.BitmapData;
	import flash.net.FileReference;
	/**
	 * 文件
	 * @author taowenzhang@gmail.com 
	 */
	public class File
	{
		var id:uint;//文件编号
		var fileReference:FileReference;//对应的文件引用
		var size:uint;//文件大小
		var thumb:BitmapData;//图片缩略图
		
		public function File() 
		{
			
		}
	}

}