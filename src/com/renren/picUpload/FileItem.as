package com.renren.picUpload 
{
	import flash.net.FileReference;
	/**
	 * 文件
	 * @author taowenzhang@gmail.com 
	 */
	public class FileItem
	{
		public static var FILE_STATUS_QUEUED:int 		= -1;//已加入上传队列
		public static var FILE_STATUS_IN_PROGRESS:int	= -2;//正在上传
		public static var FILE_STATUS_ERROR:int			= -3;//发生错误
		public static var FILE_STATUS_SUCCESS:int		= -4;//上传完毕
		public static var FILE_STATUS_CANCELLED:int		= -5;//已取消
		public static var FILE_STATUS_LOADING:int 		= -6;//正在从硬盘加载
		
		public var id:uint;//编号
		public var status:int;//状态
		public var fileReference:FileReference;//
		
		
		public function FileItem(id:uint,fileRef:FileReference) 
		{
			this.id = id;
			this.fileReference = fileRef;
		}
	}
}