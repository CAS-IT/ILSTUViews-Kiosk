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

package com.civildebatewall.kiosk.elements {
	
	
	import com.civildebatewall.Assets;
	import com.civildebatewall.data.containers.Post;
	import com.civildebatewall.kiosk.buttons.DebateThisButton;
	import com.civildebatewall.kiosk.buttons.FlagButton;
	import com.civildebatewall.kiosk.elements.opinion_text.BlockTextOpinion;
	import com.kitschpatrol.futil.blocks.BlockBase;
	import com.kitschpatrol.futil.blocks.BlockText;
	import com.kitschpatrol.futil.constants.Char;
	import com.kitschpatrol.futil.utilitites.BitmapUtil;
	import com.kitschpatrol.futil.utilitites.DateUtil;
	import com.kitschpatrol.futil.utilitites.GraphicsUtil;
	import com.kitschpatrol.futil.utilitites.NumberUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class Comment extends BlockBase {
		
		protected var _post:Post;
		protected var _postNumber:int;
		protected var postNumberString:String;
		
		protected var portraitWidth:int;
		protected var portraitHeight:int;
		protected var portrait:Sprite;
		protected var flagButton:FlagButton;
		
		private var opinion:BlockTextOpinion;
		
		public function Comment(post:Post, postNumber:int = -1) {
			_post = post;
			_postNumber = postNumber;

			portraitWidth = 138;
			portraitHeight = 189;						
			
			super({		
				width: 1024,
				minHeight: 257,
				backgroundAlpha: 0,
				paddingLeft: 30,
				paddingRight: 30,
				paddingTop: 30,
				paddingBottom: 34
			});
			
			draw();
		}
		
		private function draw():void {
			GraphicsUtil.removeChildren(content);

			// draw the portrait
			portrait = new Sprite();
			portrait.graphics.beginBitmapFill(BitmapUtil.scaleDataToFill(_post.user.photo.bitmapData, portraitWidth, portraitHeight), null, false, true);
			portrait.graphics.drawRoundRect(0, 0, portraitWidth, portraitHeight, 5, 5);
			portrait.graphics.endFill();
			
			portrait.graphics.beginFill(_post.stanceColorMedium);
			portrait.graphics.drawRect(0, 132, portraitWidth, 39);
			portrait.graphics.endFill();
			
			var bannerText:Bitmap;
			if (_post.stance == Post.STANCE_YES) {
				bannerText = Assets.getPortraitBannerYes();
				bannerText.x = 39;
				bannerText.y = 141;			
			}
			else {
				bannerText = Assets.getPortraitBannerNo();
				bannerText.x = 44;
				bannerText.y = 140;				
			}
			portrait.addChild(bannerText);
			addChild(portrait);

			// add the number
			var postNumber:BlockText = new BlockText({
				width: 42,
				height: 12,
				showBackground: false,
				textFont: Assets.FONT_BOLD,
				textBold: true,
				textSize: 12,
				textColor: _post.stanceColorLight,				
				leading: 12,
				text: _postNumber.toString() + ".",
				visible: true,
				x: 187,
				y: 17			
			});
			addChild(postNumber);
			
			// add the byline
			var byline:BlockText = new BlockText({
				maxWidth: 350,
				height: 12, 
				backgroundAlpha: 0,
				textFont: Assets.FONT_BOLD,
				textBold: true,
				textSize: 12,
				textColor: _post.stanceColorLight,				
				leading: 12,
				text: _post.user.usernameFormatted.toUpperCase() + Char.APOSTROPHE + "S RESPONSE",
				visible: true,
				x: 218,
				y: 17
			});
			addChild(byline);
			
			
			// date posted
			var timeString:String =  DateUtil.getShortHour(post.created) + ":" + NumberUtil.zeroPad(post.created.minutes, 2) + DateUtil.getAMPM(post.created).toLowerCase();
			var dateString:String =  NumberUtil.zeroPad(post.created.month + 1, 2) + "/" + NumberUtil.zeroPad(post.created.date, 2) + "/" + DateUtil.getShortYear(post.created);
			var timestamp:String = "Posted at " + timeString + " on " + dateString;			
			
			var datePosted:BlockText = new BlockText({
				maxWidth: 222,
				height: 9, 
				backgroundAlpha: 0,
				textFont: Assets.FONT_BOLD_ITALIC,
				// textItalic: true, // TODO doesn't work, font name collision? Edit font?
				textBold: true,
				textSize: 9,
				textColor: _post.stanceColorLight,				
				leading: 12,
				text: timestamp,
				visible: true,
				x: byline.right + 12,
				y: byline.bottom - 9
			});	
			addChild(datePosted);
			
			// add the hairline
			var hairline:Shape = new Shape();
			hairline.graphics.lineStyle(1, _post.stanceColorLight, 0.6, true); // some alpha to make it appear thinner
			hairline.graphics.moveTo(0, 0);
			hairline.graphics.lineTo(664, 0);
			hairline.x = 167;
			hairline.y = 43 ;
			addChild(hairline);			
			
			// flag button
			flagButton = new FlagButton();
			flagButton.targetPost = _post;
			flagButton.x = 802;
			flagButton.y = -1;
			flagButton.visible = true;
			addChild(flagButton);			

			// add the opinion
			opinion = new BlockTextOpinion({
				minWidth: 100,
				maxWidth: 662,
				maxHeight: 500,				
				paddingTop: 17,
				paddingLeft: 21,
				paddingRight: 21,
				paddingBottom: 19,	
				textFont: Assets.FONT_REGULAR,
				textSize: 18,
				textColor: 0xffffff,
				leading: 11,
				text: Char.LEFT_QUOTE + _post.text + Char.RIGHT_QUOTE,
				visible: true,
				backgroundColor: _post.stanceColorLight,
				x: 167,
				y: 61
			});
			addChild(opinion);
			
			// Add the debate me button
			var debateButton:DebateThisButton = new DebateThisButton();
			debateButton.targetPost = _post;
			debateButton.x = 860;
			debateButton.y = 60;
			debateButton.visible = true;
			addChild(debateButton);					
		}
		
		public function get post():Post {
			return _post;
		}
		
		public function set post(p:Post):void {
			_post = p;
			draw();
		}
		
		public function get postNumber():int { 
			return postNumber;
		}
		
		public function set postNumber(number:int):void {
			postNumber = number;
			if (postNumber == -1) {
				postNumberString = "";
			}
			else {
				postNumberString = postNumber.toString() + ".";
			}
		}		

	}
}
