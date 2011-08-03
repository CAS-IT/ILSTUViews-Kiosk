package net.localprojects.keyboard {
	
	import com.adobe.utils.StringUtil;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.text.TextField;
	
	import net.localprojects.CDW;
	import net.localprojects.blocks.BlockBase;
	import net.localprojects.Assets;
	
	
	public class Keyboard extends BlockBase {
		
	
		private var keys:Array;
		private var shift:Boolean;
		private var marginTopBottom:Number = 40;
		private var marginLeftRight:Number = 140;
		public var target:InteractiveObject;	
		
		
		public function Keyboard() {
			super();
			
			// background
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0, 0, 1080, 358);
			this.graphics.endFill();
			
			
			shift = false;
			
			// extra white space describes how many multiples of the keywidth it should be
			var layout:Array = [
//				['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-'],
//				['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
//				['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
//				['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.'],
//				[' SHIFT ', '   SPACE   ', ' DELETE ']
					['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
					['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
					['z', 'x', 'c', 'v', 'b', 'n', 'm'],
					[' SHIFT ', '   SPACE   ', ' DELETE ']				
			];

			keys = [];
			
			// find key width, it's the width of the keyboard divided by the longest row of keys
			var keyWidth:Number = (width - (marginLeftRight * 2)) / maxLength(layout);
			
			// key height is the height of the keyboard divided by the number of rows 
			var keyHeight:Number = (height  - (marginTopBottom * 2)) / layout.length;			
			
			// make the keys
			for (var row:int = 0; row < layout.length; row++) {
				var xPos:Number = (width - (getRowGridCount(layout[row]) * keyWidth)) / 2;
				
				//if (row == 3) xPos += (keyWidth / 2);
				
				for (var col:int = 0; col < layout[row].length; col++) {
					var letter:String = layout[row][col];
					var widthFactor:int = getWidthFactor(letter);
					var key:Key = new Key(letter, keyWidth * widthFactor, keyHeight);
					
					key.x = xPos;
					
					key.y = marginTopBottom + row * keyHeight;
					
					trace(key.y);
					
					// accuumulate width
					xPos += key.width;
					
					// events inside the key
					key.addEventListener(MouseEvent.MOUSE_DOWN, key.onMouseDown);
					key.addEventListener(MouseEvent.MOUSE_UP, key.onMouseUp);
					key.addEventListener(MouseEvent.MOUSE_OVER, key.onMouseOver);
					key.addEventListener(MouseEvent.MOUSE_OUT, key.onMouseOut);
					
					// events global to the keyboard
					key.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);					
					key.addEventListener(MouseEvent.MOUSE_UP, onKeyPressed);
										
					
					keys[key.letter] = key;
					
					addChild(key);
				}
			}

			

			
		}
		

		
		
		private function upperCase():void {
			for each (var key:Key in keys) {
				if (key.letter.length == 1 && (key.letter.charCodeAt(0) >= 97) && (key.letter.charCodeAt(0) <= 122)) {
					key.setLetter(key.letter.toUpperCase());
				}
			}
		}
		
		private function lowerCase():void {
			for each (var key:Key in keys) {
				if (key.letter.length == 1 && (key.letter.charCodeAt(0) >= 65) && (key.letter.charCodeAt(0) <= 90)) {
					key.setLetter(key.letter.toLowerCase());
				}
			}			
		}
		
		private function onMouseDown(e:MouseEvent):void {
			// make sure the text ends up where we want it
			stage.focus = target;
		}
		
		
		
		private function onKeyPressed(e:MouseEvent):void {
			
			
			Assets.clickSound.play();
			
			trace(e.target.letter);
			
			if (e.target.letter == 'SHIFT') {
				shift = e.target.active;
				
				if (shift) {
					// switch key caps to uppercase
					upperCase();
				}
				else {
					// back to lowercase
					lowerCase();					
				}
			}
			else if (e.target.letter == 'DELETE') {
				// backspace
				if (this.stage.focus is TextField) {
					var tf:TextField = this.stage.focus as TextField;
					tf.text = tf.text.substring(0, tf.selectionBeginIndex - 1) + tf.text.substring(tf.selectionEndIndex);
					tf.setSelection(tf.selectionBeginIndex - 1, tf.selectionBeginIndex - 1);
				}
			}
			else {
				
				// sending a keyboard event is just ignored by the text input fields
				// via http://www.kirupa.com/forum/showthread.php?312829-Onscreen-Keyboard-how-to-send-event
				if (this.stage.focus is TextField) {
					var tf:TextField = this.stage.focus as TextField;
					tf.text = tf.text.substring(0, tf.selectionBeginIndex) + e.target.letter + tf.text.substring(tf.selectionEndIndex);
					tf.setSelection(tf.selectionBeginIndex + 1, tf.selectionBeginIndex + 1);
				}

				
				// unstick the shift button if we're shifted if we're shifted
				if (shift) {
					keys['SHIFT'].removeEventListener(MouseEvent.MOUSE_UP, onKeyPressed);
					keys['SHIFT'].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, false));
					keys['SHIFT'].addEventListener(MouseEvent.MOUSE_UP, onKeyPressed);
					lowerCase();
				}
			}
		}
		
		// returns the number of 'cells' a row of keys takes up
		// by factoring in larger than average keys
		// multiply by keyWidth to get the full length of the row
		private function getRowGridCount(a:Array):Number {
			var count:int = 0;
			
			for (var i:int = 0; i < a.length; i++) {
				count += getWidthFactor(a[i]);
			}
			
			return count;
		}
		
		private function getWidthFactor(s:String):int {
			var spaceCount:int = 0;
			
			// leading white space
			var left:int = 0;
			while (s.charAt(left) == ' ') {
				spaceCount++;
				left++;
			}
			
			// trailing white space
			var right:int = s.length - 1;
			while (s.charAt(right) == ' ') {
				spaceCount++;
				right--;
			}
			
			if (spaceCount == 0) spaceCount = 1;
			
			return spaceCount;
		}
		
		
		// recursively finds length of the longest array, regardless of how deeply it's nested
		private function maxLength(a:Array, currentMax:int = 0):int {
			currentMax = Math.max(currentMax, a.length);
			
			for (var i:int = 0; i < a.length; i++) {
				if (a[i] is Array) {
					currentMax = Math.max(currentMax, maxLength(a[i], currentMax));
				}
			}
			
			return currentMax;
		}
		
	}
}