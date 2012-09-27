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
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.CursorEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Point;

	/**
	 * SlideHandle component provides a mechanism for "Swipe" love movement with incremental updates. The slide handle
	 * can be places in four possible directions (up, down, left, right).
	 * The flow of this component would be as follows.
	 * <p>
	 *	<ul>
	 *		<li>Cursor Attraction</li>
	 * 		<li>Cursor Capture</li>
	 * 		<li>Track Appears</li>
	 * 		<li>Handle Icon attaches to cursor</li>
	 * 		<li>Move events dispatched (value is progress from 0-1)</li>
	 * 		<li>Handle reaches end of track (dispatched sleected event)</li>
	 * 		<li>Cursor is Released</li>
	 * 		<li>Track is Hidden</li>
	 * 	</ul>
	 * </p>
	 *
	 * <p>
	 *     <code>
	 *       	var circle:Shape = new Shape();
	 *			circle.graphics.beginFill(_color);
	 *			circle.graphics.drawCircle(_radius,_radius,_radius);
	 *
	 *			var track:Shape = new Shape();
	 *			track.graphics.beginFill(0x0000ff, .5);
	 *			track.graphics.drawRect(0,0, 300, _radius*2);
	 *
	 *			var sh:SlideHandle = new SlideHandle (circle, track, null, null, SlideHandle.RIGHT);
	 *
	 *			sh.addEventListener(UIEvent.SELECTED, onSlideSelected, false, 0, true);
	 *
	 *			//event.value will be the progress of this current slide from 0 (begining) to 1 (end)
	 *			sh.addEventListener(UIEvent.MOVE, onMove, false, 0, true);
	 *		</code>
	 * </p>
	 */
	public class SlideHandle extends Handle {
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";

		protected var _track:DisplayObject;
		protected var _orientation:String;

		protected var _slideStartPosition:Point;
		protected var _currentCursorPosition:Point = new Point();

		protected var _trackEndPadding:int = 5;

		protected var _trackCaptureArea:Shape;
		protected var _trackCapturePadding:Number = .25;

		/**
		 * Creates a New SlideHandle UIComponent
		 * @param icon				Icon to use used for the handle
		 * @param track				Graphics to be used as the track
		 * @param selectedIcon		Icon to be used when Handle has captured the cursor
		 * @param disabledIcon		Icon to be used when handle is disabled
		 * @param orientation		Current Orientation of this Handle @default LEFT
		 * @param capturePadding	@see Handle._capturePadding
		 * @param minPull			@see Handle.minPull
		 * @param maxPull			@see Handle.maxPull
		 */
		public function SlideHandle(icon:DisplayObject, track:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, orientation:String = LEFT, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_track = track;
			_orientation = orientation;

			_trackCaptureArea = new Shape();
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			createTrackCaptureArea();
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			_trackCaptureArea.graphics.clear();
		}

		override public function showCaptureArea():void {
			super.showCaptureArea();
			createTrackCaptureArea();
		}
		
		override public function hideCaptureArea():void {
			super.hideCaptureArea();
			createTrackCaptureArea()
		}

		private function createTrackCaptureArea():void {
			_trackCaptureArea.graphics.clear();
			_trackCaptureArea.graphics.beginFill(0xff0000, _showCaptureArea ? .5 : 0);

			var widthPadding:Number = (_trackCapturePadding * _track.width);
			var width:uint = _track.width + widthPadding;

			var heightPadding:Number = (_trackCapturePadding * _track.height);
			var height:uint = _track.height + heightPadding;

			switch (_orientation) {
				case RIGHT:
					_trackCaptureArea.graphics.drawRect(0, -heightPadding * .5, width, height);
					break;
				case LEFT:
					_trackCaptureArea.graphics.drawRect(_icon.width, -heightPadding * .5, -width, height);
					break;
				case UP:
					_trackCaptureArea.graphics.drawRect(widthPadding * -.5, _icon.height, width, -height);
					break;
				case DOWN:
					_trackCaptureArea.graphics.drawRect(widthPadding * -.5, 0, width, height);
					break;
			}
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();
			this.addEventListener(CursorEvent.MOVE, onCursorMove);
			showTrack();
		}

		override protected function onHandleRelease():void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, _cursor, 0,0, globalPosition.x,  globalPosition.y,0));

			super.onHandleRelease();
			releaseIcon();
			hideTrack();
		}

		private function releaseIcon():void {
			_icon.x = 0;
			_icon.y = 0;
		}

		protected function onCursorMove(event:CursorEvent):void {
			if(!_cursor) return;

			if (!_slideStartPosition) _slideStartPosition = new Point(event.localX, event.localY);
			_currentCursorPosition.x = event.localX;
			_currentCursorPosition.y = event.localY;
			var progress:Number = 0;
			var trackEnd:Number;

			if (_orientation == RIGHT) {
				_icon.x = _currentCursorPosition.x - _slideStartPosition.x;
				if (_icon.x < 0) _icon.x = 0;
				trackEnd = _track.width - _icon.width - _trackEndPadding;
				progress = Math.abs(_icon.x / trackEnd);
				if (_icon.x >= trackEnd) onSelected()
			} else if (_orientation == LEFT) {
				_icon.x = _currentCursorPosition.x - _slideStartPosition.x;
				if (_icon.x > 0) _icon.x = 0;
				trackEnd = -_track.width + _track.x + _trackEndPadding;
				progress = Math.abs(_icon.x / trackEnd);
				if (_icon.x <= trackEnd) onSelected()
			} else if (_orientation == UP) {
				_icon.y = _currentCursorPosition.y - _slideStartPosition.y;
				if (_icon.y > 0) _icon.y = 0;

				trackEnd = -_track.height + _track.y + _trackEndPadding;
				progress = Math.abs(_icon.y / trackEnd);
				if (_icon.y <= trackEnd) onSelected()
			} else if (_orientation == DOWN) {
				_icon.y = _currentCursorPosition.y - _slideStartPosition.y;
				if (_icon.y < 0) _icon.y = 0;
				trackEnd = _track.height - _icon.height - _trackEndPadding;
				progress = Math.abs(_icon.y / trackEnd);
				if (_icon.y >= trackEnd) onSelected()
			}

			if(!_cursor) return;
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, event.cursor, event.localX, event.localY, event.stageX, event.stageY, progress));
		}

		protected function onSelected():void {
			release(_cursor);
			var globalPosition:Point = this.localToGlobal(_currentCursorPosition);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, _currentCursorPosition.x, _currentCursorPosition.y, globalPosition.x, globalPosition.y));
		}

		protected function showTrack():void {
			this.addChildAt(_track, 0);
			if(_orientation == LEFT) _track.x = _icon.width;
			if(_orientation == UP) _track.y = _icon.height;


			this.addChildAt(_trackCaptureArea, 0);
			_track.visible = true;
			onTrackShown();
		}

		protected function onTrackShown():void {

		}

		protected function hideTrack():void {
			if (this.contains(_trackCaptureArea)) this.removeChild(_trackCaptureArea);
			if (this.contains(_track)) this.removeChild(_track);
			_track.visible = false;
			onTrackHidden();
		}

		protected function onTrackHidden():void {

		}

		/**
		 * Returns the current orientation of this SlideHandle
		 */
		public function get orientation():String {
			return _orientation;
		}
	}
}

