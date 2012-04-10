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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.IAttractor;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.ICaptureHost;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.CursorEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;

	/**
	 * Handle is core for all components that require snapping and capturing. Currently this class should not be instantiated on its own
	 * but instead use @see RepeatingSelectableHandle @see SelectableHandle or @see SlideHandle
	 */
	public class Handle extends BaseUIComponent implements IAttractor, ICaptureHost {

		//Selection Timer Info
		protected var _idleIcon:DisplayObject;
		protected var _icon:DisplayObject;
		protected var _centerPoint:Point = new Point();
		protected var _cursor:Cursor;
		
		protected var _selectedIcon:DisplayObject;

		protected var _disabledIcon:DisplayObject;

		protected var _maxPull:Number;
		protected var _minPull:Number;

		protected var _capturePadding:Number;
		protected var _captureArea:Shape;
		protected var _showCaptureArea:Boolean;


		protected var _globalCursorPosition:Point = new Point();
		protected var _localCursorPosition:Point = new Point();

		/**
		 * HAndle Component should now be instantiated but provides the core functionality for all Capturing and Snapping components.
		 * @param icon				Normal Icon used for this handle
		 * @param selectedIcon		Icon used when handle Captures the cursor
		 * @param disabledIcon		Icon used when this handle is disabled
		 * @param capturePadding	Padding to add around Icon for attraction
		 * @param minPull			Attraction pull on the cursor when it is at the maximum distance from the center
		 * @param maxPull			Maximum attraction pull for this handle as the cursor moves towards snapping
		 */
		public function Handle(icon:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1){
			_idleIcon = _icon = icon;
			_selectedIcon = selectedIcon;
			_disabledIcon = disabledIcon;
			super();

			_captureArea = new Shape();
			_capturePadding = capturePadding;
			_minPull = minPull;
			_maxPull = maxPull;
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			this.addChild(_captureArea);
			this.addChild(_icon);
			this.addEventListener(CursorEvent.OVER, onCursorOver);
			this.addEventListener(CursorEvent.OUT, onCursorOut);
			
			createCaptureArea();
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			_cursor = null;
			if(this.contains(_captureArea)) this.removeChild(_captureArea);
			if(this.contains(_icon)) this.removeChild(_icon);
			this.removeEventListener(CursorEvent.OVER, onCursorOver);
			this.removeEventListener(CursorEvent.OUT, onCursorOut);

			_captureArea.graphics.clear();
		}

		protected function createCaptureArea():void {
			_captureArea.graphics.clear();
			_captureArea.graphics.beginFill(0xff0000, _showCaptureArea ? .5 : 0);

			var width:uint = _icon.width + (_capturePadding * _icon.width);
			var height:uint = _icon.height + (_capturePadding * _icon.height);
			_captureArea.graphics.drawRect(-(_capturePadding * _icon.width)/2, -(_capturePadding * _icon.height)/2, width, height);
		}

		/**
		 * Used for debugging. This will show the capture area for this handle
		 */
		public function showCaptureArea():void {
			_showCaptureArea = true;
			createCaptureArea();
		}

		/**
		 * Turns off the visiblity of the capture area for this handle
		 */
		public function hideCaptureArea():void {
			_showCaptureArea = false;
			createCaptureArea();
		}

		protected function onCursorOver(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OVER, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
		}

		protected function onCursorOut(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OUT, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			_cursor = null;
		}

		/**
		 * Causes this handle to capture a Cursor.
		 * @param cursor		cursor to capture
		 */
		public function capture(cursor:Cursor):void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.CAPTURE, cursor, 0, 0, globalPosition.x, globalPosition.y));
			cursor.capture(this);
			_cursor = cursor;

			onIconCapture();
			onHandleCapture();
		}

		/**
		 * Causes this handle to release a cursor.
		 * @param cursor		cursor to release
		 */
		public function release(cursor:Cursor):void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.RELEASE, cursor, 0,0, globalPosition.x,  globalPosition.y));
			_cursor.release();
			_cursor = null;
			onIconRelease();
			onHandleRelease();
		}

		protected function onIconCapture():void {
			if(_selectedIcon){
				_selectedIcon.x = _icon.x;
				_selectedIcon.y = _icon.y;
				this.removeChild(_icon);
				_icon = _selectedIcon;
				this.addChild(_icon);
			}else if (_icon is MovieClip){
				if((_icon as MovieClip).currentLabels.indexOf("_capture") != -1) (_icon as MovieClip).gotoAndStop("_capture");
			}
		}

		protected function onIconRelease():void {
			if(_selectedIcon){
				_idleIcon.x = _icon.x;
				_idleIcon.y = _icon.y;
				this.removeChild(_icon);
				_icon = _idleIcon;
				this.addChild(_icon);
			}else if (_icon is MovieClip){
				if((_icon as MovieClip).currentLabels.indexOf("_idle") != -1) (_icon as MovieClip).gotoAndStop("_idle");
			}
		}

		protected function onHandleCapture():void {

		}

		protected function onHandleRelease():void {

		}

		/**
		 * If a Handle is disabled icon will switch to disabledIcon (if provided) and cursors will not be able to interact
		 * with this handle
		 * @param value		Boolean determining enabled status
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
				if(_cursor) release(_cursor);
				if(this.contains(_icon)) this.removeChild(_icon);
				_icon = _disabledIcon;
				this.addChild(_icon);
			}
		}

		//----------------------------------
		// IAttractor
		//----------------------------------
		public function get captureHost():ICaptureHost {
			return this;
		}

		/**
		 * Returns the center point of this handle in global space
		 */
		public function get globalCenter():Point {
			return this.localToGlobal(centerPoint);
		}

		/**
		 * Returns the center point used for attraction and snapping for this handle.
		 */
		public function get centerPoint():Point {
			_centerPoint.x = _icon.width/2;
			_centerPoint.y = _icon.height/2;
			return _centerPoint;
		}

		/**
		 * Returns the width of the current capture area
		 */
		public function get captureWidth():Number {
			return _captureArea.width;
		}

		/**
		 * Returns the height of the current captyre Area
		 */
		public function get captureHeight():Number {
			return  _captureArea.height;
		}

		/**
		 * Current Minimum pull of this handle
		 */
		public function get minPull():Number {
			return _minPull;
		}

		/**
		 * Current Maximum pull of this handle
		 */
		public function get maxPull():Number {
			return _maxPull;
		}

		/**
		 * Sets the Maximum pull for this handle. Used for attraction of cursor
		 * @param value		Min attractive for to be applied every frame
		 */
		public function set maxPull(value:Number):void {
			_maxPull = value;
		}

		/**
		 * Sets the Minimum pull for this handle. Used for attraction of cursor.
		 * @param value		Max attractive force to be applied every frame.
		 */
		public function set minPull(value:Number):void {
			_minPull = value;
		}

		//----------------------------------
		// ICaptureHost
		//----------------------------------
		/**
		 * Status of the handle currently capturing a cursor
		 */
		public function get hasCursor():Boolean {
			return _cursor != null;
		}

		public function get icon():DisplayObject {
			return _icon;
		}

		public function get selectedIcon():DisplayObject {
			return _selectedIcon;
		}

		public function get disabledIcon():DisplayObject {
			return _disabledIcon;
		}
	}
}