package com.renren.picUpload 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class PicStanConsumer extends EventDispatcher
	{
		private var soProxy:SOProxy = new SOProxy();
		private var timer:Timer = new Timer(500);
		public var dataBeenStandaized:ByteArray;
		
		public function PicStanConsumer() 
		{
			init();
		}
		
		private function init():void
		{
			timer.addEventListener(TimerEvent.TIMER, handle_timer);
		}
		
		private function handle_timer(evt:TimerEvent):void
		{
			if (soProxy.productReady)
			{
				dataBeenStandaized = soProxy.getProduct();
				dispatchEvent(new Event(Event.COMPLETE));
				timer.stop();
			}
		}
		
		public function standardize(data:ByteArray):void
		{
			soProxy.addRaw(data);
			timer.start();
		}
		
		
	}

}