local tween_service = game:GetService('TweenService')
local lighting = game:GetService('Lighting')

task.spawn(function()
	while true do
		local tween = tween_service:Create(lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), { ClockTime = (lighting.ClockTime + .1) })

		tween:Play()
		tween.Completed:Wait()
	end
end)