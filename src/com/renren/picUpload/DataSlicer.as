package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	
	/**
	 * 切割数据
	 * @author taowenzhang@gmail.com 
	 */
	public class DataSlicer
	{
		public static var block_size_limit:uint = 10240;//数据切片大小上限Byte 100K
		
		/**
		 * 将data切割成DataBlock 
		 * @param	data	<ByteArray>	被切割的数据
		 * @return	<Array>	DataBlock数组
		 */
		public function slice(data:ByteArray):Array
		{
			var dataArr:Array = new Array();//存放切割后的数据块
			if (data.length <= block_size_limit)//如果小于上限值就直接返回原数据
			{
				dataArr.push(data);
				return dataArr;
			}
				
			data.position = 0;
			while (data.bytesAvailable)
			{
				var byteArr:ByteArray = new ByteArray();
				
				if (data.bytesAvailable < block_size_limit * 3 / 2)
				{
					data.readBytes(byteArr, 0,data.bytesAvailable);
				}
				else
				{
					data.readBytes(byteArr, 0, block_size_limit);
				}
				
				dataArr.push(byteArr);
			}
			return dataArr;
		}
	}
}