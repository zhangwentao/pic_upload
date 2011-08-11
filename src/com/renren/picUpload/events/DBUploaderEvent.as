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
		public static const COMPLETE:String = "complete";//上传完毕
		
		
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