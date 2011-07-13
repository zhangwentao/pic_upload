package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	/**
	 * 数据块
	 * @author taowenzhang@gmail.com
	 */
	public class DataBlock
	{
		public var file:File;//所属文件的引用
		public var index:int;//编号
		public var data:ByteArray;//数据对象
		
		public function DataBlock() 
		{
			
		}
		
		/**
		 * 删除存储的数据释放内存
		 */
		public function clear():void
		{
			_data.clear();
		}
	}
}