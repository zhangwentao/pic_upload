package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import com.renren.picUpload.MainProcess;
	import flash.events.MouseEvent;
	import com.renren.picUpload.FileItem;
	/**
	 * ...
	 * @author taowenzhang@gmail.com 
	 */
	public class Main extends Sprite
	{
		private var mainP:MainProcess = new MainProcess();
		private var fileList:FileReferenceList = new FileReferenceList();
		
		public function Main() 
		{
			stage.addEventListener(MouseEvent.CLICK,handle_stage_clicked);
			fileList.addEventListener(Event.SELECT, handle_file_selected);
		}
		
		function handle_stage_clicked(evt:MouseEvent):void 
		{
			fileList.browse();
		}
		
		private function handle_file_selected(evt:Event):void
		{
			var i:uint = 0;
			for each(var file:FileReference in evt.target.fileList)
			{
				var fileItem:FileItem = new FileItem(i,file);
				mainP.addFileItem(fileItem);
				i++;
			}
			
			mainP.launch();
			
		}
		
	}

}