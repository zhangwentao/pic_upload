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
		
		private var _fileItem:FileItem;
		
		public function PicUploadEvent(type:String, fileItem:FileItem, bubbles:Boolean = false, cancelable:Boolean = false)
		{
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