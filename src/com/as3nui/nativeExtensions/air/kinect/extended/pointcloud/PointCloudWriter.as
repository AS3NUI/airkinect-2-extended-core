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

package com.as3nui.nativeExtensions.air.kinect.extended.pointcloud {
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * This Utility will have take Depth Image Byte Array data and save it in a variety of standard Point Cloud Formats.
	 * For example to save in PLY format for Blender to MeshLab use the following.
	 * <p>
	 * <code>
	 *     	private function onDepthFrame(e:CameraFrameEvent):void {
	 *			_depthPoints = e.data;
	 *		}
	 *
	 *  	PointCloudHelper.savePTS(_depthPoints);
	 * </code>
	 * </p>
	 */
	public class PointCloudWriter {
		private static var _onSave:Function;
		private static var _onCancel:Function;

		/**
		 * Saves Depth Data in Stardard PTS Format for use with 3DS Max 'Project Helix' Point Cloud tools.
		 * More information here http://labs.autodesk.com/utilities/3dsmax_pointcloud/
		 *
		 * @param depthData			Depth Points Byte Array from a Camera Update
		 * @param intensity			Intensity to use in file (intensity is reflectivity of a point currently not in the Kinect)
		 * @param saveCallback		Callback function to called if file save is complete, will be passed a single Event Param
		 * @param cancelCallback	Callback function to called if file cancel is complete, will be passed a single Event Param
		 */
		public static function savePTS(depthData:ByteArray, width:uint = 320, height:uint = 240, depth:uint = 2048,intensity:Number = .1, saveCallback:Function = null, cancelCallback:Function = null):void {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes((depthData.length / 6).toString());
			ba.writeUTFBytes(File.lineEnding);

			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData, width,  height,  depth);

				ba.writeUTFBytes(xygRGB.x.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.y.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.z.toString());
				ba.writeUTFBytes("   ");
				ba.writeUTFBytes(intensity.toString());
				ba.writeUTFBytes("  ");
				ba.writeUTFBytes(xygRGB.rgbString());
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "pts");
		}

		/**
		 * Saves Depth Data in Standard XYZ Format for use with such tools as MeshLab. This format is simply positional point data
		 * and does not contain and Intensity or RGB point values.
		 *
		 * @param depthData			Depth Points Byte Array from a Camera Update
		 * @param saveCallback		Callback function to called if file save is complete, will be passed a single Event Param
		 * @param cancelCallback	Callback function to called if file cancel is complete, will be passed a single Event Param
		 */
		public static function saveXYZ(depthData:ByteArray,width:uint = 320, height:uint = 240, depth:uint = 2048, saveCallback:Function = null, cancelCallback:Function = null):void {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes((depthData.length / 6).toString());
			ba.writeUTFBytes(File.lineEnding);

			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData, width, height,  depth);
				ba.writeUTFBytes(xygRGB.x.toString() + "\t");
				ba.writeUTFBytes(xygRGB.y.toString() + "\t");
				ba.writeUTFBytes(xygRGB.z.toString() + "\n");
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "xyz");
		}

		/**
		 * Saves Depth Data in Standard PLY Format for use with such tools as MeshLab and Blender.
		 * Format does not include intensity but does contain per point RGB data (currently Grayscale)
		 * @param depthData			Depth Points Byte Array from a Camera Update
		 * @param saveCallback		Callback function to called if file save is complete, will be passed a single Event Param
		 * @param cancelCallback	Callback function to called if file cancel is complete, will be passed a single Event Param
		 */
		public static function savePLY(depthData:ByteArray, width:uint = 320, height:uint = 240, depth:uint = 2048, saveCallback:Function = null, cancelCallback:Function = null):void {

			var header:String = "ply" + File.lineEnding;
			header += "format ascii 1.0" + File.lineEnding;
			header += "comment author: AS3NUI" + File.lineEnding;
			header += "element vertex " + (depthData.length / 6).toString() + File.lineEnding;
			header += "property float x" + File.lineEnding;
			header += "property float y" + File.lineEnding;
			header += "property float z" + File.lineEnding;
			header += "property uchar red" + File.lineEnding;
			header += "property uchar green" + File.lineEnding;
			header += "property uchar blue" + File.lineEnding;
			header += "end_header" + File.lineEnding;

			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(header);
			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData, width, height, depth);
				ba.writeUTFBytes(xygRGB.x.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.y.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.z.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.rgbString());
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "ply");
		}


		private static function saveByteArray(byteArray:ByteArray, extension:String):void {
			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT, onSaveSuccess);
			fr.addEventListener(Event.CANCEL, onSaveCancel);
			fr.save(byteArray, "PointCloud." + extension);
		}

		private static function onSaveCancel(event:Event):void {
			(event.target as FileReference).removeEventListener(Event.SELECT, onSaveSuccess);
			(event.target as FileReference).removeEventListener(Event.CANCEL, onSaveCancel);
			if (_onCancel != null) _onCancel.apply(null, [event]);
			_onSave = _onCancel = null;
		}


		private static function onSaveSuccess(event:Event):void {
			(event.target as FileReference).removeEventListener(Event.SELECT, onSaveSuccess);
			(event.target as FileReference).removeEventListener(Event.CANCEL, onSaveCancel);
			if (_onSave != null) _onSave.apply(null, [event]);
			_onSave = _onCancel = null;
		}
	}
}

import flash.utils.ByteArray;

class XYZRGBData {
	private var _x:Number;
	private var _y:Number;
	private var _z:Number;
	private var _r:uint;
	private var _g:uint;
	private var _b:uint;

	public static function fromDepth(depthData:ByteArray, width:uint = 320, height:uint = 240, depth:uint = 2047):XYZRGBData {
		var x:Number = depthData.readShort();
		x /= width;
		var y:Number = depthData.readShort();
		y /= height;
		var z:Number = depthData.readShort();
		if (z < 1) z = 1;
		if (z > depth) z = depth;
		z /= depth;

		var gray:uint = z * 255;
		z *= 4;
		return new XYZRGBData(x, y, z, gray, gray, gray);
	}

	function XYZRGBData(x:Number, y:Number, z:Number, r:uint = 255, g:uint = 255, b:uint = 255):void {
		_x = x;
		_y = y;
		_z = z;
		_r = r;
		_g = g;
		_b = b;
	}

	public function rgbString():String {
		return r.toString() + " " + g.toString() + " " + b.toString();
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

	public function get r():uint {
		return _r;
	}

	public function get g():uint {
		return _g;
	}

	public function get b():uint {
		return _b;
	}
}