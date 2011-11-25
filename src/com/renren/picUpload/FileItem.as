package com.renren.picUpload 
{
	import com.renren.picUpload.events.FileItemEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	/**
	 * 文件
	 * @author taowenzhang@gmail.com 
	 */
	public class FileItem extends EventDispatcher
	{
		public static const FILE_STATUS_QUEUED:int 		= -1;//已加入上传队列
		public static const FILE_STATUS_IN_PROGRESS:int	= -2;//正在上传
		public static const FILE_STATUS_ERROR:int			= -3;//发生错误
		public static const FILE_STATUS_SUCCESS:int		= -4;//上传完毕
		public static const FILE_STATUS_CANCELLED:int		= -5;//已取消
		
		private static var file_id_sequence:Number = 0;		// tracks the file id sequence
		private var _status:int;	//状态
		
		public static var id_prefix:String;
		public var id:String;	//编号
		public var fileReference:FileReference;//文件引用
		public var dataBlockArr:Array = new Array(); //存放对此文件的数据块的引用
		
		/**
		 * 
		 * @param	fileReference	<FileReference> 文件引用
		 */
		public function FileItem(fileReference:FileReference) 
		{
			if (!fileReference)
				return;
			this.id = id_prefix + "_" + file_id_sequence++;
			this.fileReference = fileReference;
		}
		
		/**
		 * 获取文件的属性
		 * @return	
		 */
		public function getInfoObject():Object
		{
			var info:Object = {
				id:this.id,
				name:this.fileReference.name,
				size:this.fileReference.size,
				type:this.fileReference.type
			}
			return info;
		}

		public function get status():int
		{
			return _status;
		}

		public function set status(value:int):void
		{
			_status = value;
			if(_status == FileItem.FILE_STATUS_CANCELLED)
			{
				dispatchEvent(new FileItemEvent(FileItemEvent.UPLOAD_CANCELED,this));
			}
		}
	}
}