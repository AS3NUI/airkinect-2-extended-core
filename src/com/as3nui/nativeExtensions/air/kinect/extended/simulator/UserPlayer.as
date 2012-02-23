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

package com.as3nui.nativeExtensions.air.kinect.extended.simulator {
	import com.as3nui.nativeExtensions.air.kinect.Device;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.UserFrame;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	/**
	 * Skeleton Player is used to play back a XML recording of Skeleton Frame Data
	 * For example to use with a manual event hander use the following.
	 * <p>
	 * <code>
	 *      _skeletonPlayer = new SkeletonPlayer();
	 *         _skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
	 * </code>
	 * </p>
	 *
	 * To use with the AIRKinect Manager use the following
	 * <p>
	 * <code>
	 *      _skeletonPlayer = new SkeletonPlayer();
	 *         AIRKinectManager.addSkeletonDispatcher(_skeletonPlayer);
	 * </code>
	 * </p>
	 */
	public class UserPlayer extends EventDispatcher {
		public static const STOPPED:String = "stopped";
		public static const PAUSED:String = "paused";
		public static const PLAYING:String = "playing";

		/**
		 * Pulse Sprite used to update the player through the XML
		 */
		protected var _pulseSprite:Sprite;
		/**
		 * Determines whether playback loops upon completion
		 */
		protected var _loop:Boolean;

		/**
		 * JSON Object for playback
		 */
		protected var _currentRecording:Object;

		/**
		 * Current Skeleton Frame
		 */
		protected var _currentFrame:int;
		/**
		 * End Frame of current playback
		 */
		protected var _endFrame:int;

		/**
		 * Delay between each frame this is calulcated dynamically
		 */
		protected var _delay:uint;
		/**
		 * Last Dispatched Event Time
		 */
		protected var _lastDispatchedTime:int;
		/**
		 * Determines whether to skip initial delay in Skeleton XML
		 */
		protected var _skipInitialDelay:Boolean;

		protected var _state:String = STOPPED;

		/**
		 * Reference to kinect to simulate frames through
		 */
		private var _device:Device;

		public function UserPlayer(device:Device) {
			_pulseSprite = new Sprite();
			_device = device
		}

		/**
		 * Plays an XML recording of Skeleton Frames from SkeletonRecorder
		 * @param jsonObject          Parsed JSON Object to play back
		 * @param loop                Whether to look upon playback completion
		 * @param skipInitialDelay    Forces playback to skip the delay between starting recording and the first skeleon frame.
		 */
		public function play(jsonObject:Object, loop:Boolean = false, skipInitialDelay:Boolean = true):void {

			_device.userSimulationMode = true;
			_loop = loop;
			_currentRecording = jsonObject;
			_currentFrame = 0;
			_endFrame = _currentRecording.frames.length;
			_lastDispatchedTime = getTimer();
			_skipInitialDelay = skipInitialDelay;
			_delay = _skipInitialDelay ? 0 : _currentRecording.frames[0].time - _currentRecording.startTime;
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);

			_state = PLAYING;
		}

		/**
		 * Resumes playback
		 */
		public function resume():void {
			if (!paused) return;
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PLAYING;
		}

		/**
		 * Pauses the playback of XML
		 */
		public function pause():void {
			if (!playing) return;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PAUSED;
		}

		/**
		 * Stops the playback and resets the playback
		 */
		public function stop():void {
			_currentFrame = 0;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = STOPPED;
			_device.userSimulationMode = false;
		}

		/**
		 * Clears out the current playback and empties the XML
		 */
		public function clear():void {
			if (this.playing) stop();
			_currentRecording = null;
		}

		/**
		 * Update is called from the pulse Sprite on Enter Frame
		 * @param event
		 */
		protected function onUpdate(event:Event):void {
			//No Recording? no use being here...
			if (!_currentRecording) return;

			//Checks the current time against the last dispatched time and delay to dispatched a frame.
			if (getTimer() > _lastDispatchedTime + _delay) {
				_lastDispatchedTime = getTimer();

				var currentFrame:Object = _currentRecording.frames[_currentFrame].userFrame;
				var users:Vector.<User> = new <User>[];
				var skeletonJoints:Vector.<SkeletonJoint> = new <SkeletonJoint>[];
				for each(var user:Object in currentFrame.users) {
					var position:Vector3D = new Vector3D();
					position.x = user.position.x;
					position.y = user.position.y;
					position.z = user.position.z;

					var positionRelative:Vector3D = new Vector3D();
					positionRelative.x = user.positionRelative.x;
					positionRelative.y = user.positionRelative.y;
					positionRelative.z = user.positionRelative.z;

					var rgbPosition:Point = new Point();
					rgbPosition.x = user.rgbPosition.x;
					rgbPosition.y = user.rgbPosition.y;

					var rgbRelativePosition:Point = new Point();
					rgbRelativePosition.x = user.rgbRelativePosition.x;
					rgbRelativePosition.y = user.rgbRelativePosition.y;

					var depthPosition:Point = new Point();
					depthPosition.x = user.depthPosition.x;
					depthPosition.y = user.depthPosition.y;

					var depthRelativePosition:Point = new Point();
					depthRelativePosition.x = user.depthRelativePosition.x;
					depthRelativePosition.y = user.depthRelativePosition.y;

					for each(var skeletonJoint:Object in user.skeletonJoints) {
						var jointPosition:Vector3D = new Vector3D();
						jointPosition.x = skeletonJoint.position.x;
						jointPosition.y = skeletonJoint.position.y;
						jointPosition.z = skeletonJoint.position.z;

						var jointPositionRelative:Vector3D = new Vector3D();
						jointPositionRelative.x = skeletonJoint.positionRelative.x;
						jointPositionRelative.y = skeletonJoint.positionRelative.y;
						jointPositionRelative.z = skeletonJoint.positionRelative.z;

						var jointOrientation:Vector3D = new Vector3D();
						jointOrientation.x = skeletonJoint.orientation.x;
						jointOrientation.y = skeletonJoint.orientation.y;
						jointOrientation.z = skeletonJoint.orientation.z;

						var jointRGBPosition:Point = new Point();
						jointRGBPosition.x = skeletonJoint.rgbPosition.x;
						jointRGBPosition.y = skeletonJoint.rgbPosition.y;

						var jointRGBRelativePosition:Point = new Point();
						jointRGBRelativePosition.x = skeletonJoint.rgbRelativePosition.x;
						jointRGBRelativePosition.y = skeletonJoint.rgbRelativePosition.y;

						var jointDepthPosition:Point = new Point();
						jointDepthPosition.x = skeletonJoint.depthPosition.x;
						jointDepthPosition.y = skeletonJoint.depthPosition.y;

						var jointDepthRelativePosition:Point = new Point();
						jointDepthRelativePosition.x = skeletonJoint.depthRelativePosition.x;
						jointDepthRelativePosition.y = skeletonJoint.depthRelativePosition.y;

						skeletonJoints.push(new SkeletonJoint(
								skeletonJoint.name,
								jointPosition, jointPositionRelative, skeletonJoint.positionConfidence,
								jointOrientation, skeletonJoint.orientationConfidence,
								jointRGBPosition, jointRGBRelativePosition,
								jointDepthPosition, jointDepthRelativePosition))
					}

					users.push(new User(
							user.framework, user.userID, user.trackingID,
							position, positionRelative,
							rgbPosition, rgbRelativePosition,
							depthPosition, depthRelativePosition,
							user.hasSkeleton as Boolean,
							skeletonJoints
					));

				}
				var userFrame:UserFrame = new UserFrame(_currentFrame, getTimer(), users);
				_device.simulateUserFrame(userFrame);

				if (_currentFrame >= _endFrame - 1) {
					if (_loop) {
						_delay = _skipInitialDelay ? 0 : _currentRecording.frames[0].time - _currentRecording.startTime;
						_currentFrame = 0;
					} else {
						stop();
					}
				} else {
					_delay = _currentRecording.frames[_currentFrame + 1].time - _currentRecording.frames[_currentFrame].time;
				}

				_currentFrame++;
			}
		}

		/**
		 * Returns a true if the player is currently playing
		 */
		public function get playing():Boolean {
			return _state == PLAYING;
		}

		/**
		 * Returns a true if the player is currently paused
		 */
		public function get paused():Boolean {
			return _state == PAUSED;
		}

		/**
		 * Returns a true if the player is stopped
		 */
		public function get stopped():Boolean {
			return _state == STOPPED;
		}
	}
}