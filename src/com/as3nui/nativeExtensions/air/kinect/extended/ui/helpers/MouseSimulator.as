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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.helpers {
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.managers.UIManager;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.objects.Cursor;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	/**
	 * MouseSimulator Class provides simple access to use the mouse as a Cursor in the UIManager.
	 * To use the this helper simple add the folloowing line to your code
	 * <p>
	 * <code>
	 * 		MouseSimulator.init(stage);
	 * </code>
	 * </p>
	 */
	public class MouseSimulator {
		protected static var _stage:Stage;
		protected static var _source:String = "mouse_adapter";
		protected static var _hasBeenAdded:Boolean;
		protected static var _mouseCursor:Cursor;
		protected static var _enabled:Boolean;
		
		private static var PUSH:String = "push";
		private static var PULL:String = "pull";
		
		protected static var _currentSimulationType:String;
		protected static var _pulseSprite:Sprite;

		private static var _pushThreshold:Number = 2.5;
		private static var _pushIncriment:Number = .01;

		private static var _mouseIdleZ:int = 3;
		protected static var _currentZ:Number;

		/**
		 * Initializes the Mouse Simulator by creating a cursor for your mouse and attempting to add it to the UIManager.
		 * If the UIManager is not initialized yet the simulator will continue to attempt registration on MouseMove
		 * @param stage		stage reference
		 */
		public static function init(stage:Stage, icon:DisplayObject = null):void {
			trace("Simulator Initialized");
			_stage = stage;
			_hasBeenAdded = false;
			if(!icon) icon = new MouseGraphic();
			_mouseCursor = new Cursor("_mouse_", 1, icon);
			_pulseSprite = new Sprite();
			enable();
		}

		/**
		 * Removes the mouse cursor from the UIManager and removes the MouseSimulator From memory
		 */
		public static function uninit():void {
			disable();
			removeMouseCursor();
			_mouseCursor = null;
			_stage = null;
			_pulseSprite = null;
		}

		/**
		 * Enables the Mouse Cursor by hiding the actual mouse and adding the cursor to the UIManager
		 */
		public static function enable():void {
			if(_enabled) return;

			_enabled = true;
			_currentZ = _mouseIdleZ;
			Mouse.hide();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_stage.addEventListener(MouseEvent.CLICK, handleMouseClick);
			if(UIManager.isInitialized) addMouseCursor();
		}

		/**
		 * Disables the Mouse Cursor by unregistering it form the UIManager, turns on the real mouse cursor.
		 */
		public static function disable():void {
			if(!_enabled) return;
			_enabled = false;
			if(simulatingMove) stopSimulation();

			Mouse.show();
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_stage.removeEventListener(MouseEvent.CLICK, handleMouseClick);
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulseUpdate);
			if(UIManager.isInitialized) removeMouseCursor();
		}

		private static function handleMouseMove(event:MouseEvent):void {
			_mouseCursor.x = event.stageX / _stage.stageWidth;
			_mouseCursor.y = event.stageY / _stage.stageHeight;
			_mouseCursor.z = _currentZ;

			if(UIManager.isInitialized && !_hasBeenAdded) addMouseCursor();
		}

		private static function handleMouseClick(event:MouseEvent):void {
			_currentSimulationType = event.shiftKey ? PULL : PUSH;
			startSimulation();
		}

		private static function startSimulation():void {
			if(simulatingMove) return;
			_currentZ = _mouseIdleZ;
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onPulseUpdate);
		}

		private static function stopSimulation():void {
			_currentZ = _mouseIdleZ;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulseUpdate);
		}

		private static function onPulseUpdate(event:Event):void {
			if(_currentSimulationType == PUSH){
				_currentZ -= _pushIncriment;
				if(_currentZ <= _pushThreshold) _currentSimulationType = PULL
			}else{
				_currentZ += _pushIncriment;
				if(_currentZ >= _mouseIdleZ) stopSimulation();
			}

			_mouseCursor.z = _currentZ;
		}

		private static function get simulatingMove():Boolean {
			return _pulseSprite.hasEventListener(Event.ENTER_FRAME);
		}

		private static function addMouseCursor():void {
			if(UIManager.isInitialized) {
				_mouseCursor.x = _stage.mouseX / _stage.stageWidth;
				_mouseCursor.y = _stage.mouseY / _stage.stageHeight;
				
				_mouseCursor.icon.x = _stage.mouseX;
				_mouseCursor.icon.y = _stage.mouseY;
				
				UIManager.addCursor(_mouseCursor);
				_hasBeenAdded = true;
			}
		}

		private static function removeMouseCursor():void {
			if(UIManager.isInitialized) UIManager.removeCursor(_mouseCursor);
			_hasBeenAdded = false;
		}

		/**
		 * Returns Initialized status of the MouseSimulator
		 */
		public static function get isInitialized():Boolean {
			return !(_stage == null);
		}

		/**
		 * Returns enabled status of the Mouse Simulator
		 */
		public static function get enabled():Boolean {
			return _enabled;
		}
	}
}

import flash.display.Sprite;

class MouseGraphic extends Sprite {
	public function MouseGraphic():void {
		this.mouseEnabled  	= false;
		this.mouseChildren 	= false;
		this.buttonMode 	= false;
		this.useHandCursor	= false;
		draw();
	}

	private function draw():void {
		this.graphics.lineStyle(2,0x000000);
		this.graphics.beginFill(0x00ff00, 1);
		this.graphics.drawCircle(0,0,10);
	}
}