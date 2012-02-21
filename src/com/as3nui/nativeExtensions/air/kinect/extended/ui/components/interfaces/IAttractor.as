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

package com.as3nui.nativeExtensions.air.kinect.extended.ui.components.interfaces {
	import flash.geom.Point;

	/**
	 * Attractor will pull a cursor towards it. This is managed bgy the UIManager currently a cursor moving OVER an object
	 * will start the attraction. Once attraction is complete a cursor will be capture into the captureHost
	 */
	public interface IAttractor {

		/**
		 * Capture host to capture the cursor upon attraction complete
		 */
		function get captureHost():ICaptureHost;

		/**
		 * Global Center position of attraction point
		 */
		function get globalCenter():Point;

		/**
		 * Width of the capture area
		 */
		function get captureWidth():Number;

		/**
		 * Height of the capture area
		 */
		function get captureHeight():Number;

		/**
		 * Minimum pull of the attraction
		 */
		function get minPull():Number;

		/**
		 * Maximum pull of the attraction
		 */
		function get maxPull():Number;
	}
}