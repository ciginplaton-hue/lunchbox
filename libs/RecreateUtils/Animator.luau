-- NOTE: This will probably be deprecated when Roblox releases transitions/animations
-- on style sheets.

local Logica = require(script.Parent.Logica)
local TweenService = game:GetService("TweenService")

export type Animation = {
	animctx: {
		playing: boolean,
		time: number,
		max_time: number,
		start: number,
		goal: number,
		easing_style: Enum.EasingStyle,
		easing_direction: Enum.EasingDirection,
		thread: thread?,
	},
	node: Logica.Node<number>,
	set: (Animation, number) -> (),
	get: (Animation) -> number,
	cancel: (Animation) -> (),
}

local function setAnimationGoal(animation: Animation, goal: number)
	local animctx = animation.animctx
	local node = animation.node

	animctx.start = animation.node:get()
	animctx.goal = goal
	animctx.time = 0
	animctx.playing = true

	if not animctx.thread then
		animctx.thread = task.spawn(function()
			repeat
				local delta = math.min(animctx.time / animctx.max_time, 1)
				local interp = math.lerp(
					animctx.start,
					animctx.goal,
					TweenService:GetValue(delta, animctx.easing_style, animctx.easing_direction)
				)

				node:set(interp)
				animctx.time += task.wait()
			until delta >= 1 or not animctx.playing

			animctx.thread = nil
		end)
	end
end

local function stopAnimation(animation: Animation)
	-- we can just kill the thread if its running, no need to reset animctx
	animation.animctx.playing = false
end

return function(time: number, v: number?, style: Enum.EasingStyle?, dir: Enum.EasingDirection?): Animation
	local animator = {} :: Animation
	animator.node = Logica.Node(v or 0)
	animator.animctx = {
		time = time,
		max_time = time,
		start = 0,
		goal = 0,
		easing_style = style or Enum.EasingStyle.Linear,
		easing_direction = dir or Enum.EasingDirection.InOut,
		thread = nil,
	}

	function animator:set(v: number)
		setAnimationGoal(self, v)
	end

	function animator:get(): number
		return self.node:get()
	end

	function animator:cancel()
		stopAnimation(self)
	end

	return animator
end
