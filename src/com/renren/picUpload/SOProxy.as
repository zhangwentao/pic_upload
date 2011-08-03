package com.renren.picUpload 
{
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class SOProxy 
	{
		private var localPath:String = "/";
		private var raw_ready_name:String = "rawReady";
		private var product_ready_name:String = "productReady";
		private var raw_data_name:String = "raw";
		private var product_data_name:String = "product";
	
		private var product_ready:Boolean;//产品区可用标志
		
		public function SOProxy() 
		{
			
		}
		
		/**
		 * 
		 */
		public function get rawReady():Boolean
		{
			var so:SharedObject = SharedObject.getLocal(raw_ready_name);
			log("rawReady? " + so.data.data);
			return Boolean(so.data.data);
		}
		
		
		public function get productReady():Boolean
		{
			var so:SharedObject = SharedObject.getLocal(raw_ready_name, localPath);
			return Boolean(so.data.data);
		}
		
		public function addRaw(data:ByteArray):Boolean
		{
			var so:SharedObject = SharedObject.getLocal(raw_data_name, localPath);
			so.data.data = data;
			var suc:String = so.flush();
			if (suc == SharedObjectFlushStatus.FLUSHED)
			{
				setRawReady(true);
				return true;
			}
			else
			{
				setRawReady(false);
				return false;
			}
		}
		
		public function addProduct(data:ByteArray):Boolean
		{
			var so:SharedObject = SharedObject.getLocal(product_data_name, localPath);
			so.data.data = data;
			var suc:String = so.flush();
			if (suc == SharedObjectFlushStatus.FLUSHED)
			{
				setProductReady(true);
				return true;
			}
			else
			{
				setProductReady(false);
				return false;
			}
		}
		
		public function getRaw():ByteArray
		{
			var so:SharedObject = SharedObject.getLocal(raw_data_name, localPath);
		    setRawReady(false);
			return ByteArray(so.data.data);
		}
		
		public function getProduct():ByteArray
		{
			var so:SharedObject = SharedObject.getLocal(product_data_name, localPath);
			setProductReady(false);
			return ByteArray(so.data.data);
		}
		
		private function setRawReady(value:Boolean):void
		{
			var so:SharedObject = SharedObject.getLocal(raw_ready_name, localPath);
			so.data.data = value;
			so.flush();
		}
		
		private function setProductReady(value:Boolean):void
		{
			var so:SharedObject = SharedObject.getLocal(product_data_name, localPath);
			so.data.data = value;
			so.flush();
		}
	}
}