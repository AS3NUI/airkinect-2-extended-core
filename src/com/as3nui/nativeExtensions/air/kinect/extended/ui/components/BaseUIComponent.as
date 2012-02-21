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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.IUIComponent;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Foundational Class for all AIRKinect Extended UIComponents. In custom components this
	 * class is not required, only UIComponent implementation, but is provided as a starting point for
	 * all components providing simple ADDED_TO_STAGE and REMOVED_FROM_STAGE handlers.
	 */
	public class BaseUIComponent extends Sprite implements IUIComponent {
		public var data:*;
		protected var _enabled:Boolean;

		public function BaseUIComponent() {
			_enabled = true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true);
		}

		private function onAddedToStageHandler(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler, false, 0, true);
			onAddedToStage();
		}

		private function onRemovedFromStageHandler(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true);
			onRemovedFromStage();
		}

		protected function onAddedToStage():void {
		}

		protected function onRemovedFromStage():void {
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(value:Boolean):void {
			_enabled = value;
		}
	}
}