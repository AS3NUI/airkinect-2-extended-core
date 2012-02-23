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

package com.as3nui.nativeExtensions.air.kinect.extended.simulator.helpers {
	import com.as3nui.nativeExtensions.air.kinect.Device;
	import com.as3nui.nativeExtensions.air.kinect.events.UserFrameEvent;
	import com.as3nui.nativeExtensions.air.kinect.extended.simulator.UserPlayer;
	import com.as3nui.nativeExtensions.air.kinect.extended.simulator.UserRecorder;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	/**
	 * Skeleton Simulator Helper is a simple utility class to add Record and Playback of Skeleton Frames to any project with
	 * minimal code.
	 * To use with manual Skeleton Frame management use the following
	 * <p>
	 * <code>
	 *			SkeletonSimulatorHelper.init(stage);
	 *			SkeletonSimulatorHelper.onSkeletonFrame.add(onSimulatedUserFrame);
	 * </code>
	 * </p>
	 *
	 * To use with AIRKinectManager simply cuse
	 * <p>
	 * <code>
	 *			SkeletonSimulatorHelper.init(stage);
	 * </code>
	 * </p>
	 *
	 * Once initialized all functions are accessible through keyboard, R for record, L for Load, P for play/pause, S for Stop.
	 */
	public class SkeletonSimulatorHelper {
		private static var TOTAL_RECORDINGS:uint = 0;

		private static var _userPlayer:UserPlayer;
		private static var _userRecorder:UserRecorder;
		private static var _stage:Stage;

		private static var _enabled:Boolean;

		/**
		 * Determines if Playback should start automatically upon loading XML. If false one must
		 * play the recording after loading it manually
		 */
		public static var autoPlayOnLoad:Boolean = true;

		/**
		 * Determines if playback should automatically start after recording is complete. IF false
		 * one must load the saved XML file and play it back manually
		 */
		public static var autoPlayOnRecordFinished:Boolean = true;

		/**
		 * Determines if file saving dialog should automatically be presented when a recording is complete. If false
		 * one must manage XML data from the onRecordingStopped Signal
		 */
		public static var saveFileOnRecordFinished:Boolean = true;

		/**
		 * Determines is playback should automatically loop
		 */
		public static var autoLoop:Boolean = false;

		/**
		 * Determines if the SHIFT key is required to be held down in addiction to key presses
		 */
		public static var requireShift:Boolean = false;

		/**
		 * Key used to Load XML
		 */
		public static var loadButton:uint = Keyboard.L;
		/**
		 * Key used to Play XML
		 */
		public static var playButton:uint = Keyboard.P;
		/**
		 * Key used to Pause Playback or Recording
		 */
		public static var pauseButton:uint = Keyboard.P;

		/**
		 * Key used to stop playback or recording
		 */
		public static var stopButton:uint = Keyboard.S;

		/**
		 * Key used to start recording
		 */
		public static var recordButton:uint = Keyboard.R;

		private static var _loop:Boolean;
		private static var _currentPlayback:Object;
		private static var _currentRecording:String;
		private static var _device:Device;

		/**
		 * Initializes the Simulation Helper
		 * To use with manual Skeleton Frame management use the following
		 * <p>
		 * <code>
		 *			SkeletonSimulatorHelper.init(stage);
		 *			SkeletonSimulatorHelper.onSkeletonFrame.add(onSimulatedUserFrame);
		 * </code>
		 * </p>
		 *
		 * To use with AIRKinectManager simply cuse
		 * <p>
		 * <code>
		 *			SkeletonSimulatorHelper.init(stage);
		 * </code>
		 * </p>
		 *
		 * @param stage					stage reference for helper to use
		 */
		public static function init(stage:Stage, device:Device):void {
			_stage = stage;
			_device = device;
			_userPlayer = new UserPlayer(_device);
			_userRecorder = new UserRecorder(device);

			enable();
		}

		/**
		 * Un-Initializes the Helper. stopping recorder and player and removing all Signals and Listeners.
		 */
		public static function uninit():void {
			disable();
			if (_userPlayer && (_userPlayer.playing || _userPlayer.paused)) {
				_userPlayer.stop();
				_userPlayer.clear();
			}

			if (_userRecorder && _userRecorder.recording) {
				_userRecorder.stop();
				_userRecorder.clear();
			}

			_currentPlayback = null;
			_currentRecording = null;
		}

		/**
		 * Enables the Simulation helper. This is done automatically in the constructor and only needs to be run manually
		 * if it has been disabled.
		 */
		public static function enable():void {
			if (_enabled) return;
			_userPlayer.addEventListener(UserFrameEvent.USER_FRAME_UPDATE, onSimulatedUserFrame);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_enabled = true;
		}

		/**
		 * Disables the Simulation Helper. IT will not longer responds to key presses, and skeleton updates.
		 */
		public static function disable():void {
			if (!_enabled) return;
			_userPlayer.removeEventListener(UserFrameEvent.USER_FRAME_UPDATE, onSimulatedUserFrame);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_enabled = false;
		}

		private static function onKeyUp(event:KeyboardEvent):void {
			if (!_enabled) return;
			if (requireShift && !event.shiftKey) return;


			if (event.keyCode == loadButton) {
				_loop = event.ctrlKey || autoLoop;
				load();
			} else if (event.keyCode == playButton || event.keyCode == pauseButton) {
				if (_userPlayer.paused) {
					_userPlayer.resume();
				} else if (!_userPlayer.playing) {
					_loop = event.ctrlKey || autoLoop;
					play();
				} else if (_userPlayer.playing) {
					pause();
				}
			} else if (event.keyCode == stopButton) {
				stop();
			} else if (event.keyCode == recordButton) {
				record();
			}
		}

		/**
		 * Starts the recording, this should be done though the Keyboard automatically.
		 */
		public static function record():void {
			if (!_enabled) return;
			if (!_userRecorder || !_userPlayer) return;
			_userRecorder.record();
		}

		/**
		 * On Record stopped. Dispatches  onRecordingStopped with JSON as its only parameter.
		 * If autoPlayOnRecordFinished playback is started
		 * If saveFileOnRecordFinished file dialog is shown to save XML
		 */
		private static function onRecordStopped():void {
			_currentRecording = _userRecorder.currentRecordingJSON;

			if (saveFileOnRecordFinished) {
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(_currentRecording);

				var fr:FileReference = new FileReference();
				fr.addEventListener(Event.SELECT, onSaveSuccess);
				fr.addEventListener(Event.CANCEL, onSaveCancel);
				fr.save(ba, "SkeletonRecording_" + TOTAL_RECORDINGS + ".json");
			} else {
				if (autoPlayOnRecordFinished) {
					if (_userPlayer.playing) _userPlayer.stop();
					_currentPlayback = JSON.parse(_currentRecording) as Object;
					play();
				}
			}
		}

		private static function onSaveSuccess(event:Event):void {
			TOTAL_RECORDINGS++;
			if (autoPlayOnRecordFinished) {
				if (_userPlayer.playing) _userPlayer.stop();
				_currentPlayback = JSON.parse(_currentRecording);
				play();
			}
		}


		private static function onSaveCancel(event:Event):void {
			if (autoPlayOnRecordFinished) {
				if (_userPlayer.playing) _userPlayer.stop();
				_currentPlayback = JSON.parse(_currentRecording);
				play();
			}
		}

		/**
		 * Prompts the user to load an JSON file for SkeletonFrame playback
		 */
		public static function load():void {
			if (!_enabled) return;
			var jsonFilter:FileFilter = new FileFilter("JSON", "*.json");
			var file:File = new File();
			file.addEventListener(Event.SELECT, onFileSelected);
			file.browseForOpen("Please select a file...", [jsonFilter]);
		}

		/**
		 * Starts playback of the current XML in memory
		 */
		public static function play():void {
			if (!_enabled) return;
			if(!_userPlayer) return;
			if (!_currentPlayback) {
				load();
				return;
			}
			if (_userPlayer.playing) _userPlayer.stop();
			_userPlayer.play(_currentPlayback, _loop);
		}

		/**
		 * If currently playing,playback is paused.
		 * If currently recording, recording is paused
		 */
		public static function pause():void {
			if (!_enabled) return;
			if (!_currentPlayback || !_userPlayer) return;
			if (_userPlayer.playing) _userPlayer.pause();
		}

		/**
		 * If currently playing, playback is stopped.
		 * If currently Recording, recording is stopped
		 */
		public static function stop():void {
			if (!_enabled) return;
			if (_userRecorder && _userRecorder.recording) {
				_userRecorder.stop();
				onRecordStopped();
			} else if (_userPlayer && _currentPlayback) {
				if (_userPlayer.playing) _userPlayer.stop();
			}
		}

		/**
		 * Stops playback and Recording and clears out all XML from memory.
		 */
		public static function clear():void {
			if (!_enabled) return;
			if (_userRecorder && _userRecorder.recording) {
				_userRecorder.stop();
				_userRecorder.record();
			}

			if (_userPlayer && _userPlayer.playing) _userPlayer.stop();

			_currentPlayback = null;
			_currentRecording = null;
		}

		private static function onFileSelected(event:Event):void {
			var fileStream:FileStream = new FileStream();
			try {
				fileStream.open(event.target as File, FileMode.READ);
				_currentPlayback = JSON.parse(fileStream.readUTFBytes(fileStream.bytesAvailable)) as Object;
				fileStream.close();
				if (autoPlayOnLoad) play();
			} catch (e:Error) {
				trace("Error loading Config : " + e.message);
			}
		}

		private static function onSimulatedUserFrame(event:UserFrameEvent):void {

		}

		/**
		 * Boolean true is player is current Playing
		 */
		public static function get playing():Boolean {
			if (!_userPlayer) return false;
			return _userPlayer.playing
		}

		/**
		 * Boolean true if player is currently paused
		 */
		public static function get paused():Boolean {
			if (!_userPlayer) return false;
			return _userPlayer.paused;
		}

		/**
		 * Boolean true if player is currently stopped
		 */
		public static function get stopped():Boolean {
			if (!_userPlayer) return false;
			return _userPlayer.stopped
		}

		/**
		 * Boolean true if currently recording
		 */
		public static function get recording():Boolean {
			if (!_userRecorder) return false;
			return _userRecorder.recording
		}
	}
}