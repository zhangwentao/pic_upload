package com.renren.picUpload.events 
{
	import com.renren.picUpload.DataBlock;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class DBUploaderEvent extends Event 
	{
		public static const UPLOAD_BLOCK_COMPLETE:String = "complete";				//一个数据块上传完毕
		public static const UPLOAD_FILE_COMPLETE:String = "fileComplete";			//整个文件完成
		public static const UPLOAD_CANCELED:String = "uploadCanceled";				//上传操作已取消
		
		public var dataBlock:DataBlock;
	
		public function DBUploaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new DBUploaderEvent(type, bubbles, cancelable);  
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DBUploaderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}