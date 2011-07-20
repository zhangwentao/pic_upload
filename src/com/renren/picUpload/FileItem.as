package com.renren.picUpload 
{
	import flash.net.FileReference;
	/**
	 * 文件
	 * @author taowenzhang@gmail.com 
	 */
	public class FileItem
	{
		public static var FILE_STATUS_QUEUED:int 		= -1;
		public static var FILE_STATUS_IN_PROGRESS:int	= -2;
		public static var FILE_STATUS_ERROR:int			= -3;
		public static var FILE_STATUS_SUCCESS:int		= -4;
		public static var FILE_STATUS_CANCELLED:int		= -5;
		
		var id:uint;//编号
		var status:int;//状态
		var fileReference:FileReference;//
		
		public function FileItem(id:uint,fileRef:FileReference) 
		{
			this.id = id;
			this.fileReference = fileRef;
		}
	}
}