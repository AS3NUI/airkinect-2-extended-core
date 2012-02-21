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

package com.as3nui.nativeExtensions.air.kinect.extended.simulator.data {
	import com.as3nui.nativeExtensions.air.kinect.data.UserFrame;

	/**
	 * Timecoded User Frame is used to associate a UserFrame with the time of a recording.
	 */
	public class TimeCodedUserFrame {
		protected var _time:uint;
		protected var _userFrame:UserFrame;

		public function TimeCodedUserFrame(time:uint, userFrame:UserFrame):void {
			_time = time;
			_userFrame = userFrame;
		}

		public function get time():uint {
			return _time;
		}

		public function get userFrame():UserFrame {
			return _userFrame;
		}
	}
}