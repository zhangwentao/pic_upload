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
		public static var FILE_STATUS_QUEUED:int 		= -1;
		public static var FILE_STATUS_IN_PROGRESS:int	= -2;
		public static var FILE_STATUS_ERROR:int			= -3;
		public static var FILE_STATUS_SUCCESS:int		= -4;
		public static var FILE_STATUS_CANCELLED:int		= -5;
		public static var FILE_STATUS_NEW:int 			= -6;
		
		var id:uint;//文件编号
		var status:int;//文件状态
		var fileReference:FileReference;//对应的文件引用
		var thumb:BitmapData;//图片缩略图
		
		
		public function File() 
		{
			
		}
		
	}

}