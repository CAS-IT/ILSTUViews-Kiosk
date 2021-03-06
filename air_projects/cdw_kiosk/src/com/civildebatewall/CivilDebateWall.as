/*--------------------------------------------------------------------
Civil Debate Wall Kiosk
Copyright (c) 2012 Local Projects. All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 2 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program. 

If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------*/

package com.civildebatewall {
	
	import com.bit101.components.FPSMeter;
	import com.civildebatewall.data.Data;
	import com.civildebatewall.kiosk.core.Kiosk;
	import com.civildebatewall.wallsaver.core.WallSaver;
	import com.civildebatewall.wallsaver.core.WallSaverTimer;
	import com.demonsters.debugger.MonsterDebugger;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.FastEase;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Strong;
	import com.greensock.events.TweenEvent;
	import com.greensock.plugins.CacheAsBitmapPlugin;
	import com.greensock.plugins.ThrowPropsPlugin;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.kitschpatrol.flashspan.FlashSpan;
	import com.kitschpatrol.flashspan.NetworkedScreen;
	import com.kitschpatrol.flashspan.events.CustomMessageEvent;
	import com.kitschpatrol.flashspan.events.FlashSpanEvent;
	import com.kitschpatrol.flashspan.events.FrameSyncEvent;
	import com.kitschpatrol.futil.tweenPlugins.FutilBlockPlugin;
	import com.kitschpatrol.futil.utilitites.BitmapUtil;
	import com.kitschpatrol.futil.utilitites.FileUtil;
	import com.kitschpatrol.futil.utilitites.GraphicsUtil;
	import com.kitschpatrol.futil.utilitites.NumberUtil;
	import com.kitschpatrol.futil.utilitites.PlatformUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.setup.SimpleTargetSetup;
	import org.as3commons.logging.setup.target.AirFileTarget;
	import org.as3commons.logging.setup.target.MonsterDebugger3TraceTarget;
	import org.as3commons.logging.setup.target.TraceTarget;
	import org.as3commons.logging.setup.target.mergeTargets;
	import org.as3commons.logging.util.captureUncaughtErrors;
	
	// Main entry point for the app.
	// Manages display of Interactive Kiosk and Wallsaver modes.
	public class CivilDebateWall extends Sprite	{
		
		private static const logger:ILogger = getLogger(CivilDebateWall);
		
		public static var flashSpan:FlashSpan;		
		public static var data:Data;
		public static var state:State;
		public static var settings:Settings;
		public static var self:CivilDebateWall;
		

		
		public static var wallSaver:WallSaver;
		
		public static var kiosk:Kiosk;
		public static var	dashboard:Dashboard;
		
			
		public static var userActivityMonitor:UserActivityMonitor;

		public static var wallSaverTimer:WallSaverTimer;
		public static var randomDebateTimer:RandomDebateTimer;
		public static var dataUpdateTimer:DataUpdateTimer;		
		
		private var commandLineArgs:Array;
		public var fpsMeter:FPSMeter;
		
		public function CivilDebateWall(commandLineArgs:Array = null)	{
			self = this;
			this.commandLineArgs = commandLineArgs;
			
			// TweenMax Greensock plugins
			TweenPlugin.activate([ThrowPropsPlugin, CacheAsBitmapPlugin, TransformAroundCenterPlugin, TransformAroundPointPlugin]);				

			// TweenMax Futil plugins
			TweenPlugin.activate([FutilBlockPlugin]);
			
			// TODO Problem for wallsaver? 
			FastEase.activate([Linear, Quad, Cubic, Quart, Quint, Strong]);
			
			// Work around for lack of mouse-down events (Still need this?)
			// http://forums.adobe.com/message/2794098?tstart=0
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;			
			
			fpsMeter = new FPSMeter(this);
			fpsMeter.visible = false;
			fpsMeter.start();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
			
			// load settings from a local JSON file			
			settings = SettingsLoader.load();
			
			// In local multi-screen debug mode, kiosk number is set via command line args instead of IP-based introspection
			// TODO genereic command line settings override system?
			if (commandLineArgs.length > 0) {
				trace("CLA:");
				trace(commandLineArgs);
				settings.kioskNumber = commandLineArgs[0];
				settings.testWidth = commandLineArgs[1];
				settings.testHeight = commandLineArgs[2];	
				settings.localMultiScreenTest = true;
				settings.useSLR = false;
				settings.useWebcam = false;
				settings.halfSize= false;
			}
			
			// Pick computer name for logging folder prefix
			var computerName:String;
			if (PlatformUtil.isMac) {
				settings.computerName = (settings.localMultiScreenTest) ? "LocalMac" + settings.kioskNumber : "LocalMacSingle";
				init(); // Keep setting up
			}
			else if (PlatformUtil.isWindows) {
				// Windows uses the conmputer's host name to prefix the log folder
				PlatformUtil.getHostName(onHostName);
			}
		}
		
		private function onHostName(name:String):void {
			settings.computerName = name;
			init(); // Keep setting up
		}
		
		private function init():void {
			// Set up logging via AS3 Commons Logging
			// More info: http://as3commons.org/as3-commons-logging/
			if (settings.logToMonster) MonsterDebugger.initialize(this);
			var monsterTarget:MonsterDebugger3TraceTarget = (settings.logToMonster) ? new MonsterDebugger3TraceTarget() : null; 
			var traceTarget:TraceTarget = (settings.logToTrace) ? new TraceTarget() : null;			
			var fileTarget:AirFileTarget = (settings.logToFile) ? new AirFileTarget(settings.logFilePath + "/" + settings.computerName + "/TheWallKiosk.{date}.log") : null; 			
			
			LOGGER_FACTORY.setup = new SimpleTargetSetup(mergeTargets(traceTarget, fileTarget, monsterTarget));			

			captureUncaughtErrors(loaderInfo); // log errors, does this always work?			

			logger.info("Starting The Wall Kiosk");
			logger.info("Logging to: " + (settings.logToMonster ? "MonsterDebugger " : "") + "|" + (settings.logToTrace ? " Trace " : "") + "|" + (settings.logToFile ? " File" : ""));
			logger.info("Server: " + settings.serverPath);
			logger.info("Loaded settings from: " + settings.settingsPath);
			
			if (commandLineArgs.length > 0) {
				logger.info("Command line args: " + commandLineArgs);
			}
			else {
				logger.info("No command line args passed at startup");				
			}			

			// set up the stage
			stage.quality = StageQuality.BEST;
	
			// three possible window modes
			if (settings.localMultiScreenTest) {			
				// dimensions come from app.xml
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				stage.nativeWindow.width = settings.testWidth;
				stage.nativeWindow.height = settings.testHeight;				
			}
			else if (settings.halfSize) {
				// temporarily squish screen for laptop development (half size)				
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				stage.nativeWindow.width = 540;
				stage.nativeWindow.height = 960;
			}
			else {
				// window dimensions are defined in app.xml, don't bother scaling
				stage.scaleMode = StageScaleMode.NO_SCALE;
			}
			
			// make sure image folders exist
			if (PlatformUtil.isWindows) {
				FileUtil.createFolderIfNecessary(settings.imagePath);
				FileUtil.createFolderIfNecessary(settings.tempImagePath);				
			}
			else if (PlatformUtil.isMac) {
				FileUtil.createFolderIfNecessary(settings.imagePath);
				// NO SLR, so no temp folder
			}
			
			// fill the background
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 1080, 1920);
			graphics.endFill();
			
			// set up gui overlay
			dashboard = new Dashboard();
			dashboard.visible = false;
			
			// scale the dashboard according to
			if (settings.halfSize) {
				dashboard.scaleX = 1080 / stage.width;
				dashboard.scaleY = 1920 / stage.height;
			}
			
			// Set the custom context menu
			contextMenu = Menu.getMenu();
			
			if (settings.startFullScreen)	toggleFullScreen();
			
						
			
			// Set up the wall data stores
			data = new Data();
			state = new State();
			
			userActivityMonitor = new UserActivityMonitor(stage);
			
			// Interactive kiosk
			kiosk = new Kiosk();
			addChild(kiosk);

			if (PlatformUtil.isWindows) {
				logger.info("Getting Kiosk Number from IP");
				//flashSpan = new FlashSpan(-1, settings.flashSpanConfigPath); // For production
				flashSpan = new FlashSpan(settings.kioskNumber, File.applicationDirectory.nativePath + "/flash_span_settings.xml"); // For testing
			}
			else {
				flashSpan = new FlashSpan(settings.kioskNumber, File.applicationDirectory.nativePath + "/flash_span_settings.xml");
			}
			
			// Set up flash span
			// TODO move this to its own class
			flashSpan.addEventListener(FlashSpanEvent.START, onSyncStart);
			flashSpan.addEventListener(FlashSpanEvent.STOP, onSyncStop);
			flashSpan.addEventListener(CustomMessageEvent.MESSAGE_RECEIVED, onCustomMessageReceived);
			flashSpan.addEventListener(FrameSyncEvent.SYNC, onFrameSync);
			
			settings.kioskNumber = flashSpan.settings.thisScreen.id;
			
			logger.info("Kiosk Number: " + settings.kioskNumber);
			
			wallSaver = new WallSaver();
			wallSaver.x = -flashSpan.settings.thisScreen.x; // shift content left
			addChild(wallSaver);
			
			wallSaverTimer = new WallSaverTimer();
			randomDebateTimer = new RandomDebateTimer();
			dataUpdateTimer = new DataUpdateTimer();
			
			// Load the data, which fills up everything through binding callbacks
			CivilDebateWall.state.firstLoad = true;
			data.load();

			// dashboard goes on top... or add when active? 
			addChild(dashboard);
			
			// tell thew world we've gone active
			userActivityMonitor.onActive();
		}
		

				
		public function toggleFullScreen():void {		
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				Mouse.hide();
			}
			else {
				stage.displayState = StageDisplayState.NORMAL;
				Mouse.show();
			}		
		}
		
		
		// FLASH SPAN ====================================================================================================
		
		// Wallsaver control abstraction... these get broadcast to everyone through flashspan
		
		// message headers
		private const PLAY_SEQUENCE_A:String = "a";
		private const PLAY_SEQUENCE_B:String = "b";
		private const ACTIVITY:String = "c";
		private const INACTIVITY:String = "d";
		
		private function onSyncStart(e:FlashSpanEvent):void {
			//wallSaver.timeline.play();
			
		}

		
		public function broadcastActivity():void {
			flashSpan.broadcastCustomMessage(ACTIVITY, settings.kioskNumber.toString());
		}
		
		public function broadcastInactivity():void {
			flashSpan.broadcastCustomMessage(INACTIVITY, settings.kioskNumber.toString());
		}
		
		private function onSyncStop(e:FlashSpanEvent):void {
			if (wallSaver.timeline.active) wallSaver.endSequence();
			if ((settings.kioskNumber == 0) && (everyoneInactive)) wallSaverTimer.start();
			if (!state.userActive) CivilDebateWall.randomDebateTimer.start(); // keep shuffling debates
			if (!state.userActive) CivilDebateWall.dataUpdateTimer.start(); // keep updating
		}		
		
		
		public function recordSequenceA():void {
			wallSaver.cueSequenceA();
			wallSaver.timeline.timeScale = 2.0;
			wallSaver.timeline.addEventListener(TweenEvent.UPDATE, function(e:TweenEvent):void {
				takeScreenshot();
			});
			logger.info("recording sequence A");
			
			// add placeholders
			var screen1:Bitmap = Assets.sampleScreen1;
			var screen2:Bitmap = Assets.sampleScreen2;
			var screen3:Bitmap = Assets.sampleScreen3;
			var screen4:Bitmap = Assets.sampleScreen4;
			var screen5:Bitmap = Assets.sampleScreen5;			
			
			screen1.x = CivilDebateWall.flashSpan.settings.screens[0].x;			
			screen2.x = CivilDebateWall.flashSpan.settings.screens[1].x;
			screen3.x = CivilDebateWall.flashSpan.settings.screens[2].x;				
			screen4.x = CivilDebateWall.flashSpan.settings.screens[3].x;
			screen5.x = CivilDebateWall.flashSpan.settings.screens[4].x;
			
			var wallSaverIndex:int = getChildIndex(wallSaver);
			
			this.addChildAt(screen1, wallSaverIndex);
			this.addChildAt(screen2, wallSaverIndex);
			this.addChildAt(screen3, wallSaverIndex);
			this.addChildAt(screen4, wallSaverIndex);
			this.addChildAt(screen5, wallSaverIndex);			
			
			CivilDebateWall.randomDebateTimer.stop();
			CivilDebateWall.dataUpdateTimer.stop();		
			wallSaver.timeline.play();			
		}
		
		public function playSequenceA():void {
			if (settings.kioskNumber == 0) wallSaverTimer.stop();
			if (wallSaver.timeline.active) wallSaver.timeline.stop();
			flashSpan.stop();
			flashSpan.broadcastCustomMessage(PLAY_SEQUENCE_A); // this cues
			TweenMax.delayedCall(2, flashSpan.start);  // wait for messages to land before starting
		}
		
		public function playSequenceB():void {
			if (settings.kioskNumber == 0) wallSaverTimer.stop();
			if (wallSaver.timeline.active) wallSaver.timeline.stop();
			flashSpan.stop();
			flashSpan.broadcastCustomMessage(PLAY_SEQUENCE_B); // this cues
			TweenMax.delayedCall(2, flashSpan.start); // wait for messages to land before starting
		}
		
		// keep a screen-indexed array of activity status
		// disconnected screens are null
		private var everyoneInactive:Boolean;
		private var activeScreens:Array = [];
		
		// set missing screens to null
		private function updateScreenActivityStatus():void {
			for (var i:int = 0; i < flashSpan.settings.screens.length; i++) {
				if (!flashSpan.settings.screens[i].connected) activeScreens[i] = null;
			}
		}
		
		private function isEveryoneInactive():Boolean {
			for (var i:int = 0; i < activeScreens.length; i++) {
				if ((activeScreens[i] != null) && (activeScreens[i])) {
					return false;	
				}
			}
			return true;
		}
		
		
		
		
		
		private function onCustomMessageReceived(e:CustomMessageEvent):void {
			if (e.header == PLAY_SEQUENCE_A) {
				CivilDebateWall.randomDebateTimer.stop();
				CivilDebateWall.dataUpdateTimer.stop();				
				logger.info("Playing Sequence A");
				wallSaver.cueSequenceA();
				flashSpan.frameCount = 0;
			}
			else if (e.header == PLAY_SEQUENCE_B) {
				CivilDebateWall.randomDebateTimer.stop();
				CivilDebateWall.dataUpdateTimer.stop();			
				logger.info("Playing Sequence B");
				wallSaver.cueSequenceB();
				flashSpan.frameCount = 0;
			}
			else if ((e.header == ACTIVITY) || (e.header == INACTIVITY)) {
				
				// Only the server (leftmost screen, 0) cares about this
				if (settings.kioskNumber == 0) {
					var fromScreen:NetworkedScreen = flashSpan.settings.screens[int(e.message)];
					updateScreenActivityStatus();	
					
					if (e.header == ACTIVITY) {
						logger.info("Received activity notice from screen " + fromScreen.id);
						activeScreens[fromScreen.id] = true;
						everyoneInactive = false;
						wallSaverTimer.stop();
					}
					else if (e.header == INACTIVITY) {
						logger.info("Received inctivity notice from screen " + fromScreen.id);
						activeScreens[fromScreen.id] = false;

						everyoneInactive = isEveryoneInactive(); 
						
						if (everyoneInactive) {
							logger.info("All screens inactive. Starting wallsaver timer");
							wallSaverTimer.start()
						}
					}
				}
			}		
			else {
				logger.error("Received unknown custom packet: " + e.header + "," + e.message);
			}

		}

		private function onFrameSync(e:FrameSyncEvent):void {
			
			if (e.frameCount < wallSaver.timeline.duration) {
				wallSaver.timeline.gotoAndPlay(e.frameCount);
			}
		}
		
		
		private var screenshotIndex:int = 0;
		
		
		// This actually takes a psuedo-five screen screenshot
		public function takeScreenshot():void {

			
			// Take Photo
			var screen:Bitmap = new Bitmap(new BitmapData(CivilDebateWall.flashSpan.settings.totalWidth, CivilDebateWall.flashSpan.settings.totalHeight, false, 0xffffff), "auto", true);
			
			screen.bitmapData.draw(this.stage);
			FileUtil.saveJpeg(screen, settings.screenshotPath, "frame-" + NumberUtil.zeroPad(screenshotIndex++, 5) + ".jpg", 70);
		
		}
		
	}
}
