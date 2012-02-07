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

package com.civildebatewall.kiosk.elements.question_text {
	
	public class QuestionHeaderHome extends QuestionHeaderBase {
		
		public function QuestionHeaderHome() {
			super();
			
			// this is the big home question
			setParams({
				width: 1080,
				height: 313,
				textSize: 39,
				leading: 29,
				paddingTop: 65,
				paddingRight: 100,
				paddingBottom: 65,
				paddingLeft: 100,
				lineWidth: 982,
				backgroundAlpha: 0.85
			});

			drawLines();
		}
		
	}
}
