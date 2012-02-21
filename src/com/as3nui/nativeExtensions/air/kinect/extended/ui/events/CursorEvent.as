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

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;

	/**
	 * Cursor Events are used internally for components. A cursor can trigger an OVER, OUT, or MOVE event
	 * on a component.
	 */
	public class CursorEvent extends Event {
		/**
		 * OVER Event when a cursor moves over a component
		 */
		public static const OVER:String		= "com.as3nui.nativeExtensions.air.kinect.extended.ui.events.OVER"; //
		/**
		 * OUT Event when a cursor moves out of a component
		 */
		public static const OUT:String 		= "com.as3nui.nativeExtensions.air.kinect.extended.ui.events.OUT"; //
		/**
		 * Move event when a cursor is moving overtop a component
		 */
		public static const MOVE:String 	= "com.as3nui.nativeExtensions.air.kinect.extended.ui.events.MOVE"; //


		private var _cursor:Cursor;
		private var _localX:Number = 0;
		private var _localY:Number = 0;
		private var _stageX:Number = 0;
		private var _stageY:Number = 0;
		private var _relatedObject:InteractiveObject;

		/**
		 * Cursor event is dispatched whenever a cursor is over, out or moving on a component
		 * @param type				Event Type
		 * @param cursor			Cursor being controlled
		 * @param relatedObject		Object under cursor
		 * @param localX			Local X position of cursor in relatedObject
		 * @param localY			Local Y position of cursor in relatedObject
		 * @param stageX			Stage X position of cursor
		 * @param stageY			Stage Y position of cursor
		 */
		public function CursorEvent(type:String, cursor:Cursor, relatedObject:InteractiveObject, localX:Number, localY:Number, stageX:Number, stageY:Number) {
			super(type);
			this._cursor = cursor;

			this._relatedObject = relatedObject;

			this._stageX = stageX;
			this._stageY = stageY;

			this._localX = localX;
			this._localY = localY;
		}

		public override function clone():Event {
			return new CursorEvent(type, _cursor, _relatedObject, _localX, _localY, _stageX, _stageY);
		}

		public function get cursor():Cursor {
			return this._cursor;
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

		public function get relatedObject():DisplayObject {
			return _relatedObject;
		}
	}
}