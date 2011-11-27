package com.civildebatewall.staging {
	import com.civildebatewall.CivilDebateWall;
	import com.civildebatewall.State;
	import com.kitschpatrol.futil.blocks.BlockText;
	import com.kitschpatrol.futil.utilitites.StringUtil;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextLineMetrics;
	
	public class BlockTextOpinion extends BlockText	{
	
		private var highlightLayer:Shape;
		private var _highlightColor:uint;
		
		public function BlockTextOpinion(params:Object = null) {
			highlightLayer = new Shape();
			
			
			super(params);
			
			content.addChildAt(highlightLayer, getChildIndex(textField));
			
			
			CivilDebateWall.state.addEventListener(State.ON_HIGHLIGHT_WORD_CHANGE, onHighlightChange);
		}
		
		
		override public function set text(textContent:String):void {
			super.text = textContent;
			// update the highlight
			updateHighlight();
			
		}
		
		override public function update(contentWidth:Number = -1, contentHeight:Number = -1):void {
			super.update(contentWidth, contentHeight);
			drawBackground();
		}
		
		protected function drawBackground():void {
			background.graphics.clear();
			
			if (textField != null) {
				var yPos:Number = 0;			
				for (var i:int = 0; i < textField.numLines; i++) {
					var metrics:TextLineMetrics = textField.getLineMetrics(i);				
					background.graphics.beginFill(backgroundColor); // white fill for manipulation by tweenmax			
					
					if (i == 0 || i == textField.numLines - 1) {
						// first or last line
						background.graphics.drawRect(0, yPos, Math.round(metrics.width - 4) + paddingLeft + paddingRight, textSize + paddingTop + paddingBottom);
					}
					else {
						// middle line
						background.graphics.drawRect(0, yPos + 4, Math.round(metrics.width - 4) + paddingLeft + paddingRight, textSize + paddingTop + paddingBottom - 4);					
					}
					
					background.graphics.endFill();
					yPos += metrics.height;				
				}		
			}
		}
		
		private function onHighlightChange(e:Event):void {
			updateHighlight();
		}
		
		private function updateHighlight():void {
			if (textField != null) {
				clearHighlight();
				
				if (CivilDebateWall.state.highlightWord != null) {
					highlightColor = CivilDebateWall.state.highlightWordColor;
					setHighlight(CivilDebateWall.state.highlightWord);
				}
			}
		}
		
		
		// highlighting
		protected var highlightedString:String = ''; // TODO, no need?
		
		// todo put in padding object
		protected var highlightPaddingTop:Number = 7;
		protected var highlightPaddingBottom:Number = 0; // 9;
		protected var highlightPaddingLeft:Number = 0; // 9;
		protected var highlightPaddingRight:Number = 0; // 9;
		
		
		private function highlightPosition(start:int, end:int):void {
			// add space to end
			var existingText:String = text;
			var highlightArea:Rectangle = new Rectangle();
			
			// left bounds, string up to the highlighted word
			var onLine:int = textField.getLineIndexOfChar(start);
			var theLineText:String = textField.getLineText(onLine);
			var lineLeftIndex:int = textField.getLineOffset(onLine);
			var leftStringExclusive:String = theLineText.substring(0, start - lineLeftIndex);
			super.text =  leftStringExclusive; // call super so we don't trigger the highlight update...
			
			var leftExclusiveMetrics:TextLineMetrics = textField.getLineMetrics(0);			

			highlightArea.x = leftExclusiveMetrics.x + leftExclusiveMetrics.width;
			highlightArea.y = (leftExclusiveMetrics.height * onLine);				
						
			// right bounds, string up to and including the highlighted word
			var leftStringInclusive:String = theLineText.substring(0, end - lineLeftIndex);
			
			super.text =  leftStringInclusive;
			var leftInclusiveMetrics:TextLineMetrics = textField.getLineMetrics(0);
			highlightArea.width = (leftInclusiveMetrics.x + leftInclusiveMetrics.width) - highlightArea.x;
			highlightArea.height = leftInclusiveMetrics.height;						
			
			super.text =  existingText;
			
			// apply padding
			highlightArea.y -= highlightPaddingTop;			
			highlightArea.x -= highlightPaddingLeft;
			highlightArea.width += highlightPaddingLeft + highlightPaddingRight;
			highlightArea.height += highlightPaddingTop + highlightPaddingBottom;
			
			// draw the hilite
			highlightLayer.graphics.beginFill(_highlightColor);
			highlightLayer.graphics.drawRect(highlightArea.x, highlightArea.y, highlightArea.width, highlightArea.height);
			highlightLayer.graphics.endFill();
		}
		
		public function set highlightColor(c:uint):void {
			_highlightColor = c;
			setHighlight(highlightedString);			
		}
		
		public function get highlightColor():uint {
			return _highlightColor;
		}
		
		private function setHighlight(s:String):void {
			
			trace("highlighting " + s);
			
			if (s.length > 0) {
				
				highlightedString = s;
				
				highlightLayer.graphics.clear();

				trace("searching for " + s + " in " + text);
				
				var locations:Array = StringUtil.searchString(s, text);
			
				
				trace("locations: " + locations);
				
				// highlight each one...
				for (var i:int = 0; i < locations.length; i++) {
					highlightPosition(locations[i][0], locations[i][1]);
				}
			}
			else {
				clearHighlight();
			}
		}
		
		private function clearHighlight():void {
			highlightLayer.graphics.clear();
			highlightedString = '';
		}
				
		
		
		
		
		
		
	}
}
