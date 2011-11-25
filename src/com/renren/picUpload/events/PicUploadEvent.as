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
		
	    public static const QUEUE_LIMIT_EXCEEDED:String = "queueLimitExceeded";//上传队列以达到长度已达到上限
		
		
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