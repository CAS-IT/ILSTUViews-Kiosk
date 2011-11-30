package com.civildebatewall {
	import com.bit101.components.*;
	import com.civildebatewall.data.Question;
	import com.civildebatewall.kiosk.core.Kiosk;
	
	import flash.display.*;
	import flash.events.Event;
	
	
	public class Dashboard extends Window	{
		
		private var logBox:TextArea;
		private var viewChooser:ComboBox;
		private var overlaySlider:Slider;
		private var focalLengthSlider:Slider;
		private var barTestSlider:Slider;		
		
		
		
		private var framesRendered:uint;
		public var wallsaverFrameLabel:Label;
		public var frameRateLabel:Label;
		public var framesRenderedLabel:Label;
		
		public function Dashboard(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Dashboard")	{
			super(parent, xpos, ypos, title);
			this.width = 250;
			this.height = 250;
			this.hasMinimizeButton = true;
			this.minimized = true;
			
			framesRendered = 0;
			
			
			new PushButton(this, 5, 5, "Cue Sequence A", function():void { CivilDebateWall.self.cueSequenceA(); });
			new PushButton(this, 110, 5, "Cue Sequence B", function():void { CivilDebateWall.self.cueSequenceB(); });
			new PushButton(this, 5, 50, "Play", function():void { CivilDebateWall.self.startWallsaver(); });
			new PushButton(this, 110, 50, "Stop", function():void { CivilDebateWall.self.stopWallsaver(); });
			wallsaverFrameLabel = new Label(this, 5, 100, "Frame Number:");
			frameRateLabel = new Label(this, 5, 125, "Frame Rate:");
			framesRenderedLabel = new Label(this, 5, 150, "Frames Rendered:");			
			
			CivilDebateWall.self.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
				
			
//			logBox = new TextArea(this, 5, 5, "Dashboard ready");
//			logBox.width = this.width - 10;
//			logBox.height = 90;

//			
//			
//			focalLengthSlider = new Slider("horizontal", this, 120, 120, onFocalLengthSlider);
//			focalLengthSlider.minimum = 1;
//			focalLengthSlider.maximum = 3;
//			focalLengthSlider.value = 1;	
//			
//		
//			
//			viewChooser = new ComboBox(this, 5, 140, 'View');
//			viewChooser.addItem('Home');
//			viewChooser.addItem('Debate Overlay');
//			viewChooser.addItem('Pick Stance');	
//			viewChooser.addItem('SMS Prompt');
//			viewChooser.addItem('Photo Booth');
//			viewChooser.addItem('Name Entry');
//			viewChooser.addItem('Verify Opinion');
//			viewChooser.addItem('Edit Opinion');	
//			viewChooser.addItem('Stats Overlay');
//			viewChooser.addItem('Inactivity Overlay');
//			viewChooser.addItem('Submit Overlay');			
//			
//			viewChooser.numVisibleItems = viewChooser.items.length;
//			
//			viewChooser.addEventListener(Event.SELECT, onViewSelect);
//			viewChooser.width = this.width - 10;
//			
//
//			
//			
			
		}
		
		
		private function onEnterFrame(e:Event):void {
			
			wallsaverFrameLabel.text = "Frame Number: " + CivilDebateWall.flashSpan.frameCount;
			frameRateLabel.text = "Frame Rate: " + CivilDebateWall.self.fpsMeter.fps;
			framesRenderedLabel.text = "Frames Rendered: " + framesRendered++;
			
		}
		
		// logs a single line of text to the window
		public function log(s:String):void {
			logBox.text = s + "\n" + logBox.text;
		}
		
		private function onOverlaySlider(e:Event):void {
			Kiosk.testOverlay.alpha = overlaySlider.value;
		}
		
		private function onFocalLengthSlider(e:Event):void {
			CivilDebateWall.kiosk.view.portraitCamera.setFocalLength(focalLengthSlider.value);
		}
		

		
		private function onViewSelect(e:Event):void {
			var selection:String = e.target.selectedItem;

			if (selection == 'Home') CivilDebateWall.kiosk.view.homeView();
			if (selection == 'Debate Overlay') CivilDebateWall.kiosk.view.threadView();
			if (selection == 'Photo Booth') CivilDebateWall.kiosk.view.photoBoothView();
			if (selection == 'Stats Overlay') CivilDebateWall.kiosk.view.statsView();
			if (selection == 'Inactivity Overlay') CivilDebateWall.kiosk.view.inactivityOverlayView();			
		}
		
		
	}
}