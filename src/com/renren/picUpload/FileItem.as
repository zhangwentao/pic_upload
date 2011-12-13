package com.renren.picUpload 
{
	import com.renren.picUpload.events.FileItemEvent;
	
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	/**
	 * 文件
	 * @author taowenzhang@gmail.com 
	 */
	public class FileItem extends EventDispatcher
	{
		public static const FILE_STATUS_QUEUED:int 			= 1;//已加入上传队列
		public static const FILE_STATUS_IN_PROGRESS:int		= 2;//正在上传
		public static const FILE_STATUS_SUCCESS:int			= 3;//上传完毕
		public static const FILE_STATUS_CANCELLED:int			= 4;//已取
		public static const FILE_STATUS_START_PROCESS;int 	= 5;//文件开始被处理
		
		public static const FILE_STATUS_ERROR_ZERO_BYTE:int			= 11;//文件0字节
		public static const FILE_STATUS_ERROR_EXCEEDS_SIZE_LIMIT:int	= 12;
		public static const FILE_STATUS_ERROR_FAIL_TO_LOAD_LOCAL:int	= 13;
		public static const FILE_STATUS_ERROR_INVALIDATE_IMG_TYPE:int = 14;
		
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
			switch(_status)
			{
				case FileItem.FILE_STATUS_QUEUED:
					dispatchEvent(new FileItemEvent(FileItemEvent.FILE_QUEUED,this));
					break;
				case FileItem.FILE_STATUS_IN_PROGRESS:
					dispatchEvent(new FileItemEvent(FileItemEvent.UPLOAD_PROGRESS,this));
					break;
				case FileItem.FILE_STATUS_CANCELLED:
					dispatchEvent(new FileItemEvent(FileItemEvent.UPLOAD_CANCELED,this));
					break;
				case FileItem.FILE_STATUS_START_PROCESS:
					dispatchEvent(new FileItemEvent(FileItemEvent.START_PROCESS_FILE,this));
					break;
				case FileItem.FILE_STATUS_SUCCESS:
					dispatchEvent(new FileItemEvent(FileItemEvent.UPLOAD_SUCCESS,this));
					break;
				case FileItem.FILE_STATUS_ERROR_ZERO_BYTE:
					dispatchEvent(new FileItemEvent(FileItemEvent.ZERO_BYTE_FILE,this));
					break;
				case FileItem.FILE_STATUS_ERROR_EXCEEDS_SIZE_LIMIT:
					dispatchEvent(new FileItemEvent(FileItemEvent.FILE_EXCEEDS_SIZE_LIMIT,this));
					break;
				case FileItem.FILE_STATUS_ERROR_FAIL_TO_LOAD_LOCAL:
					dispatchEvent(new FileItemEvent(FileItemEvent.LOAD_LOCAL_FILE_IO_ERROR,this));
					break;
				case FileItem.FILE_STATUS_ERROR_INVALIDATE_IMG_TYPE:
					dispatchEvent(new FileItemEvent(FileItemEvent.INVALIDATE_IMG_TYPE,this));
					break;
				
			}
			
		}
	}
}