package com.civildebatewall.data {
	import com.adobe.serialization.json.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.*;
	
	import sekati.layout.Arrange;
	import sekati.utils.ColorUtil;
	import com.civildebatewall.CDW;
	import com.civildebatewall.Utilities;
	
	public class Database extends EventDispatcher {
		
		
		public var question:Question;
		public var users:Array;
		public var threads:Array;
		public var posts:Array;
		public var stats:Object;
		
		public var smsNumber:String;
		
			
		public function Database() {
			super();
		}
		
		public function load():void {
			// load the question
			question = null;
			users = [];
			threads = [];
			posts = [];
			stats = {};			
			smsNumber = '';
			
			
			trace('Loading from DB');
			trace('Loading question');
			Utilities.getRequestJSON(CDW.settings.serverPath + '/api/sms/kiosk' + CDW.settings.kioskNumber, onPhoneNumberReceived); // TODO no need, grab it when we check the recents on SMS prompt page?
		}
		
		private function onPhoneNumberReceived(r:Object):void {
			trace('Got phone number, loading users');
			smsNumber = r['number'];
			trace('sms number: ' + smsNumber);
			Utilities.getRequestJSON(CDW.settings.serverPath + '/api/questions/current', onQuestionReceived);			
		}
		
		private function onQuestionReceived(r:Object):void {
			trace('Question Loaded, getting users');
			
			// Store the question
			question = new Question(r);
		
			// Get users
			Utilities.getRequestJSON(CDW.settings.serverPath + '/api/users', onUsersReceived);			
		}
		
		
		public var photoQueue:LoaderMax = new LoaderMax({name:"portraitQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
			
		private function onUsersReceived(jsonUserObjects:Object):void {
			for each (var jsonUserObject:Object in jsonUserObjects) {
				users.push(new User(jsonUserObject));
			}
			
			photoQueue.load();
		}
			
		private function progressHandler(event:LoaderEvent):void {
			trace("progress: " + event.target.progress);
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}		
		
		private function completeHandler(event:LoaderEvent):void {
			trace(event.target + " is complete!");
			trace("loading threads");
			Utilities.getRequestJSON(CDW.settings.serverPath + '/api/questions/' + question.id + '/threads', onThreadsReceived);
		}
		
		public var postQueue:LoaderMax = new LoaderMax({name:"postQueue", onProgress:progressHandler, onComplete:onPostsLoaded, onError:errorHandler});		
		
		private function onThreadsReceived(r:Object):void {
			for each (var jsonThread:Object in r) {
				threads.push(new Thread(jsonThread));
			}
			
			postQueue.load();
		}
		
		private function onPostsLoaded(event:LoaderEvent):void {
			trace("posts loaded");

			// TODO STATS, client or server side?
			// Utilities.postRequestJSON(CDW.settings.serverPath + '/api/stats/get', {'question': '4e2755b50f2e420354000001'}, onStatsReceived);
			stats = {}
			
			// that's everything
			// now sort by date
			
			
			trace('question',question);
			trace('users',users);
			trace('threads',threads);
			trace('posts',posts);				
				
			// ready to start
			// this.dispatchEvent(new Event(Event.COMPLETE));
		}		
		
		
		
		
		
		
		
		

		
		
//
//		
//		// STUBS
//		public function getQuestionText():String {
//			return question['question'];
//		}
//		
//		public function getActivePortrait():Bitmap {
//			return getDebateAuthorPortrait(CDW.state.activeDebate);
//		}
//		
//		public function getDebateAuthor(debateID:String):String {
//			return debates[debateID]['author']['_id']['$oid'];
//		}
//		
//		public function getDebateAuthorPortrait(debateID:String):Bitmap {
//			return portraits[getDebateAuthor(debateID)]; 
//		}
//		
//		public function getPortrait(authorID:String):Bitmap {
//			return portraits[authorID]; 
//		}		
//		
//		public function getDebateAuthorName(debateID:String):String {
//			return Utilities.toTitleCase(debates[debateID]['author']['firstName']); 
//		}		
//		
//		public function getOpinion(debateID:String):String {
//			return debates[debateID]['opinion'];
//		}
//		
//		public function getStance(debateID:String):String {
//			return debates[debateID]['stance'];
//		}
//		
//		public function getDebateCount():int {
//			var i:int = 0;
//			for (var debateID:String in debates) {
//				i++;
//			}
//			return i;
//		}
//		
//		public function getCommentCount(debateID:String):int {
//			var i:int = 0;
//			
//			for (var commentID:String in debates[debateID]['comments']) {
//				trace('comment ID: ' + commentID);
//				i++;
//			}
//			return i;
//		}		
//		
//		
//		public function cloneDebateAuthorPortrait(debateID:String):Bitmap {
//			return new MetaBitmap(portraits[getDebateAuthor(debateID)].bitmapData.clone());
//		}
//		
//		// returns list of IDs of most debated posts
//		public function getMostDebatedList():Array {
//			var mostDebated:Array = [];
//			
//			for each (var row:Object in stats['mostDebatedOpinions']) {
//				mostDebated.push(row['id']);
//			}
//			
//			return mostDebated;
//		}
//		
//		// returns list of IDs of most debated posts
//		public function getMostLikedList():Array {
//			var mostLiked:Array = [];
//			
//			for each (var row:Object in stats['mostLikedDebates']) {
//				mostLiked.push(row['id']);
//			}
//			
//			return mostLiked;
//		}		
//		
//		
//		public function getNextDebate():String {
//			var grabNext:Boolean;
//			
//			// walk the object
//			for (var debateID:String in debates) {
//				
//				if (grabNext) {
//					return debateID;
//				}
//				
//				if (debateID == CDW.state.activeDebate) {
//					grabNext = true;
//				}
//			}
//			
//			return null;
//		}		
//		
//		public function getPreviousDebate():String {
//			var lastID:String = null;
//			
//			// walk the object
//			for (var debateID:String in debates) {
//				if (debateID == CDW.state.activeDebate) {
//					return lastID;
//				}
//				else {
//					lastID = debateID;
//				}
//			}
//			
//			return null;
//		}
//		
		
		// NEW STUFF
		
		public function getUserByID(id:String):User {
			for each (var user:User in users) {
				if (user.id == id) return user;
			}
			return null;
			// todo else raise error
		}
		
	}
}