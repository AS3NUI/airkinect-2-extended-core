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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.events {
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.objects.Cursor;

	import flash.events.Event;

	/**
	 * UIEvent is dispatched from a component should be used to listen for needed events
	 * on all components in the libraru
	 */
	public class UIEvent extends Event {
		/**
		 * Over Event dispatched whena cursor moves over a component
		 */
		public static const OVER:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.OVER"; //

		/**
		 * Out Event dispatched when cursor moves out of a component
		 */
		public static const OUT:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.OUT"; //

		/**
		 * Capture event is dispatched when a component captures the cursor
		 */
		public static const CAPTURE:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.CAPTURE"; //

		/**
		 * Release event is dispatched when a component releases the cursor
		 */
		public static const RELEASE:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.RELEASE"; //

		/**
		 * Selected event is dispatched when a component is selected
		 */
		public static const SELECTED:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.SELECTED"; //

		/**
		 * Move event is dispatched when the cursor moves ontop of a component
		 */
		public static const MOVE:String = "com.as3nui.nativeExtensions.air.kinect.extended.ui.components.events.MOVE"; //

		private var _localX:Number = 0;
		private var _localY:Number = 0;
		private var _stageX:Number = 0;
		private var _stageY:Number = 0;
		private var _value:Number = 0;
		private var _delta:Number = 0;
		private var _cursor:Cursor;

		/**
		 * UIEvent will be dispatched from a component
		 * @param type			Type of event
		 * @param cursor		Cursor event was triggered by
		 * @param localX		localX position of cursor inside currentTarget
		 * @param localY		localY position of cursor inside currentTarget
		 * @param stageX		stageX position of cursor
		 * @param stageY		stageY position of cursor
		 * @param value			value is used optionally. Available, for example, on move event of crank slider to tell the current value of the move
		 * @param delta			delta is used optionally. Avaliable, for exmaple, on move event of crank slider to tell the change in rotation.
		 */
		public function UIEvent(type:String, cursor:Cursor, localX:Number, localY:Number, stageX:Number, stageY:Number, value:Number = 0, delta:Number = 0) {
			super(type);

			this._cursor = cursor;
			this._stageX = stageX;
			this._stageY = stageY;

			this._localX = localX;
			this._localY = localY;

			this._value = value;
			this._delta = delta;
		}

		public override function clone():Event {
			return new UIEvent(type, _cursor, _localX, _localY, _stageX, _stageY);
		}

		public function get localX():Number {
			return _localX;
		}

		public function get localY():Number {
			return _localY;
		}

		public function get stageX():Number {
			return _stageX;
		}

		public function get stageY():Number {
			return _stageY;
		}

		public function get cursor():Cursor {
			return _cursor;
		}

		public function get delta():Number {
			return _delta;
		}

		public function get value():Number {
			return _value;
		}
	}
}