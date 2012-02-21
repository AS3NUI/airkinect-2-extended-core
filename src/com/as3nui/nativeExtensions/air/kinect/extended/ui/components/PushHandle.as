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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	public class PushHandle extends Handle {
		private var _originalZ:Number;
		private var _pushChangeThreshold:Number;

		public function PushHandle(icon:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, pushThreshold:Number = .07, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_pushChangeThreshold = pushThreshold;
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();

			_originalZ = _cursor.z;
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		private function onUpdate(event:Event):void {
			var overallDiff:Number = _originalZ - _cursor.z;
			if (overallDiff >= _pushChangeThreshold) onSelected();
		}

		protected function onSelected():void {
			release(_cursor);
			var globalPosition:Point = this.localToGlobal(centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, centerPoint.x, centerPoint.y, globalPosition.x, globalPosition.y));
		}
	}
}