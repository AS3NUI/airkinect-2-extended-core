/**
 *
 * User: Ross
 * Date: 2/20/12
 * Time: 8:11 PM
 */
package com.as3nui.nativeExtensions.air.kinect.extended.simulator.data {
	public class UserRecording {

		private var _duration:uint;
		private var _startTime:uint;
		private var _frames:Vector.<TimeCodedUserFrame>;

		public function UserRecording(duration:uint,  startTime:uint,  frames:Vector.<TimeCodedUserFrame>) {
			_duration = duration;
			_startTime = startTime;
			_frames = frames;
		}
		public function get duration():uint {
			return _duration;
		}

		public function get startTime():uint {
			return _startTime;
		}

		public function get frames():Vector.<TimeCodedUserFrame> {
			return _frames;
		}
	}
}