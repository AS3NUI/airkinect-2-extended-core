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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * SelectableHandle uses a Selection Timer upon capture to determine selection.
	 * The flow of this component would be as follows.
	 *	<ul>
	 *		<li>Cursor Attraction</li>
	 * 		<li>Cursor Capture</li>
	 * 		<li>SelectionTimer Start</li>
	 * 		<li>SelectionTimer Complete (dispatched event)</li>
	 * 		<li>Cursor Release</li>
	 * 	</ul>
	 */
	public class SelectableHandle extends Handle {

		protected var _selectionTimer:BaseTimerSprite;
		protected var _selectionStartTimer:int;
		protected var _selectionDelay:uint;

		/**
		 * Creates a Selectable Handle UIComponent
		 * @param icon				Icon to use for normal display
		 * @param selectionTimer	Selection Timer to use upon capture
		 * @param selectedIcon		Icon to use during Capture of cursor
		 * @param disabledIcon		Icon to use when handle is disabled
		 * @param selectionDelay	Delay for selection (seconds)
		 * @param capturePadding	@see Handle._capturePadding
		 * @param minPull			@see Handle.minPull
		 * @param maxPull			@see Handle.maxPull
		 */
		public function SelectableHandle(icon:DisplayObject, selectionTimer:BaseTimerSprite, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, selectionDelay:uint = 1, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_selectionDelay = selectionDelay;
			_selectionTimer = selectionTimer;
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();
			this.addChild(_selectionTimer);

			_selectionTimer.x = centerPoint.x;
			_selectionTimer.y = centerPoint.y;


			_selectionTimer.onProgress(0);

			_selectionStartTimer = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		protected function onSelectionTimeUpdate(event:Event):void {
			var progress:Number = (getTimer() - _selectionStartTimer) / (_selectionDelay * 1000);
			_selectionTimer.onProgress(progress);
			if (progress >= 1) onSelected();
		}

		protected function onSelected():void {
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			release(_cursor);

			var globalPosition:Point = this.localToGlobal(centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, centerPoint.x, centerPoint.y, globalPosition.x, globalPosition.y));
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