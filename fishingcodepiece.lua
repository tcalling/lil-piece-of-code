local rod = script.Parent
local startedthrow = false
local repstor = game:GetService("ReplicatedStorage")
local baitthrowevent = repstor.BaitThrowEvent
local minigameevent = repstor.FishMinigameEvent
local tweenservice = game:GetService("TweenService")


local neededlist


local inventoryevent = repstor.TurnOffEvent

local playergui

local debounce = false
---------------------------------------------SetVariables

local catchefish = false

--------------------------------------------------------


script.Parent.Equipped:Connect(function()
	script.BaitThrowScript.Enabled = true
end)


script.Parent.Unequipped:Connect(function()
	script.BaitThrowScript.Enabled = false
end)
-----------------------------------------------------------Activation
script.Parent.Activated:Connect(function()
	if startedthrow == false and debounce == false then
		print("Throwing Fishing Rod")





		startedthrow = true
		debounce = true
		catchefish = false

		local humanoid = script.Parent.Parent.Humanoid
		humanoid.WalkSpeed = 0
		humanoid.AutoRotate = false

		local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
		playergui = player.PlayerGui
		----------------------------
		local enable = false
		inventoryevent:FireClient(player,enable)
        ----------------------------------------
		script.Parent.Parent.HumanoidRootPart.Anchored = true
		------------------------------------------------
		local animthrow = script.ThrowAnim
		
		local animtrack = humanoid:LoadAnimation(animthrow) --------------------ThrowAnimPlay
		
		animtrack:Play()
		------------------------------------------- 
		script.Parent.Bait.WeldConstraint:Destroy()
		local ropeconst = Instance.new("RopeConstraint",script.Parent.MetalCtch)




		ropeconst.Visible = true
		ropeconst.Attachment0 = script.Parent.MetalCtch.Attachment0 ------------SetAttachmentsRope
		ropeconst.Attachment1 = script.Parent.Bait.Attachment




		animtrack.Stopped:Wait()
		script.Parent.Bait.Anchored = true
		baitthrowevent:FireClient(player) ------------------FireServer

		baitthrowevent.OnServerEvent:Connect(function(player,mousehit)-------------FireServerBack
			print("Bait Throw Event Fired")
			if script.Parent.Parent.Name == player.Name then
				print(player,"IS PLAYER WHO CASTED AND IT SHALL WORK ONLY FOR HIM")
				script.throw:Play()
				script.Parent.Bait.reel:Play()



				local tweenpos = mousehit -----------------SetMousePos
				ropeconst.Length = 40



				local tweenrod = tweenservice:Create(script.Parent.Bait,TweenInfo.new(1),{Position = tweenpos}) ------TweenPos
				script.Parent.Bait.Orientation = Vector3.new(0, -90, 0)
				tweenrod:Play()	
				
				task.wait(1.2)
				
				sendraycast(mousehit,ropeconst)
				print("stopped tween")
				if ropeconst.CurrentDistance >= 90  then --------------CheckRopeDistMax
					script.Enabled = false
					task.wait(0.1)
					print("too much")

					local fallanim = script.FallAnim
					local falltrack = humanoid:LoadAnimation(fallanim)

					local sound = game.ReplicatedStorage.stumble:Clone()
					sound.Parent = humanoid.Parent.Head
					sound:Play()

					falltrack:Play() ------------PlayFallAnim
					returnrod()
					falltrack.Stopped:Wait()
					script.Enabled = true
				end
			end


			--------------------------------------------------------------------------- throw

		end)
		task.wait(1)

		script.Parent.Bait.reel:Stop()
		script.Parent.Bait.AttachmentEffect.ParticleEmitter.Enabled = true ------EFFECT

		task.wait(0.5)

		debounce = false

		if catchefish == false then ------------------------CheckCatch
			while wait(5) do
				local catchmoment = math.random(1,2)

				if catchmoment == 1 and catchefish == false then
					catchefish = true
					print("Catching fish")

					local fishmodule = require(game.ServerScriptService.FishModuleScript)
					local fishlist1 = require(game.ServerScriptService.FishModuleScript.FishLists)

					if player.Character.LocationValue.Value == "Summer" then
						print("changed fishlist to summer")
						neededlist = fishlist1.v1
					elseif player.Character.LocationValue.Value == "Snow" or player.Character.LocationValue.Value == "Void" then
						local text = playergui.TipGui:FindFirstChild("Txt")
						local tweenframe = tweenservice:Create(text,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true),{TextTransparency = 0})
						tweenframe:Play()
						text.Text = "This fishing rod is too weak to catch anything here..."
						returnrodwill()
						return
					end

					local randomfish = fishmodule.GetRandomFish(neededlist) 
					minigameevent:FireClient(player,script.Parent.Bait,script.Parent.Parent.HumanoidRootPart,randomfish)
					print(player,"started catching")
					
					debounce = true
					
					minigameevent.OnServerEvent:Connect(function(player)
						print(player,"caught the fish")
						
						debounce = false
						
						if script.Parent.Parent.Name == player.Name then
							print("PLAYER IS TRUE")
							returnrodwill()

							if player.Character.LocationValue.Value == "Summer" then
								print("giving summer fish")

								for i,v in pairs(game.ReplicatedStorage.fishesloc1:GetDescendants()) do
									if v.Name == randomfish and v:IsA("Tool") then
										print("tool found giving to char")
										local clonedfish = v:Clone()
										clonedfish.Parent = player.Backpack
									end
								end
							end
						end
					end)
				end
			end
		end

		-------------------------------------






	elseif startedthrow == true and debounce == false then ---------------------SECOND ACTIVATION
		returnrodwill()
	end

end)

-----------------------------------------------------------

function returnrod() ---------RETURNROD1
	print("Retracting Fishing Rod")
	startedthrow = false
	
	script.Parent.Bait.AttachmentEffect.ParticleEmitter.Enabled = false
	
	----------------------------------------------------------
	local humanoid = script.Parent.Parent.Humanoid
	local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	local enable = true
	------yeah kind bad decision,but the game was made in a week so i was js panicking
	
	inventoryevent:FireClient(player,enable)
	
	humanoid.WalkSpeed = 16
	humanoid.AutoRotate = true
	
	script.Parent.Parent.HumanoidRootPart.Anchored = false
	------------------------------------------------------
	local anim = script.PullAnim
	local animtrack = humanoid:LoadAnimation(anim)
	
	animtrack:Play()
	script.pull:Play()
	
	--------------------------------------------------RodAttachmentsAdjusting
	script.Parent.MetalCtch.RopeConstraint:Destroy()
	script.Parent.Bait.CanCollide = false
	script.Parent.Bait.Anchored = false
	script.Parent.Bait.Position = script.Parent.MetalCtch.Position
	---------------------------------------------------------------
	local weldback = Instance.new("WeldConstraint",script.Parent.Bait)
	weldback.Part0 = script.Parent.Bait
	weldback.Part1 = script.Parent.MetalCtch
	-----------------------------------------------------------------

end


function sendraycast(mouse,rope)
	local rayOrigin = script.Parent.Parent.Head.Position
	local rayDirection = (mouse - rayOrigin).Unit * 100 

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {script.Parent.Parent} 
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude 

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local hitPart = raycastResult.Instance
		print(rope.CurrentDistance)
		if hitPart.Name ~= "WaterCube" or rope.CurrentDistance <= 30 then
			print(hitPart)
			print("not water cube")
			local text = playergui.TipGui:FindFirstChild("Txt")
			local tweenframe = tweenservice:Create(text,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true),{TextTransparency = 0})
			tweenframe:Play()
			text.Text = "Too Close/Not Water!"
			returnrodwill()
		end
	end
end



function returnrodwill() ------------RETURNROD2
	print("Retracting Fishing Rod")
	startedthrow = false
	script.Parent.Bait.AttachmentEffect.ParticleEmitter.Enabled = false
	
	local humanoid = script.Parent.Parent.Humanoid
	local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	local enable = true
	
	inventoryevent:FireClient(player,enable)
	humanoid.WalkSpeed = 16
	humanoid.AutoRotate = true
	script.Parent.Parent.HumanoidRootPart.Anchored = false
	------------------------------------------------------
	local anim = script.PullAnim
	local animtrack = humanoid:LoadAnimation(anim)
	
	animtrack:Play()
	script.pull:Play()
	--------------------------------------------------
	script.Parent.MetalCtch.RopeConstraint:Destroy()
	script.Parent.Bait.CanCollide = false
	script.Parent.Bait.Anchored = false
	script.Parent.Bait.Position = script.Parent.MetalCtch.Position
	---------------------------------------------------------------
	local weldback = Instance.new("WeldConstraint",script.Parent.Bait)
	weldback.Part0 = script.Parent.Bait
	weldback.Part1 = script.Parent.MetalCtch
	-----------------------------------------------------------------
	script.Enabled = false
	task.wait(0.1)
	script.Enabled = true
end

---------------Lol, not really proud of those two functions, could do better