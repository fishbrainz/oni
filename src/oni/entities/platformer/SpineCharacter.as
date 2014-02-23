package oni.entities.platformer 
{
	import spine.Event;
	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.animation.AnimationStateData;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.starling.StarlingTextureLoader;
	import spine.starling.SkeletonAnimation;
	import spine.starling.StarlingAtlasAttachmentLoader;
	import oni.assets.AssetManager;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class SpineCharacter extends Character
	{
		protected var _skeleton:SkeletonAnimation;
		
		public function SpineCharacter(params:Object) 
		{
			//Super
			super(params);
			
			//Get the texture atlas and the skeleton json for the character
			var atlas:TextureAtlas = AssetManager.getTextureAtlas("character_" + params.skeleton);
			var json:SkeletonJson = new SkeletonJson(new StarlingAtlasAttachmentLoader(atlas));
			
			//Read the skeleton data
			var skeletonData:SkeletonData = json.readSkeletonData(AssetManager.getAsset("character_" + params.skeleton + "Skeleton"));
	
			//Load the animation state data, set mixes
			var stateData:AnimationStateData = new AnimationStateData(skeletonData);
			_setMixes(stateData);
			
			//Finally, create a skeleton with the data we have
			_skeleton = new SkeletonAnimation(skeletonData, stateData);
			_skeleton.scaleX = _skeleton.scaleY = 0.5;
			_skeleton.x = _params.bodyWidth / 2;
			_skeleton.y = _params.bodyHeight + 2;
			addChild(_skeleton);
			
			//Add the skeleton to the juggler
			Starling.juggler.add(_skeleton);
		}
		
		protected function _setMixes(stateData:AnimationStateData):void
		{
			//Idle breath
			stateData.setMixByName("idle_breath", "run", 0.25);
			stateData.setMixByName("idle_breath", "jump", 0.1);
			
			//Run
			stateData.setMixByName("run", "idle_breath", 0.25);
			stateData.setMixByName("run", "jump", 0);
			
			//Jump
			stateData.setMixByName("jump", "idle_breath", 0);
			stateData.setMixByName("jump", "run", 0);
		}
		
		override public function move(direction:int):void 
		{
			//Check if different
			if (canMove && direction != _moveDirection)
			{
				//Flip based on direction
				_skeleton.scaleX = 0.5 * direction;
				
				//Set running animation, if we're not in mid-air
				if (!isJumping)
				{
					_skeleton.state.setAnimationByName(0, "run", true);
				}
				
				//Super
				super.move(direction);
			}
		}
		
		override public function stop():void 
		{
			if (isMoving)
			{
				//Super
				super.stop();
				
				//Play idle animation
				_skeleton.state.setAnimationByName(0, "idle_breath", true);
			}
		}
			
		override public function jump():void 
		{
			//Only jump if we're on the ground
			if (canJump)
			{
				//Super
				super.jump();
				
				//Play jump animation
				_skeleton.state.setAnimationByName(0, "jump", false);
			}
		}
		
	}

}