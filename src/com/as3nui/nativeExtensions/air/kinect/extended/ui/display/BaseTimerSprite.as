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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.display {
	import flash.display.Sprite;

	/**
	 * Base class for all UI Timer Sprites. All Timers should extend this class
	 * and properly handle onProgress
	 */
	public class BaseTimerSprite extends Sprite {
		protected var _progress:Number;
		
		public function BaseTimerSprite() {
			_progress = 0;
		}

		/**
		 * Function should be overridden by custom Timer Sprite
		 * @param progress		Progress will be a number between 0-1 indecating the progress of the timer.
		 */
		public function onProgress(progress:Number):void {
			_progress = progress;
		}
	}
}