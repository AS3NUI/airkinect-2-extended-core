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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.managers {
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.IAttractor;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.ICaptureHost;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.IUIComponent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.CursorEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/**
	 * UIManager is a singleton responsible for handling all event dispatching to UIComponents from Cursors.
	 * All components implementing IUIComponent will automatically be available for events, if more control is required
	 * or a custom movieclip or sprite needs these events simply register the component with the registerComponent function
	 * to receive CursorEvent "OVER", "OUT" and "MOVE".
	 *
	 * Before use the UIManager must be initialized as follows
	 * <p>
	 * <code>
	 * 		UIManager.init(stage);
	 * </code>
	 * </p>
	 */
	public class UIManager {
		public static var PARENT_SEARCH_ENABLED:Boolean		= true;

		protected static var _instance:UIManager;

		public static function get instance():UIManager {
			if(!_instance) throw new Error("UIManager must be initialized to be used at Singleton");
			return _instance;
		}

		/**
		 * Returns Initialization status of UIManager
		 */
		public static function get isInitialized():Boolean {
			return _instance is UIManager;
		}

		/**
		 * Initializes the UIManager for use
		 * @param stage			stage reference
		 */
		public static function init(stage:Stage):void {
			if(_instance) return;
			_instance = new UIManager(stage);
		}

		/**
		 * Removes the UIManager from memory.
		 */
		public static function dispose():void {
			if(!_instance) return;
			instance.dispose();
			_instance = null;
		}

		/**
		 * Adds a Cursor to the UIManager to be tracked into UIComponents
		 * @param cursor		Cursor to add
		 */
		public static function addCursor(cursor:Cursor):void {
			instance.addCursor(cursor)
		}

		/**
		 * Removes a Cursor form the UIManager
		 * @param cursor		Cursor to remove
		 */
		public static function removeCursor(cursor:Cursor):void {
			instance.removeCursor(cursor)
		}

		/**
		 * Allows for manual registration of any InteractiveObject to receieve CursorEvents
		 * @param interactiveObject		InteractiveObject to register into UIManager
		 */
		public static function registerComponent(interactiveObject:InteractiveObject):void {
			instance.registerComponent(interactiveObject);
		}

		/**
		 * Manually removes a interactive object, that was added with registerComponent, from the UIManager
		 * @param interactiveObject
		 */
		public static function unregisterComponent(interactiveObject:InteractiveObject):void {
			instance.unregisterComponent(interactiveObject);
		}

		/**
		 * Returns the current Custom Object Filter
		 */
		public static function get customObjectFilter():Function {
			return instance.customObjectFilter;
		}

		/**
		 * Sets a Custom Object Filter. This function will be called to determine which object is under a point on the stage
		 * for event dispatching. the function will receive 1 parameter of type Point and will be the current position of the cursor
		 * on the stage. This function is expected to return an InteractiveObject that is under that point.
		 * @param value
		 */
		public static function set customObjectFilter(value:Function):void {
			instance.customObjectFilter = value;
		}

		/**
		 * Sprite used to hold cursors visually on the stage.
		 */
		public static function get cursorContainer():Sprite {
			return instance.cursorContainer;
		}

		//----------------------------------
		// Instance
		//----------------------------------
		protected var _components:Vector.<InteractiveObject>;
		protected var _cursors:Vector.<Cursor>;
		protected var _cursorContainer:Sprite;

		protected var _stage:Stage;
		protected var _pulseSprite:Sprite;

		//Reusable Vector 3D Point;
		protected var _inputPoint:Vector3D = new Vector3D();
		protected var _customObjectFilter:Function;
		protected var _targetLookup:Dictionary;

		/**
		 * UIManager provides communication between UIcomponents in the display list and Cursors
		 * @param stage		stage reference
		 */
		public function UIManager(stage:Stage) {
			_stage = stage;

			_cursorContainer = new Sprite();
			_cursorContainer.mouseChildren = _cursorContainer.mouseEnabled = false;
			stage.addChild(_cursorContainer);
			stage.addEventListener(Event.ADDED, onStageChildAdded);
			stage.addEventListener(Event.ENTER_FRAME, onPulse);

			this._cursors = new <Cursor>[];
			this._components = new <InteractiveObject>[];
			this._targetLookup = new Dictionary();
		}

		/**
		 * Removes the UIManager from memory.
		 */
		public function dispose():void {
			if(_stage.contains(_cursorContainer)) _stage.removeChild(_cursorContainer);
			_stage.removeEventListener(Event.ADDED, onStageChildAdded);
			_stage.removeEventListener(Event.ENTER_FRAME, onPulse);

			if(_cursors) {
				var cursors:Vector.<Cursor> = _cursors.concat();
				for each(var cursor:Cursor in cursors){
					removeCursor(cursor);
				}
			}

			this._cursors = null;
			this._components = null;
			this._targetLookup = null;
		}

		/**
		 * Called whenevr a child is added to the stage. Forces the Cursors to the top
		 * @param event
		 */
		private function onStageChildAdded(event:Event):void {
			updateCursorContainer();
		}

		/**
		 * Moves the cursor container to the top of thge displaylist
		 */
		private function updateCursorContainer():void {
			if(_stage.contains(_cursorContainer)) _stage.setChildIndex(_cursorContainer, _stage.numChildren-1);
		}

		/**
		 * Adds a cursor into the UIManager for trakcing into UIComponents
		 * @param cursor		Cursor to add
		 */
		public function addCursor(cursor:Cursor):void {
			if(!this._cursors) return;
			if(this._cursors.indexOf(cursor) >= 0) return;
			this._cursors.push(cursor);
			_cursorContainer.addChild(cursor.icon);
		}

		/**
		 * Removes a Cursor from the UIManager
		 * @param cursor		Cursor to remove
		 */
		public function removeCursor(cursor:Cursor):void {
			if(!this._cursors) return;
			var cursorIndex:Number = this._cursors.indexOf(cursor);
			if(cursorIndex == -1) return;
			this._cursors.splice(cursorIndex, 1);

			if(!_targetLookup[cursor.source]) _targetLookup[cursor.source] = new Dictionary();
			//Cursor Removed dispatch out for any objects it is over
			if(_targetLookup[cursor.source][cursor.id] is InteractiveObject) {
				//Convert InputPoint coords into stage coords
				_inputPoint.x = cursor.x * _stage.stageWidth;
				_inputPoint.y = cursor.y * _stage.stageHeight;

				// Interactive Object under the current Input Point
				var cursorPoint:Point = cursor.toPoint();
				cursorPoint.x *= _stage.stageWidth;
				cursorPoint.y *= _stage.stageHeight;
				
				var targetObject:InteractiveObject = _targetLookup[cursor.source][cursor.id] as InteractiveObject;
				var localPoint:Point = targetObject.globalToLocal(cursorPoint);

				//Dispatch OUT
				(_targetLookup[cursor.source][cursor.id] as InteractiveObject).dispatchEvent(new CursorEvent(CursorEvent.OUT, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));
				_targetLookup[cursor.source][cursor.id]  = _stage;
			}

			if(_cursorContainer.contains(cursor.icon)) {
				_cursorContainer.removeChild(cursor.icon);
			}
		}

		/**
		 * Pulse is called on Enterframe. This is used to move all cursors and manage all event dispatching
		 * @param event
		 */
		public function onPulse(event:Event):void {
			var cursorPoint:Point;
			var targetObject:InteractiveObject;
			var localPoint:Point;
			for each(var cursor:Cursor in this._cursors){

				if(!cursor.enabled) {
					if(!_targetLookup[cursor.source]) _targetLookup[cursor.source] = new Dictionary();
					if(_targetLookup[cursor.source][cursor.id] is InteractiveObject) {
						// Interactive Object under the current Input Point
						cursorPoint = cursor.toPoint();
						cursorPoint.x *= _stage.stageWidth;
						cursorPoint.y *= _stage.stageHeight;

						targetObject = _targetLookup[cursor.source][cursor.id] as InteractiveObject;
						localPoint = targetObject.globalToLocal(cursorPoint);

						//Stop Attraction
						if(targetObject is IAttractor) cursor.stopAttraction();
						//Release Cursor
						if(targetObject is ICaptureHost && (targetObject as ICaptureHost).hasCursor) (targetObject as ICaptureHost).release(cursor);

						//Dispatch OUT
						(_targetLookup[cursor.source][cursor.id] as InteractiveObject).dispatchEvent(new CursorEvent(CursorEvent.OUT, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));
						_targetLookup[cursor.source][cursor.id]  = _stage;
					}
					continue;
				}

				//Convert InputPoint coords into stage coords
				_inputPoint.x = cursor.x * _stage.stageWidth;
				_inputPoint.y = cursor.y * _stage.stageHeight;

				if(cursor.state != Cursor.CAPTURED){
					var xDiff:Number = _inputPoint.x - cursor.icon.x;
					var yDiff:Number = _inputPoint.y - cursor.icon.y;
					cursor.xVelocity = (xDiff * cursor.easing);
					cursor.yVelocity = (yDiff * cursor.easing);

					if(cursor.attractor != null){
						xDiff = cursor.attractor.globalCenter.x - cursor.icon.x;
						yDiff = cursor.attractor.globalCenter.y - cursor.icon.y;

						var xRatio:Number = Math.abs(xDiff / (cursor.attractor.captureWidth/2));
						var yRatio:Number = Math.abs(yDiff / (cursor.attractor.captureHeight/2));
						if(xRatio > 1) xRatio = 1;
						if(yRatio > 1) yRatio = 1;
						xRatio = Math.abs(1 - xRatio);
						yRatio = Math.abs(1 - yRatio);

						cursor.xVelocity = xDiff * (cursor.attractor.minPull + (xRatio * (cursor.attractor.maxPull - cursor.attractor.minPull)));
						cursor.yVelocity = yDiff * (cursor.attractor.minPull + (yRatio * (cursor.attractor.maxPull - cursor.attractor.minPull)));

						if(Math.abs(cursor.xVelocity) <= .1 && Math.abs(cursor.yVelocity) <= .1){
							cursor.xVelocity = 0;
							cursor.yVelocity = 0;

							cursor.icon.x = cursor.attractor.globalCenter.x;
							cursor.icon.y = cursor.attractor.globalCenter.y;
							cursor.attractor.captureHost.capture(cursor);
						}
					}
				}

				cursor.icon.x += cursor.xVelocity;
				cursor.icon.y += cursor.yVelocity;

				// Interactive Object under the current Input Point
				cursorPoint = cursor.toPoint();
				cursorPoint.x *= _stage.stageWidth;
				cursorPoint.y *= _stage.stageHeight;
				targetObject = getInteractiveObjectUnderPoint(cursorPoint);
				localPoint = targetObject.globalToLocal(cursorPoint);

				if(!_targetLookup[cursor.source]) _targetLookup[cursor.source] = new Dictionary();

				if(!_targetLookup[cursor.source][cursor.id]) {
					_targetLookup[cursor.source][cursor.id] = targetObject;

					if(targetObject is IAttractor && cursor.attractor == null && cursor.captureHost == null) {
						if(!(targetObject is ICaptureHost && (targetObject as ICaptureHost).hasCursor)) cursor.startAttraction(targetObject as IAttractor);
					}
					//Dispatch OVER
					targetObject.dispatchEvent(new CursorEvent(CursorEvent.OVER, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));
				}

				var originalTarget:InteractiveObject = _targetLookup[cursor.source][cursor.id] as InteractiveObject;
				if(originalTarget != targetObject){
					if(originalTarget is IAttractor) cursor.stopAttraction();
					if(originalTarget is ICaptureHost && (originalTarget as ICaptureHost).hasCursor) (originalTarget as ICaptureHost).release(cursor);
					
					//Dispatch OUT
					(originalTarget as InteractiveObject).dispatchEvent(new CursorEvent(CursorEvent.OUT, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));

					//Dispatch OVER
					_targetLookup[cursor.source][cursor.id] = targetObject;
					targetObject.dispatchEvent(new CursorEvent(CursorEvent.OVER, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));
					if(targetObject is IAttractor && cursor.attractor == null && cursor.captureHost == null) {
						if(!(targetObject is ICaptureHost && (targetObject as ICaptureHost).hasCursor)) cursor.startAttraction(targetObject as IAttractor);
					}
				}

				//Dispatch MOVE
				targetObject.dispatchEvent(new CursorEvent(CursorEvent.MOVE, cursor,  targetObject, localPoint.x,  localPoint.y,  _inputPoint.x,  _inputPoint.y));
			}
		}

		/**
		 * Registers any InteractiveObject into the UIManager to receive CursorEvents
		 * @param interactiveObject		InteractiveObject to register
		 */
		public function registerComponent(interactiveObject:InteractiveObject):void {
			if(_components.indexOf(interactiveObject) >= 0) return;
			this._components.push(interactiveObject);
		}

		/**
		 * Removes an InteractiveObject, that was previously added with registerComponent, from the UIManager
		 * @param interactiveObject
		 */
		public function unregisterComponent(interactiveObject:InteractiveObject):void {
			if(_components.indexOf(interactiveObject) == -1) return;
			var componentIndex:Number = this._components.indexOf(interactiveObject);
			this._components.splice(componentIndex, 1);
		}

		//----------------------------------
		// Utility Functions
		//----------------------------------

		/**
		 * Determines which object is under the cursor for event dispatching.
		 * To override this see @customObjectFilter
		 *
		 * @param point		Stage position of the cursor
		 * @return			InteractiveObject under point
		 */
		protected function getInteractiveObjectUnderPoint(point:Point):InteractiveObject {
			//Allows users to supply custom filters
			if(_customObjectFilter != null) return _customObjectFilter.apply(this, [point]);

			var targets:Array =  _stage.getObjectsUnderPoint(point);
			
			var item:DisplayObject;

			while(targets.length > 0) {
				item = targets.pop() as DisplayObject;

				//If this component is disabled skip it.
				if(item is IUIComponent && (!(item as IUIComponent).enabled)) continue;
				
				if ((item is InteractiveObject && (item as InteractiveObject).mouseEnabled && (item is Stage || _components.indexOf(item) >=0 || (item is IUIComponent)))) {
					return item as InteractiveObject;
				}else if(PARENT_SEARCH_ENABLED){
					var currentObject:DisplayObject = item.parent;

					while(currentObject && !(currentObject is Stage)){
						if((currentObject is InteractiveObject && (currentObject as InteractiveObject).mouseEnabled && (_components.indexOf(currentObject) >=0 || (currentObject is IUIComponent)))) {
							if(!(currentObject is IUIComponent) || ((currentObject is IUIComponent) && (currentObject as IUIComponent).enabled)) {
								return currentObject as InteractiveObject;
							}
						}
						currentObject = currentObject.parent;
					}
				}
			}
			return _stage;
		}

		/**
		 * Returns the current Custom Object Filter
		 */
		public function get customObjectFilter():Function {
			return _customObjectFilter;
		}

		/**
		 * Sets a Custom Object Filter. This function will be called to determine which object is under a point on the stage
		 * for event dispatching. the function will receive 1 parameter of type Point and will be the current position of the cursor
		 * on the stage. This function is expected to return an InteractiveObject that is under that point.
		 * @param value
		 */
		public function set customObjectFilter(value:Function):void {
			_customObjectFilter = value;
		}

		/**
		 * Returns the current sprite containing all the cursors in the display list.
		 */
		public function get cursorContainer():Sprite {
			return _cursorContainer;
		}
	}
}