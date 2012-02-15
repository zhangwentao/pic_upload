package com.renren.picUpload
{
	import com.renren.picUpload.StatisticsData;
	import com.adobe.serialization.json.JSON;
	public class StatisticsCollector
	{
		private var dic:Object;
		
		public function StatisticsCollector()
		{
			dic={};
		}
		
		public function add(key:String,value:StatisticsData):void
		{
			log("add:"+key);
			dic[key] = value;
		}
		
		public function del(key:String):void
		{
			delete dic[key];
		}
		
		public function getJSONformate():String
		{
			var statistics:Array = new Array();
			for each(var sta in dic)
			{
				statistics.push(sta);
			}
			return JSON.encode(statistics);
		}
		
	}
}