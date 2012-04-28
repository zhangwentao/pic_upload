package org.asclub.ui
{
    import flash.display.*;
    import flash.events.*;
    import flash.ui.*;
    import flash.utils.*;

    public class ContextMenuManager extends Object
    {

        public function ContextMenuManager()
        {
            return;
        }// end function

        public function getMenuItems(param1:InteractiveObject) : Array
        {
            if (param1.contextMenu == null)
            {
                return null;
            }
            return param1.contextMenu.customItems;
        }// end function

        public static function hideBuiltInItems(param1:InteractiveObject, param2:Boolean = true) : void
        {
            if (param1.contextMenu != null)
            {
                if (param2)
                {
                    param1.contextMenu.hideBuiltInItems();
                }
                return;
            }
            var _loc_3:* = new ContextMenu();
            _loc_3.hideBuiltInItems();
            param1.contextMenu = _loc_3;
            return;
        }// end function

        public static function addMenu(param1:InteractiveObject, param2:String, param3:Function = null, param4:Boolean = false, param5:Boolean = true, param6:Boolean = true, ... args) : void
        {
            args = new ContextMenu();
            var _loc_9:* = new ContextMenuItem(param2, param4, param5, param6);
            if (param3 != null)
            {
                _loc_9.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getFun(param3, args));
            }
            if (param1.contextMenu != null)
            {
                param1.contextMenu.customItems.push(_loc_9);
                return;
            }
            if (getQualifiedClassName(param1) != "flash.display::Stage")
            {
                args.customItems.push(_loc_9);
                param1.contextMenu = args;
            }
            return;
        }// end function

        public static function addMenuAt(param1:InteractiveObject, param2:int, param3:String, param4:Function = null, param5:Boolean = false, param6:Boolean = true, param7:Boolean = true, ... args) : Boolean
        {
            args = new ContextMenu();
            var _loc_10:* = new ContextMenuItem(param3, param5, param6, param7);
            if (param4 != null)
            {
                _loc_10.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getFun(param4, args));
            }
            if (param2 > param1.contextMenu.customItems.length || param2 < 0)
            {
                return false;
            }
            if (param1.contextMenu != null)
            {
                param1.contextMenu.customItems.splice(param2, 0, _loc_10);
                return true;
            }
            if (getQualifiedClassName(param1) != "flash.display::Stage")
            {
                args.customItems.push(_loc_10);
                param1.contextMenu = args;
                return true;
            }
            return false;
        }// end function

        public static function addMenus(param1:InteractiveObject) : void
        {
            return;
        }// end function

        public static function editMenu(param1:InteractiveObject, param2:String, param3:String, param4:Function = null, param5:Boolean = false, param6:Boolean = true, param7:Boolean = true, ... args) : Boolean
        {
            var _loc_10:ContextMenu = null;
            var _loc_11:ContextMenuItem = null;
            if (param1.contextMenu == null)
            {
                return false;
            }
            args = getIndexByCaption(param1, param2);
            if (args == -1)
            {
                return false;
            }
            if (removeMenu(param1, param2))
            {
                _loc_10 = new ContextMenu();
                _loc_11 = new ContextMenuItem(param3, param5, param6, param7);
                if (param4 != null)
                {
                    _loc_11.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getFun(param4, args));
                }
                if (param1.contextMenu != null)
                {
                    param1.contextMenu.customItems.splice(args, 0, _loc_11);
                    return true;
                }
                if (getQualifiedClassName(param1) != "flash.display::Stage")
                {
                    _loc_10.customItems.push(_loc_11);
                    param1.contextMenu = _loc_10;
                    return true;
                }
                return false;
            }
            return false;
        }// end function

        public static function removeMenu(param1:InteractiveObject, param2:String) : Boolean
        {
            if (param1.contextMenu == null)
            {
                return false;
            }
            var _loc_3:* = getIndexByCaption(param1, param2);
            if (_loc_3 == -1)
            {
                return false;
            }
            param1.contextMenu.customItems.splice(_loc_3, 1);
            return true;
        }// end function

        public static function removeMenuAt(param1:InteractiveObject, param2:int) : Boolean
        {
            if (param1.contextMenu == null)
            {
                return false;
            }
            if (param2 >= param1.contextMenu.customItems.length || param2 < 0)
            {
                return false;
            }
            param1.contextMenu.customItems.splice(param2, 1);
            return true;
        }// end function

        public static function removeAll(param1:InteractiveObject) : void
        {
            param1.contextMenu = null;
            return;
        }// end function

        public static function getIndexByCaption(param1:InteractiveObject, param2:String) : int
        {
            var _loc_3:int = 0;
            while (_loc_3 < param1.contextMenu.customItems.length)
            {
                
                if (param2 == param1.contextMenu.customItems[_loc_3].caption)
                {
                    return _loc_3;
                }
                _loc_3++;
            }
            return -1;
        }// end function

        private static function getFun(param1:Function, param2:Array) : Function
        {
            var _function:* = param1;
            var alt:* = param2;
            var _fun:* = function (param1) : void
            {
                var _loc_2:* = new Array();
                _function.apply(null, _loc_2.concat(param1, alt));
                return;
            }// end function
            ;
            return _fun;
        }// end function

    }
}
