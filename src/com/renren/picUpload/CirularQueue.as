package com.renren.picUpload 
{
	/**
	 * 循环队列
	 * @author wentao.zhang
	 */
	public class CirularQueue
	{
		var max_size:int;
		var front:int;
		var rear:int;
		var base:Array;
		
		public function CirularQueue(maxSize:int) 
		{
			max_size = maxSize;
			front = 0;
			rear = 0;
			base = new Array(max_size);
		}
		
		public function get head():*
		{
			return base[front];
		}
		
		public function get length():int
		{
			return (max_size + rear - front) % max_size;
		}

		public function clear():void
		{
			front = rear = 0;
		}
		
		public function enQueue(item:*):void
		{
			base[rear] = item;
			rear = (rear + 1) % max_size;
		}
		
		public function deQueue():*
		{
			var resut = base[front];
			front = (front +1) % max_size;
			return resut;
		}
	
		public function isEmpty():Boolean
		{
			return Boolean(rear == front);
		}
		
		public function isFull():Boolean
		{
			return Boolean( length == max_size);
		}
	}
}