package com.civildebatewall.kiosk.elements {
	import com.civildebatewall.CivilDebateWall;
	
	import flash.events.MouseEvent;
	
	public class EditNameOrOpinionButton extends WhiteButton {
		
		public function EditNameOrOpinionButton(params:Object=null)	{
			super({
				text: "EDIT NAME OR OPINION",
				width: 389,
				height: 64
			});
			
			onButtonUp.push(onUp);
		}
		
		private function onUp(e:MouseEvent):void {
			CivilDebateWall.state.setView(CivilDebateWall.kiosk.view.opinionEntryView);
		}
	}
}