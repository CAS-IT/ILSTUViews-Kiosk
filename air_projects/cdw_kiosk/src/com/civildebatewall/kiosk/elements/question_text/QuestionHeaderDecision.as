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
	
	public class QuestionHeaderDecision extends QuestionHeaderBase {
		
		public function QuestionHeaderDecision () {
			super();

			// This is the smaller decision view question
			setParams({
				width: 880,
				height: 157,
				textSize: 26,
				leading: 18,
				paddingRight: 35,
				paddingLeft: 35,
				lineWidth: 850,
				lineInset: 15,
				lineThickness: 3,
				backgroundAlpha: 1			
			});
			
			drawLines();
		}
		
	}
}
