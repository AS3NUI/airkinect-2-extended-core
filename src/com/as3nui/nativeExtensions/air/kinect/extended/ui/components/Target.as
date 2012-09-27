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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.display.BaseTimerSprite;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.CursorEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.managers.UIManager;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * A Target does not attract a cursor but does use the Selection Timer Mechanism. This component dispatches
	 * OVER, OUT, and SELECTED. Upon Rollover a Target will not capture a cursor but will turn it invisible then the target
	 * will position the Selection Timer at the location of the cursor. This gives the illusion that the cursor has changed into
	 * the selection timer but still allows movement.
	 * The flow of this component would be as follows.
	 * <p>
	 *	<ul>
	 *		<li>Cursor Over</li>
	 *		<li>Cursor Turned invisible</li>
	 *		<li>Selection Timer placed at location of cursor</li>
	 *		<li>Selection Timer Started</li>
	 *		<li>(optional, if moved) Cursor movement mapped to selection timer movement</li>
	 * 		<li>Selection Time Complete (dispatches selected event)</li>
	 * 		<li>Selection Timer removed</li>
	 * 		<li>Cursor turned visible</li>
	 * 	</ul>
	 * </p>
	 */
	public class Target extends HotSpot {
		protected var _globalCursorPosition:Point = new Point();
		protected var _localCursorPosition:Point = new Point();
		protected var _cursor:Cursor;

		protected var _selectionTimer:BaseTimerSprite;
		protected var _selectionStartTimer:int;
		protected var _selectionDelay:uint;

		/**
		 * Creates a new Target UIComponent
		 * @param icon				Icon to use for normal display
		 * @param selectionTimer	SelectionTimer to use upon RollOver
		 * @param disabledIcon		Icon to use when disabled
		 * @param selectionDelay	Delay for Selection Timer (seconds)
		 */
		public function Target(icon:DisplayObject, selectionTimer:BaseTimerSprite, disabledIcon:DisplayObject=null, selectionDelay:uint = 1){
			super(icon, disabledIcon);
			_selectionTimer = selectionTimer;
			_selectionDelay = selectionDelay;
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onCursorOver(event:CursorEvent):void {
			super.onCursorOver(event);
			_cursor = event.cursor;
			_cursor.visible = false;
			startSelectionTimer();
		}

		override protected function onCursorOut(event:CursorEvent):void {
			if(_cursor)
			{
				super.onCursorOut(event);
				_cursor.visible = true;
				_cursor = null;
	
				if (UIManager.cursorContainer.contains(_selectionTimer)) UIManager.cursorContainer.removeChild(_selectionTimer);
				this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			}
		}

		protected function startSelectionTimer():void {
			UIManager.cursorContainer.addChild(_selectionTimer);
			_selectionTimer.onProgress(0);

			_selectionStartTimer = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			onSelectionTimeUpdate(null);
		}

		protected function onSelectionTimeUpdate(event:Event):void {
			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;
			_localCursorPosition = UIManager.cursorContainer.globalToLocal(_globalCursorPosition);

			_selectionTimer.x = _localCursorPosition.x;
			_selectionTimer.y = _localCursorPosition.y;

			var progress:Number = (getTimer() - _selectionStartTimer) / (_selectionDelay * 1000);
			_selectionTimer.onProgress(progress);
			if (progress >= 1) onSelected();
		}

		protected function onSelected():void {
			if (UIManager.cursorContainer.contains(_selectionTimer)) UIManager.cursorContainer.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			_cursor.visible = true;

			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;
			_localCursorPosition = this.globalToLocal(_globalCursorPosition);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, _localCursorPosition.x, _localCursorPosition.y, _globalCursorPosition.x, _globalCursorPosition.y));
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
		}

		//----------------------------------
		// Selection Delay
		//----------------------------------
		/**
		 * Returns the current delay for selection (seconds)
		 */
		public function get selectionDelay():uint {
			return _selectionDelay;
		}

		/**
		 * Sets the current Delay for selection
		 * @param value			Delay in seconds
		 */
		public function set selectionDelay(value:uint):void {
			_selectionDelay = value;
		}
	}
}