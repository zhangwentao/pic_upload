package  
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author taowenzhang@gmail.com
	 */
	public class ScrollBar extends Sprite
	{
		private var _target:Sprite;
		private var masker:Shape;//遮罩
		private var _pageSize:Number;
		private var _width:Number;
		private var thumb:Sprite;
		private var max:Number;
		
		public function ScrollBar(pageSize:Number,width:Number)
		{
			this._width = width;
			this._pageSize = pageSize;
			this.thumb = new thumbSkin();
		}
		
		private function initMasker():void
		{
			masker = new Shape();
			masker.graphics.beginFill(0x000000);
			masker.graphics.drawRect(0, 0, this._width, _pageSize);
			masker.graphics.endFill();
			_target.mask = masker;
			masker.x = _target.x;
			masker.y = _target.y;
			_target.parent.addChild(masker);
		}
		
		public function set target(target:Sprite):void
		{
			this._target = target;
			adjustThumb();
			initMasker();
			addChild(thumb);
			initThumbEvent();
		}
		
		private function adjustThumb():void
		{
			if (_target.height < this._pageSize)
			{
				thumb.height = _pageSize;
			}
			else
			{
				thumb.height = _pageSize * _pageSize / _target.height;
			}
			max = _target.height - _pageSize;
		}
		
		private function initThumbEvent():void
		{
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, handle_thumb_mouseDown);
		}
		
		public function update():void
		{
			adjustThumb();
		}
		
		private function handle_thumb_mouseDown(evt:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, handle_stage_mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handle_stage_mouseMove);
			thumb.startDrag(false, new Rectangle(0, 0, 0, _pageSize-thumb.height));
			
		}
		
		private function handle_stage_mouseUp(evt:MouseEvent):void
		{
			thumb.stopDrag();
		}
		
		private function handle_stage_mouseMove(evt:MouseEvent):void
		{
			
		}
	}

}