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
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * Crank Handle Component is used to provide a unlimited range of movement through a small component.
	 * This component will use the basic handle mentality of cursor attraction and capture then provides a mechanism for rotation to
	 * dispatch move events. These move events will contain the current value of the rotation along with the delta change from the last dispatch in Radians.
	 * <p>
	 * <code>
	 *		var circle:Sprite = new Sprite();
	 *		circle.graphics.beginFill(color);
	 *		circle.graphics.drawCircle(radius, radius, radius);
	 *		var rotator:Sprite = new Sprite();
	 *		rotator.graphics.beginFill(0x000000, .5);
	 *		rotator.graphics.drawCircle(radius*2, radius*2, radius*2);
	 *
	 *		var ch:CrankHandle = new CrankHandle(circle,  rotator);
	 *		this.addChild(ch);
	 *
	 *		ch.addEventListener(UIEvent.MOVE, onCrankMove, false, 0, true);
	 *
	 *		//Capture the Move Event and look at the value or delta properties
	 * 		private function onCrankMove(event:UIEvent):void {
	 *			var ratio:Number = event.value / (Math.PI * 2);
	 *		}
	 *
	 * </code>
	 * </p>
	 */
	public class CrankHandle extends Handle {
		protected var _rotator:DisplayObject;
		protected var _rotatorCaptureArea:Sprite;
		protected var _rotatorCapturePadding:Number;
		protected var _lastGlobalCursorPosition:Point = new Point();
		
		//Rotation in Radians of the current frame
		protected var _currentRadians:Number;
		//Radians from the previous frame
		protected var _previousRadians:Number;
		//Addition of radians increments since capture
		protected var _overallRadians:Number;

		//Sprite container for all visual debugging
		protected var _debug:Sprite;
		//Visual Debugging
		protected var _drawDebug:Boolean;

		//determines is this is the FIRST update of movement in a rotation;
		private var _isFirstUpdate:Boolean;

		/**
		 * Creates a new UI Crank handle
		 * @param icon						Icon for general rendering
		 * @param rotator					Graphic to show once cursor is captured
		 * @param selectedIcon				Icon to use when a cursor is captured into this Handle
		 * @param disabledIcon				Icon to use when handle is disabled
		 * @param rotatorCapturePadding		Padding to use around Rotator Graphic
		 * @param capturePadding			@see Handle._capturePadding
		 * @param minPull					@see Handle.minPull
		 * @param maxPull					@see Handle.maxPull
		 */
		public function CrankHandle(icon:DisplayObject, rotator:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, rotatorCapturePadding:Number = 400, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1){
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_rotator = rotator;
			_rotatorCaptureArea = new Sprite();
			_rotatorCapturePadding = rotatorCapturePadding;
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			createRotatorCaptureArea();
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			_rotatorCaptureArea.graphics.clear();
			if(stage.contains(_debug)) stage.removeChild(_debug);
		}

		override public function showCaptureArea():void {
			super.showCaptureArea();
			createRotatorCaptureArea();
		}

		override public function hideCaptureArea():void {
			super.hideCaptureArea();
			createRotatorCaptureArea()
		}

		private function createRotatorCaptureArea():void {
			_rotatorCaptureArea.graphics.clear();
			_rotatorCaptureArea.graphics.beginFill(0xff0000, _showCaptureArea ? .5 : 0);

			var widthPadding:Number = _rotatorCapturePadding;
			var width:uint = _rotator.width + widthPadding;

			var heightPadding:Number = _rotatorCapturePadding;
			var height:uint = _rotator.height + heightPadding;
			_rotatorCaptureArea.graphics.drawRect(0, 0, width, height);
		}


		override protected function onHandleCapture():void {
			super.onHandleCapture();

			_previousRadians = _currentRadians = _overallRadians = 0;
			
			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;
			_localCursorPosition = this.globalToLocal(_globalCursorPosition);

			_rotatorCaptureArea.x  = _localCursorPosition.x - (_rotatorCaptureArea.width/2);
			_rotatorCaptureArea.y  = _localCursorPosition.y - (_rotatorCaptureArea.height/2);

			if(_drawDebug) stage.addChild(_debug);
			showRotator();

			_cursor.visible = true;
			_isFirstUpdate = true;
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			hideRotator();

			if(_debug && stage.contains(_debug)) stage.removeChild(_debug);
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		private function onUpdate(event:Event):void {
			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;

			if(_isFirstUpdate){
				_isFirstUpdate = false;
				_lastGlobalCursorPosition.x = _globalCursorPosition.x;
				_lastGlobalCursorPosition.y = _globalCursorPosition.y;
			}

			_localCursorPosition = this.globalToLocal(_globalCursorPosition);
			_currentRadians = Math.atan2(_globalCursorPosition.y - _lastGlobalCursorPosition.y, _globalCursorPosition.x - _lastGlobalCursorPosition.x);

			//Shortest rotation distance between the previous and the current.
			var angleDiff:Number = Math.atan2(Math.sin(_currentRadians - _previousRadians), Math.cos(_currentRadians - _previousRadians));
			_overallRadians += angleDiff;
			_previousRadians = _currentRadians;
			if(_drawDebug) {
				if(!stage.contains(_debug)) stage.addChild(_debug);
				onDebugMove();
			}

			this.dispatchEvent(new UIEvent(UIEvent.MOVE,_cursor, _localCursorPosition.x,  _localCursorPosition.y, _globalCursorPosition.x,  _globalCursorPosition.y, _overallRadians, angleDiff ))
		}

		private function showRotator():void {
			this.addChildAt(_rotator,0);
			_rotator.x = -_icon.width/2;
			_rotator.y = -_icon.height/2;
			_rotator.visible = true;

			this.addChildAt(_rotatorCaptureArea,0);
			onRotatorShown();
		}

		private function onRotatorShown():void {
			
		}
		
		private function hideRotator():void {
			_rotator.visible = false;
			if(this.contains(_rotator)) this.removeChild(_rotator);
			if(this.contains(_rotatorCaptureArea)) this.removeChild(_rotatorCaptureArea);
			onRotatorHidden();
		}

		private function onRotatorHidden():void {
			
		}


		//----------------------------------
		// Crank Dial Visual Debugging
		//----------------------------------

		private var _debugDial:Sprite;
		private var _debugArrow:Sprite;
		private var _debugRadius:Number = 50;
		private var _debugAngleConvert:Number = 180 / Math.PI;

		private function onDebugMove():void{
			_debugArrow.x = _debugRadius * Math.cos(_currentRadians);
			_debugArrow.y = _debugRadius * Math.sin(_currentRadians);
			_debugArrow.rotation = _debugAngleConvert * _currentRadians + 90;
		}
		
		private function _makeDebugDial():void {
			var g:Graphics = _debugDial.graphics;
			g.clear();
			g.lineStyle(1, 0x004000);
			g.drawCircle(0, 0, _debugRadius);
			_debugDial.x = _debugDial.y = _debugRadius + 50;
			_debug.addChild(_debugDial);
		}

		private function _makeDebugArrow():void {
			var g:Graphics = _debugArrow.graphics;
			g.clear();
			g.beginFill(0x000080);
			g.moveTo(0, -15);
			g.lineTo(7, 6);
			g.lineTo( -7, 6);
			g.endFill();
			_debugArrow.y = -_debugRadius;
			_debugDial.addChild(_debugArrow);
		}

		/**
		 * Returns current state of drawing the debug
		 */
		public function get drawDebug():Boolean {
			return _drawDebug;
		}

		/**
		 * Controls the drawing of the debug indicator for this handle.
		 * @param value		Boolean to set the status to.
		 */
		public function set drawDebug(value:Boolean):void {
			_drawDebug = value;

			if(_drawDebug){
				if(!_debug) {
					_debug = new Sprite();
					_debugDial = new Sprite();
					_debugArrow = new Sprite();
					_makeDebugDial();
					_makeDebugArrow();
				}
			}else{
				if(_debug && stage.contains(_debug)) stage.removeChild(_debug);
				_debugDial = null;
				_debugArrow = null;
			}
		}
	}
}