package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	
	/**
	 * 数据块
	 * @author taowenzhang@gmail.com
	 */
	public class DataBlock
	{
		public var file:FileItem;//所属文件的引用
		public var index:uint;//数据块编号
		public var count:uint;//所属文件被分成的总块数
		public var data:ByteArray;//数据对象
		
		public function DataBlock(file:FileItem,index:uint,count:uint,data:ByteArray) 
		{
			this.file = file;
			this.index = index;
			this.count = count;
			this.data = data;
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