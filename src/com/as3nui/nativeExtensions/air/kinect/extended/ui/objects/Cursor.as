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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.objects {
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.IAttractor;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces.ICaptureHost;

	import flash.display.DisplayObject;
	import flash.geom.Point;


	/**
	 * Cursors are used through the UImanager to interact with UI components. Cursor management can be done when required
	 * by calling the update function and changting the x,y,z location of a cursor.
	 * To create a Cursor use the following
	 * <p>
	 * <code>
	 *     //Create a Graphic Element to represent the cursor
	 *     	var circle:Shape = new Shape();
	 *		circle.graphics.lineStyle(2, 0x000000);
	 *		circle.graphics.beginFill(0x00ff00);
	 *		circle.graphics.drawCircle(0, 0, 20);
	 *
	 *		//Create a Cursor to use for the left hand
	 *		//source and ID parameters can be anything, they are only set to "_kinect_" and AIRKinectSkeleton.HAND_LEFT for easy understanding
	 *		//they could just as easily be "mysource" and 1.
	 *  	_leftHandCursor = new Cursor("_kinect_", AIRKinectSkeleton.HAND_LEFT, circle);
	 *
	 *  	//Add the Cursor to the UIManager
	 *  	UIManager.addCursor(_leftHandCursor);
	 * </code>
	 * </p>
	 *
	 * To Update a Cursor using the previous example as a base use the following
	 * <p>
	 * <code>
	 *
	 *     //This will usually run on Enterframe or SkeletonFrameUpdate
	 *     _leftHandCursor.update(newX, newY, newZ);
	 * </code>
	 * </p>
	 */
	public class Cursor {

		/**
		 * State ikn which the cursor is free moving
		 */
		public static const FREE:String = "free";

		/**
		 * State inwhich the cursor ic captured by a component and not visible or moving.
		 */
		public static const CAPTURED:String = "captured";

		protected var _source:String;
		protected var _id:uint;

		protected var _x:Number;
		protected var _y:Number;
		protected var _z:Number;
		protected var _X:Number;
		protected var _Y:Number;
		protected var _Z:Number;

		protected var _xVelocity:Number;
		protected var _yVelocity:Number;

		//reusable point
		protected var _point:Point = new Point();

		protected var _isInteractive:Boolean;
		protected var _icon:DisplayObject;

		protected var _state:String = FREE;
		
		protected var _captureHost:ICaptureHost;
		protected var _attractor:IAttractor;

		protected var _enabled:Boolean;
		protected var _visible:Boolean;

		protected var _easing:Number;

		/**
		 * Cursor is used to interact with UIComponents through the UIManager
		 * @param source		A Source for this cursor (mouse, kinect, etc)
		 * @param id			A unique ID for this cursor
		 * @param icon			Icon to represent the cursor
		 * @param easing		Easing this cursor will use for attraction for handles in the UI
		 */
		public function Cursor(source:String, id:uint, icon:DisplayObject, easing:Number = .3) {
			_source = source;
			_id = id;
			_visible = _enabled = true;

			_icon = icon;
			_isInteractive = true;
			_x = _y = _z = _X = _Y = _Z = 0;

			_xVelocity = _yVelocity = 0;
			_easing = easing;
		}

		//----------------------------------
		// Capture/Release Function
		//----------------------------------

		/**
		 * Captures this cursor causing it to turn invisible and stop being attracted to any UIComponents
		 * @param host		Host that has captured this cursor
		 */
		public function capture(host:ICaptureHost):void {
			_captureHost = host;
			_state = CAPTURED;
			this._icon.visible = false;
			this.stopAttraction();
		}

		/**
		 * Releases the cursor from the captured state, returning control and visibility
		 */
		public function release():void {
			_captureHost = null;
			_state = FREE;
			this._icon.visible = true;
		}

		/**
		 * Starts attracting this cursor towards a IAttractor
		 * @param attractor		IAttractor to move towards
		 */
		public function startAttraction(attractor:IAttractor):void {
			_attractor = attractor;
		}

		/**
		 * Stops attraction by clearing out current attraction params and allowing the cursor to move
		 * freely.
		 */
		public function stopAttraction():void {
			_attractor = null;
		}

		//----------------------------------
		// Source
		//----------------------------------
		public function get source():String {
			return _source;
		}

		public function set source(value:String):void {
			_source = value;
		}

		//----------------------------------
		// ID
		//----------------------------------
		public function get id():uint {
			return _id;
		}

		public function set id(value:uint):void {
			_id = value;
		}

		//----------------------------------
		// Location Getters/Setters
		//----------------------------------
		public function update(x:Number, y:Number, z:Number):void {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public function get x():Number {
			return _x;
		}

		public function get y():Number {
			return _y;
		}

		public function get z():Number {
			return _z;
		}

		public function set x(value:Number):void {
			_X = value - _x;
			_x = value;
		}

		public function set y(value:Number):void {
			_Y = value - _y;
			_y = value;
		}

		public function set z(value:Number):void {
			_Z = value - _z;
			_z = value;
		}

		//----------------------------------
		// Acceleration Getters
		//----------------------------------
		public function get X():Number {
			return _X;
		}

		public function get Y():Number {
			return _Y;
		}

		public function get Z():Number {
			return _Z;
		}

		public function toPoint():Point {
			_point.x = _x;
			_point.y = _y;
			return _point;
		}

		//----------------------------------
		// Interactivity
		//----------------------------------
		public function get isInteractive():Boolean {
			return _isInteractive;
		}

		public function set isInteractive(value:Boolean):void {
			_isInteractive = value;
		}

		//----------------------------------
		// Icon
		//----------------------------------
		public function get icon():DisplayObject {
			return _icon;
		}

		public function set icon(value:DisplayObject):void {
			_icon = value;
		}

		public function get state():String {
			return _state;
		}

		public function get xVelocity():Number {
			return _xVelocity;
		}

		public function set xVelocity(value:Number):void {
			_xVelocity = value;
		}

		public function get yVelocity():Number {
			return _yVelocity;
		}

		public function set yVelocity(value:Number):void {
			_yVelocity = value;
		}

		public function get captureHost():ICaptureHost {
			return _captureHost;
		}

		public function get attractor():IAttractor {
			return _attractor;
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(value:Boolean):void {
			_enabled = value;
			if(_state == FREE && _visible) _icon.visible = _enabled
		}

		public function set visible(value:Boolean):void{
			_visible = value;
			_icon.visible = _visible
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function get easing():Number {
			return _easing;
		}

		public function set easing(value:Number):void {
			_easing = value;
		}
	}
}