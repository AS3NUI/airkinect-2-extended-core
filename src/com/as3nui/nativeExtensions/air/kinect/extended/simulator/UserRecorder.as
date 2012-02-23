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
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.events.UserFrameEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.simulator.data.TimeCodedUserFrame;
	import com.as3nui.nativeExtensions.air.kinect.extended.simulator.data.UserRecording;

	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * Skeleton Recorder is used to capture Skeleton Frames from the Kinect and record them.
	 * Upon completion data can be retrieved as XML
	 */
	public class UserRecorder extends EventDispatcher {
		/**
		 * Stopped state of recording
		 */
		public static const STOPPED:String = "stopped";

		/**
		 * Recording State of Recorder
		 */
		public static const RECORDING:String = "recording";

		/**
		 * Paused state of recorder
		 */
		public static const PAUSED:String = "paused";

		/**
		 * Current recorder state
		 */
		protected var _state:String = STOPPED;

		/**
		 * A vector of TimeCodedUserFrames that have been recorded
		 */
		protected var _currentRecording:Vector.<TimeCodedUserFrame>;

		/**
		 * Time inwhich recording started
		 */
		protected var _recordingStartTimer:int;
		/**
		 * Duration of the recording
		 */
		protected var _recordedDuration:int;

		/**
		 * Whether recording should ignore empty skeleton frames.
		 */
		protected var _ignoreEmptyFrames:Boolean;

		/**
		 * Kinect Instance to record from
		 */
		private var _device:Kinect;

		/**
		 * Skeleton Recorder constructor
		 */
		public function UserRecorder(device:Kinect) {
			_currentRecording = new <TimeCodedUserFrame>[];
			_ignoreEmptyFrames = true;
			_device = device;
		}

		/**
		 * Starts recording Skeleton Frames from the Kinect
		 */
		public function record():void {
			if (recording) return;
			//If stopped start a new recording
			if (_state == STOPPED) clear();
			_recordingStartTimer = getTimer();
			_state = RECORDING;
			_device.addEventListener(UserFrameEvent.USER_FRAME_UPDATE, onUserFrame);
		}

		/**
		 * Pauses the recorder
		 */
		public function pause():void {
			if (!recording) return;
			_state = PAUSED;
			_device.removeEventListener(UserFrameEvent.USER_FRAME_UPDATE, onUserFrame);
		}

		/**
		 * Stops the recording
		 */
		public function stop():void {
			if (!recording) return;
			_state = STOPPED;
			_recordedDuration = getTimer() - _recordingStartTimer;
			_device.removeEventListener(UserFrameEvent.USER_FRAME_UPDATE, onUserFrame);
		}

		/**
		 * Clears out the current recording data
		 */
		public function clear():void {
			_currentRecording = new <TimeCodedUserFrame>[];
		}

		/**
		 * Event handler for USer from from Kinect. Adds frame to recorded buffer
		 * @param event		UserFrameEvent
		 */
		protected function onUserFrame(event:UserFrameEvent):void {
			if (!_ignoreEmptyFrames || event.userFrame.usersWithSkeleton.length > 0) {
				_currentRecording.push(new TimeCodedUserFrame(getTimer(), event.userFrame));
			}
		}

		/**
		 * Returns the current Recording as a vector
		 */
		public function get currentRecording():Vector.<TimeCodedUserFrame> {
			return _currentRecording;
		}

		/**
		 * Returns the current Recording in JSON format
		 */
		public function get currentRecordingJSON():String {
			if (_state != STOPPED) return null;
			var recording:UserRecording = new UserRecording(_recordedDuration, _recordingStartTimer, _currentRecording);
			return JSON.stringify(recording);
		}

		/**
		 * Boolean true if the recorder is recording
		 */
		public function get recording():Boolean {
			return _state == RECORDING;
		}

		/**
		 * Boolean true if the recorder is currently stopped
		 */
		public function get stopped():Boolean {
			return _state == STOPPED;
		}

		/**
		 * Boolean true if the recorder is currently paused
		 */
		public function get paused():Boolean {
			return _state == PAUSED;
		}

		/**
		 * Boolean to set if Empty frames should be ignored.
		 * If this is true any frames with 0 skeletons will not be recorded.
		 * If false all frames will be recorded regardless of number of skeletons
		 */
		public function get ignoreEmptyFrames():Boolean {
			return _ignoreEmptyFrames;
		}

		/**
		 * Boolean to set if Empty frames should be ignored.
		 * If this is true any frames with 0 skeletons will not be recorded.
		 * If false all frames will be recorded regardless of number of skeletons
		 */
		public function set ignoreEmptyFrames(value:Boolean):void {
			_ignoreEmptyFrames = value;
		}
	}
}