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
	 * RepeatingSelectableHandle component allows for multiple selections of the same handle. This is done with an optional repeat timer.
	 * The flow of this component would be as follows.
	 *	<ul>
	 *		<li>Cursor Attraction</li>
	 * 		<li>Cursor Capture</li>
	 * 		<li>SelectionTimer Start</li>
	 * 		<li>SelectionTimer Complete (dispatched event)</li>
	 * 		<li>(optional) Repeat Timer start</li>
	 * 		<li>(optional) Repeat Timer complete</li>
	 * 		<li>SelectionTimer Start</li> (repeats)
	 * 	</ul>
	 *
	 * 	If RepeatTimer is left null the selection timer will simply start again after completed
	 */
	public class RepeatingSelectableHandle extends Handle {

		protected var _selectionTimer:BaseTimerSprite;
		protected var _selectionStartTimer:int;
		protected var _selectionDelay:uint;

		//Repeat Delay timer
		protected var _repeatTimer:BaseTimerSprite;
		protected var _repeatDelay:uint;
		protected var _repeatStartTime:Number;

		/**
		 * Allows for Repeating Selections from the same handle delayed by selecetion time and an optional repeat timer.
		 * @param icon				Normal Icon for displaying this handle
		 * @param selectionTimer	Selection Timer used after capture
		 * @param repeatTimer		Repeat Timer used after selection
		 * @param selectedIcon		Icon to use during capture of cursor
		 * @param disabledIcon		Icon to use when handle is disabled
		 * @param selectionDelay	Delay for selection timer (seconds)
		 * @param repeatDelay		Delay for repeat timer (seconds)
		 * @param capturePadding	@see Handle._capturePadding
		 * @param minPull			@see Handle.minPull
		 * @param maxPull			@see Handle.maxPull
		 */
		public function RepeatingSelectableHandle(icon:DisplayObject, selectionTimer:BaseTimerSprite, repeatTimer:BaseTimerSprite = null, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, selectionDelay:uint = 1, repeatDelay:uint = 1, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_selectionDelay = selectionDelay;
			_selectionTimer = selectionTimer;

			_repeatTimer = repeatTimer;
			_repeatDelay = repeatDelay;
			_repeatStartTime = NaN;
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();
			addSelectionTimer();
			startSelectionTimer();
		}

		private function addSelectionTimer():void {
			this.addChild(_selectionTimer);
			_selectionTimer.x = centerPoint.x;
			_selectionTimer.y = centerPoint.y;
		}

		private function startSelectionTimer():void {
			_selectionTimer.onProgress(0);
			_selectionStartTimer = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			if (this.contains(_repeatTimer)) this.removeChild(_repeatTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);

			_repeatStartTime = NaN;
		}

		protected function onSelectionTimeUpdate(event:Event):void {
			var progress:Number;

			if (!(isNaN(_repeatStartTime))) {
				progress = (getTimer() - _repeatStartTime) / (_repeatDelay * 1000);
				if (_repeatTimer) _repeatTimer.onProgress(progress);
				if (progress >= 1) {
					if (this.contains(_repeatTimer)) this.removeChild(_repeatTimer);
					if (!this.contains(_selectionTimer)) addSelectionTimer();

					_repeatStartTime = NaN;
					_selectionStartTimer = getTimer();
				}
			} else {
				progress = (getTimer() - _selectionStartTimer) / (_selectionDelay * 1000);
				_selectionTimer.onProgress(progress);
				if (progress >= 1) onSelected();
			}
		}

		protected function onSelected():void {
			if (_repeatDelay > 0) {
				_repeatStartTime = getTimer();
				if (_repeatTimer && _repeatDelay > 0) {
					if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);

					//Repeat Timer
					this.addChild(_repeatTimer);
//					_repeatTimer.x = centerPoint.x - (_repeatTimer.width / 2);
//					_repeatTimer.y = centerPoint.y - (_repeatTimer.height / 2);

					_repeatTimer.x = centerPoint.x;
					_repeatTimer.y = centerPoint.y;
				}
			}

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

		/**
		 * Returns the current delay for repeating timer (seconds)
		 */
		public function get repeatDelay():uint {
			return _repeatDelay;
		}

		/**
		 * Sets the current repeat timer delay (seconds)
		 * @param value		Delay in seconds
		 */
		public function set repeatDelay(value:uint):void {
			_repeatDelay = value;
		}
	}
}