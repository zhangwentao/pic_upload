package org.asclub.controls
{
    import flash.display.*;
    import flash.system.*;
    import flash.utils.*;

    public class CustomUIComponent extends Sprite
    {

        public function CustomUIComponent()
        {
            return;
        }// end function

        protected function getDisplayObjectInstance(param1:Object) : DisplayObject
        {
            var classDef:Object;
            var skin:*;
            var value:* = param1;
            skin = value;
            if (skin is Class)
            {
                return new skin as DisplayObject;
            }
            if (skin is DisplayObject)
            {
                (skin as DisplayObject).x = 0;
                (skin as DisplayObject).y = 0;
                return skin as DisplayObject;
            }
            try
            {
                classDef = getDefinitionByName(skin.toString());
            }
            catch (e:Error)
            {
                try
                {
                    classDef = ApplicationDomain.currentDomain.getDefinition(skin.toString()) as Object;
                }
                catch (e:Error)
                {
                }
                if (classDef == null)
                {
                    return null;
                }
                return new classDef as DisplayObject;
        }// end function

        protected function getSkinBitmapData(param1:Object) : BitmapData
        {
            if (param1 is BitmapData)
            {
                return param1 as BitmapData;
            }
            var _loc_2:* = this.getDisplayObjectInstance(param1);
            var _loc_3:* = new BitmapData(_loc_2.width, _loc_2.height);
            _loc_3.draw(_loc_2);
            return _loc_3;
        }// end function

        public function setStyle(param1:String, param2:Object) : void
        {
            return;
        }// end function

    }
}
