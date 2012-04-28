package org.asclub.controls
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    public class SimpleStateButton extends CustomUIComponent implements IDestroyable
    {
        private var state_normal:BitmapData;
        private var state_hover:BitmapData;
        private var state_down:BitmapData;
        private var state_disabled:BitmapData;
        private var has_hover:Boolean = false;
        private var has_down:Boolean = false;
        private var hovering:Boolean = false;
        private var is_selected:Boolean = false;
        private var _enabled:Boolean = false;
        private var instance:Bitmap;
        private var _textLabel:TextField;
        private var _label:String;
        private var _textFormat:Object;
        private var _disabledTextFormat:TextFormat;

        public function SimpleStateButton(param1:BitmapData, param2:BitmapData = null, param3:BitmapData = null, param4:BitmapData = null)
        {
            this._textFormat = new TextFormat("ËÎÌו", 12, 0);
            this.state_normal = param1.clone();
            if (param2)
            {
                this.has_hover = true;
                this.state_hover = param2.clone();
            }
            else
            {
                this.state_hover = param1.clone();
            }
            if (param3)
            {
                this.has_down = true;
                this.state_down = param3.clone();
            }
            else
            {
                this.state_down = param1.clone();
            }
            if (param4)
            {
                this.state_disabled = param4.clone();
            }
            else
            {
                this.state_disabled = param1.clone();
            }
            if (this.state_normal.rect.equals(this.state_hover.rect) && this.state_normal.rect.equals(this.state_down.rect))
            {
                this.init();
            }
            else
            {
                throw new Error("State bitmap data dimensions must be equal");
            }
            return;
        }// end function

        public function set selected(param1:Boolean) : void
        {
            this.is_selected = param1;
            var _loc_2:* = this._textLabel.defaultTextFormat;
            if (this.is_selected)
            {
                this.updateState(this.state_down);
                _loc_2.bold = true;
            }
            else
            {
                if (this.hovering)
                {
                    this.updateState(this.state_hover);
                }
                else
                {
                    this.updateState(this.state_normal);
                }
                _loc_2.bold = false;
            }
            this._textLabel.setTextFormat(_loc_2);
            return;
        }// end function

        public function get selected() : Boolean
        {
            return this.is_selected;
        }// end function

        public function set enabled(param1:Boolean) : void
        {
            var _loc_2:TextFormat = null;
            this._enabled = param1;
            this.mouseEnabled = this._enabled;
            this.tabEnabled = this._enabled;
            if (this._enabled)
            {
                if (this.is_selected)
                {
                    this.updateState(this.state_down);
                }
                else
                {
                    this.updateState(this.state_normal);
                }
                _loc_2 = this._textLabel.defaultTextFormat;
            }
            else
            {
                this.updateState(this.state_disabled);
                _loc_2 = this._disabledTextFormat ? (this._disabledTextFormat) : (this._textLabel.defaultTextFormat);
            }
            this._textLabel.setTextFormat(_loc_2);
            return;
        }// end function

        public function get enabled() : Boolean
        {
            return this._enabled;
        }// end function

        public function get label() : String
        {
            return this._label;
        }// end function

        public function set label(param1:String) : void
        {
            this._label = param1;
            this._textLabel.text = this._label;
            this.resize();
            return;
        }// end function

        override public function setStyle(param1:String, param2:Object) : void
        {
            switch(param1)
            {
                case "textFormat":
                {
                    this._textFormat = param2;
                    this._textLabel.setTextFormat(this._textFormat);
                    this._textLabel.defaultTextFormat = this._textFormat;
                    this.resize();
                    break;
                }
                case "disabledTextFormat":
                {
                    this._disabledTextFormat = param2 as TextFormat;
                    break;
                }
                case "upSkin":
                {
                    this.state_normal = getSkinBitmapData(param2);
                    this.updateSkin();
                    break;
                }
                case "overSkin":
                {
                    this.state_hover = getSkinBitmapData(param2);
                    this.updateSkin();
                    break;
                }
                case "downSkin":
                {
                    this.state_down = getSkinBitmapData(param2);
                    this.updateSkin();
                    break;
                }
                case "disabledSkin":
                {
                    this.state_disabled = getSkinBitmapData(param2);
                    this.updateSkin();
                    break;
                }
                default:
                {
                    break;
                }
            }
            return;
        }// end function

        public function destroy() : void
        {
            removeEventListener(MouseEvent.ROLL_OVER, this.onStateRollOver);
            removeEventListener(MouseEvent.ROLL_OUT, this.onStateRollOut);
            removeEventListener(MouseEvent.MOUSE_DOWN, this.onStateMouseDown);
            removeEventListener(MouseEvent.MOUSE_UP, this.onStateMouseUp);
            this.instance.bitmapData.dispose();
            return;
        }// end function

        private function init() : void
        {
            buttonMode = true;
            useHandCursor = true;
            this.instance = new Bitmap();
            this.instance.bitmapData = this.state_normal;
            this._textLabel = new TextField();
            this._textLabel.autoSize = TextFieldAutoSize.CENTER;
            this._textLabel.selectable = false;
            this._textLabel.mouseEnabled = false;
            addChild(this.instance);
            addChild(this._textLabel);
            if (this.has_hover)
            {
                addEventListener(MouseEvent.ROLL_OVER, this.onStateRollOver);
                addEventListener(MouseEvent.ROLL_OUT, this.onStateRollOut);
            }
            if (this.has_down)
            {
                addEventListener(MouseEvent.MOUSE_DOWN, this.onStateMouseDown);
                addEventListener(MouseEvent.MOUSE_UP, this.onStateMouseUp);
            }
            return;
        }// end function

        private function onStateRollOver(event:MouseEvent) : void
        {
            this.hovering = true;
            if (!this.is_selected && this.enabled)
            {
                this.updateState(this.state_hover);
            }
            return;
        }// end function

        private function onStateRollOut(event:MouseEvent) : void
        {
            this.hovering = false;
            if (!this.is_selected && this.enabled)
            {
                this.updateState(this.state_normal);
            }
            return;
        }// end function

        private function onStateMouseDown(event:MouseEvent) : void
        {
            if (this.enabled)
            {
                this.updateState(this.state_down);
            }
            return;
        }// end function

        private function onStateMouseUp(event:MouseEvent) : void
        {
            if (!this.selected && this.enabled)
            {
                if (this.hovering)
                {
                    this.updateState(this.state_hover);
                }
                else
                {
                    this.updateState(this.state_normal);
                }
            }
            return;
        }// end function

        private function updateSkin() : void
        {
            if (this.is_selected)
            {
                this.updateState(this.state_down);
            }
            else if (this.hovering)
            {
                this.updateState(this.state_hover);
            }
            else
            {
                this.updateState(this.state_normal);
            }
            this.resize();
            return;
        }// end function

        private function resize() : void
        {
            this._textLabel.width = this._textLabel.textWidth + 4;
            this._textLabel.x = (this.instance.width - this._textLabel.width) * 0.5;
            this._textLabel.y = (this.instance.height - this._textLabel.height) * 0.5;
            return;
        }// end function

        private function updateState(param1:BitmapData) : void
        {
            this.instance.bitmapData = param1;
            return;
        }// end function

    }
}
