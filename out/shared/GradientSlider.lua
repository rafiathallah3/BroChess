-- dispeller 2020
-- Open Sourced Get On Gradient Slider module/function

local GradientSlider = {}
local UserInputService = game:GetService('UserInputService')

local selecting = false

function GradientSlider.getColor(percentage, ColorKeyPoints)
	if (percentage < 0) or (percentage>1) then
		--error'getColor percentage out of bounds!'
		warn'getColor got out of bounds percentage (less than 0 or greater than 1'
	end
	
	local closestToLeft = ColorKeyPoints[1]
	local closestToRight = ColorKeyPoints[#ColorKeyPoints]
	local LocalPercentage = .5
	local color = closestToLeft.Value
	
	-- This loop can probably be improved by doing something like a Binary search instead
	-- This should work fine though
	for i=1,#ColorKeyPoints-1 do
		if (ColorKeyPoints[i].Time <= percentage) and (ColorKeyPoints[i+1].Time >= percentage) then
			closestToLeft = ColorKeyPoints[i]
			closestToRight = ColorKeyPoints[i+1]
			LocalPercentage = (percentage-closestToLeft.Time)/(closestToRight.Time-closestToLeft.Time)
			color = closestToLeft.Value:lerp(closestToRight.Value,LocalPercentage)
			print(typeof(ColorKeyPoints[1]))
			return color
		end
	end
	warn('Color not found!')
	return color
end

function GradientSlider.RGBToColor(ColorShower : Frame, RGBFrame, together : boolean, onEnterPress : boolean, toUpdateOnChange : boolean?)
	local function setColor(frame)
		local color
		if(together) then --If to change color using all RGB values
			color = {}
			for _, colorFrame in pairs(RGBFrame:GetChildren()) do
				if(colorFrame:IsA("Frame")) then
					color[colorFrame.Name] = tonumber(colorFrame:WaitForChild("ValueBox").Text) --Store all RGB values in the table
				end
			end	
		else --To change only one aspect of the current color
			local originalColor = ColorShower.BackgroundColor3
			color = {
				R = originalColor.R*255;
				G = originalColor.G*255;
				B = originalColor.B*255;
			}
			color[frame.Name] = tonumber(frame:WaitForChild("ValueBox").Text) --Change the one axis/aspect of the color
		end

		ColorShower.BackgroundColor3 = Color3.fromRGB(color.R, color.G, color.B) --Set the color
	end

	for _, colorFrame in pairs(RGBFrame:GetChildren()) do
		if(colorFrame:IsA("Frame")) then
			if(onEnterPress) then
				colorFrame:WaitForChild("ValueBox").FocusLost:Connect(function()
					setColor(colorFrame)
				end)
			else
				colorFrame:WaitForChild("ValueBox"):GetPropertyChangedSignal("Text"):Connect(function()
					setColor(colorFrame)
				end)
			end
		end
	end

	if(toUpdateOnChange == true or toUpdateOnChange == nil) then
		ColorShower:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() --When the color shower changes, update the RGB values
			RGBFrame:WaitForChild("R"):WaitForChild("ValueBox").Text = math.floor(ColorShower.BackgroundColor3.R*255)
			RGBFrame:WaitForChild("G"):WaitForChild("ValueBox").Text = math.floor(ColorShower.BackgroundColor3.G*255)
			RGBFrame:WaitForChild("B"):WaitForChild("ValueBox").Text = math.floor(ColorShower.BackgroundColor3.B*255)
		end)
	end
end

function GradientSlider.beginSelection(MainFrame, axis, frameToUpdate : Frame?, otherAxis, FrameYangInginDitunjukkan: Frame?)	

	local ColorShower = MainFrame:FindFirstChild("ColorShower") or frameToUpdate.ColorShower
	local PickerArea = MainFrame.ColorPickerArea
	local Picker = PickerArea.Picker
	local Gradient = PickerArea:FindFirstChildOfClass('UIGradient')

	selecting = true
	local ColorKeyPoints = Gradient.Color.Keypoints

	repeat task.wait()
		-- left cord of ColorPickerArea in pixels
		local minPos = PickerArea.AbsolutePosition[axis]

		-- right cord of ColorPickerArea in pixels
		local maxPos = minPos+PickerArea.AbsoluteSize[axis]

		-- width of ColorPickerArea in pixels
		local PixelSize = PickerArea.AbsoluteSize[axis]

		-- raw Mouse X/Y pixel position
		local mouse = UserInputService:GetMouseLocation()[axis] - (axis=="Y" and 36 or 0)

		-- constraints
		if mouse<minPos then
			mouse = minPos
		elseif mouse > maxPos then
			mouse = maxPos
		end

		-- get percentage mouse is on
		local Pos = (mouse-minPos)/PixelSize

		-- move the visual Picker line
		if(axis == "X") then
			Picker.Position = UDim2.new(Pos,0,0,0)
		elseif(axis == "Y") then
			Picker.Position = UDim2.new(0,0,Pos,0)
		else
			warn("No such axis!")
		end

		-- set the ColorShower frame color
		ColorShower.BackgroundColor3 = GradientSlider.getColor(Pos,ColorKeyPoints)
		if(FrameYangInginDitunjukkan) then
			FrameYangInginDitunjukkan.BackgroundColor3 = GradientSlider.getColor(Pos, ColorKeyPoints);
		end

		if(frameToUpdate) then --If the current color change is supposed to influence a different frame:
			local Area = frameToUpdate:WaitForChild("ColorPickerArea")
			local Grad : UIGradient = Area:FindFirstChildOfClass('UIGradient')
			local colors = Grad.Color.Keypoints
			colors[2] = ColorSequenceKeypoint.new(colors[2].Time,ColorShower.BackgroundColor3)
			Grad.Color = ColorSequence.new(colors) --Change the color pallete of the second frame

			local color = GradientSlider.getColor(Area:WaitForChild("Picker").Position[otherAxis].Scale,colors)
			if(frameToUpdate:FindFirstChild("ColorShower")) then
				frameToUpdate:WaitForChild("ColorShower").BackgroundColor3 = color --Update the color shower if its in the other frame
			else
				ColorShower.BackgroundColor3 = color --Update the color shower of this frame
			end
		end

	until not selecting
end

-- upon the user ending selection
function GradientSlider.endSelection()
	-- this will stop the loop
	selecting = false
end

function GradientSlider.enableColorPicker(frame, axis : "Y" | "X" , frameToUpdate : Frame | nil, otherAxis : "Y"? | "X"?)
	frame:WaitForChild("ColorPickerArea").InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			GradientSlider.beginSelection(frame, axis, frameToUpdate, otherAxis)
		end
	end)

	frame:WaitForChild("ColorPickerArea").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			GradientSlider.endSelection()
		end
	end)
end

return GradientSlider;