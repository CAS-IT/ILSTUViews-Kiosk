package net.localprojects.elements
{
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import fl.motion.Color;
	
	import flash.display.*;
	
	import net.localprojects.*;
	import net.localprojects.blocks.BlockBase;
	
	public class QuotationMark extends BlockBase	{
		
		public static const OPENING:String = "opening";
		public static const CLOSING:String = "closing";
		private var quotation:Sprite;
		private var color:uint;
		
		public function QuotationMark() {
			init();
		}
		
		public function init():void {
			quotation = Assets.getQuotation();
			addChild(quotation);
			
		}
		
		public var colorTween:TweenMax;

		public function setColor(c:uint, instant:Boolean = false):void {
			color = c;
			var duation:Number = instant ? 0 : 1;
			TweenMax.to(quotation, duation, {colorMatrixFilter: {colorize: color, amount: 1}});
		}
		


		public function setStyle(type:String):void {
			// specify an opening or closing quotation
			// default is "opening"
			
			if (type == OPENING) {
				quotation.x = 0;
				quotation.y = 0;				
				quotation.scaleX = 1;
				quotation.scaleY = 1;				
			}
			else if (type == CLOSING) {
				// compensate for the flip to keep the origin at the top left
				quotation.x = quotation.width;
				quotation.y = quotation.height;				
				quotation.scaleX = -1;
				quotation.scaleY = -1;				
			}
			else {
				trace('Invalid quotation type.');
			}
			
		}

	}
}
