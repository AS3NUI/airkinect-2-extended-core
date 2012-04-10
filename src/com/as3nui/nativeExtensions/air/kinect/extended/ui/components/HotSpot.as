/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.as3nui.nativeExtensions.air.kinect.extended.ui.components {
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.CursorEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;

	/**
	 * HotSpot component dispatches OVER and OUT events and will never be selected. If provides for simple roll over selections
	 * and roll out deselection.
	 * <p>
	 * <code>
	 *		var s:Sprite = new Sprite();
	 *		s.graphics.beginFill(Math.random()*0xffffff);
	 *		s.graphics.drawRect(0,0,200,200);
	 *
	 *		var hotSpot:HotSpot = new HotSpot(s);
	 *		hotSpot.addEventListener(UIEvent.OVER, onHotSpotOver, false, 0, true);
	 *		this.addChild(hotSpot);
	 * </code>
	 * </p>
	 */
	public class HotSpot extends BaseUIComponent {
		protected var _icon:DisplayObject;
		protected var _idleIcon:DisplayObject;
		protected var _disabledIcon:DisplayObject;

		/**
		 * Crates a new HotSpot UIComponent
		 * @param icon				Normal Icon for display
		 * @param disabledIcon		Disabled Icon
		 */
		public function HotSpot(icon:DisplayObject,disabledIcon:DisplayObject=null){
			super();
			_icon = _idleIcon = icon;
			_disabledIcon = disabledIcon;
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			this.addChild(_icon);
			this.addEventListener(CursorEvent.OVER, onCursorOver);
			this.addEventListener(CursorEvent.OUT, onCursorOut);
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			if(this.contains(_icon)) this.removeChild(_icon);
			this.removeEventListener(CursorEvent.OVER, onCursorOver);
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
			this.removeEventListener(CursorEvent.OUT, onCursorOut);
		}

		protected function onCursorMove(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
		}

		protected function onCursorOver(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OVER, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			this.addEventListener(CursorEvent.MOVE, onCursorMove);
		}

		protected function onCursorOut(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OUT, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
		}

		/**
		 * When disabled a target will not interact with cursors or dispatch events
		 * @param value		Boolean ot enabled status
		 */
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if(_enabled){
				if(_idleIcon != _icon){
					if(this.contains(_icon)) this.removeChild(_icon);
					_icon = _idleIcon;
					this.addChild(_icon);
				}
			}else if(_disabledIcon){
				if(this.contains(_icon)) this.removeChild(_icon);
				_icon = _disabledIcon;
				this.addChild(_icon);
			}
		}

		public function get icon():DisplayObject {
			return _icon;
		}

		public function get idleIcon():DisplayObject {
			return _idleIcon;
		}

		public function get disabledIcon():DisplayObject {
			return _disabledIcon;
		}
	}
}