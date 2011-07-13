package com.renren.picUpload 
{
	import flash.utils.ByteArray;
	/**
	 * 文件切割者
	 * @author taowenzhang@gmail.com 
	 */
	public class FileSlicer
	{
		public static var block_size_limit:uint;//文件切片大小上限
		
		public function FileSlicer() 
		{
			
		}
		
		/**
		 * 将文件的data切割成DataBlock 
		 * @param	data	<ByteArray>	被切割的文件数据
		 * @return	<Array>	DataBlock 数组
		 */
		public function slice(data:ByteArray):Array
		{
			
		}

	}

}