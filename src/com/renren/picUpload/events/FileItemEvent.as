package com.renren.picUpload.events
{
	import com.renren.picUpload.FileItem;
	import flash.events.Event;
	
	public class FileItemEvent extends Event
	{
		public static const FILE_QUEUED:String = "fileQueued";//文件被加入队列
		public static const UPLOAD_SUCCESS:String = "uploadSuccess";//上传成功
		public static const UPLOAD_PROGRESS:String = "uploadProgress";//上传中
		public static const UPLOAD_CANCELED:String = "uploadCanceled";//取消一个文件的上传
		public static const ZERO_BYTE_FILE:String = "zeroByteFile";//文件为长度为0
		public static const FILE_EXCEEDS_SIZE_LIMIT:String = "fileExceedsSizeLimit";//上传的文件超出文件尺寸上限
		public static const START_PROCESS_FILE:String = "startProcessFile";//对图片进行处理
		public static const LOAD_LOCAL_FILE_IO_ERROR:String = "loadLocalFileIoError";//加载本地文件时发生io错误
		public static const INVALIDATE_IMG_TYPE:String = "invalidateImgType";//非法的图片格式。
		
		private var _fileItem:FileItem;
		
		public function FileItemEvent(type:String,fileItem:FileItem,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._fileItem = fileItem;
		}
		
		public function get fileItem():FileItem
		{
			return this._fileItem;
		}
	}
}