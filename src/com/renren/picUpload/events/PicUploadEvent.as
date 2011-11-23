package com.renren.picUpload.events
{
	import com.renren.picUpload.FileItem;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class PicUploadEvent extends Event
	{
		public static const UPLOAD_SUCCESS:String = "uploadSuccess";//上传成功
		public static const UPLOAD_PROGRESS:String = "uploadProgress";//上传中
		public static const UPLOAD_CANCELED:String = "uploadCanceled";//取消一个文件的上传
		public static const START_PROCESS_FILE:String = "startProcessFile";//对图片进行处理
	    public static const QUEUE_LIMIT_EXCEEDED:String = "queueLimitExceeded";//上传队列以达到长度已达到上限
		public static const FILE_QUEUED:String = "fileQueued";//文件被加入队列
		public static const ZERO_BYTE_FILE:String = "zeroByteFile";//文件为长度为0
		public static const FILE_EXCEEDS_SIZE_LIMIT:String = "fileExceedsSizeLimit";//上传的文件超出文件尺寸上限
		public static const NOT_LOGIN:String = "notLogin";
		private var _fileItem:FileItem;
		public var data:*;
		
		public function PicUploadEvent(type:String, fileItem:FileItem, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			_fileItem = fileItem;
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new PicUploadEvent(type, _fileItem, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("PicUploadEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
		/**
		 * 相关的FileItem对象
		 */
		public function get fileItem():FileItem 
		{
			return _fileItem;
		}
	
	}

}