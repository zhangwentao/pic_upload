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
		public var index:uint;//数据块编号
		public var data:ByteArray;//数据对象
		
		public function DataBlock(file:File,index:uint,data:ByteArray) 
		{
			
		}
		
		/**
		 * 删除存储的数据释放内存
		 */
		public function dispose():void
		{
			_data.clear();
		}
	}
}