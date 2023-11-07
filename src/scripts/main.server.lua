-- Services
local Selection = game:GetService("Selection");

-- Vars
local RootFolder = script.Parent;
local MainFrame = RootFolder.MainFrame;

local RAIL_TAG = "GrindRail";
local ORIGIN_COLOR = MainFrame.RootFolderSelector.BackgroundColor3;
local RED = Color3.fromRGB(255, 0, 0);
local GREEN = Color3.fromRGB(0, 255, 0);

-- Logic Vars
local RootFolder : Folder = nil;
local SelectedItems = {};

local Toolbar = plugin:CreateToolbar("Rail Formatter");

local PluginButton = Toolbar:CreateButton("Launch Formatter", "", "rbxassetid://11598218220");

local DockWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, --From what side gui appears
	false, 
	false, 
	200, --default width
	300, --default height
	150, --minimum width 
	150 --minimum height 
);

local Widget = plugin:CreateDockWidgetPluginGui("RailFormatter", DockWidgetInfo);
Widget.Title = "Rail Formatter V1.0";
MainFrame.Parent = Widget;

MainFrame.RootFolderSelector.Button.MouseButton1Click:Connect(function() 
	local Selected = Selection:Get();
	if (not Selected[1]:IsA("Folder")) then warn("Selected Instance has to be a Folder"); MainFrame.RootFolderSelector.BackgroundColor3 = RED; return nil; end
	RootFolder = Selected[1];
	MainFrame.RootFolderSelector.Button.Text = Selected[1].Name;
	MainFrame.RootFolderSelector.BackgroundColor3 = GREEN;
end)

MainFrame.RootFolderSelector.Button.MouseButton2Click:Connect(function()
	RootFolder = nil;
	MainFrame.RootFolderSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.RootFolderSelector.Button.Text = "Select Root Folder";
end)

MainFrame.ItemSelector.Button.MouseButton1Click:Connect(function() 
	local Selected = Selection:Get();
	for _, instance in ipairs(Selected) do
		if (not instance:HasTag(RAIL_TAG)) then 
			warn("One of the selected Parts is not Tagged a GrindRail");
			MainFrame.ItemSelector.BackgroundColor3 = RED;
			return nil;
		end
		if (not instance:IsA("Part")) then
			warn("One of the selected Parts is not a Part");
			MainFrame.ItemSelector.BackgroundColor3 = RED;
			return nil;
		end
		table.insert(SelectedItems, instance);
	end 
	MainFrame.ItemSelector.Button.Text = "<Instance>";
	MainFrame.ItemSelector.BackgroundColor3 = GREEN;
end)

MainFrame.ItemSelector.Button.MouseButton2Click:Connect(function() 
	SelectedItems = nil;
	MainFrame.ItemSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.ItemSelector.Button.Text = "Select Rail Instances";
end)

MainFrame.RunSelector.Button.MouseButton1Click:Connect(function() 
	local index = 0;
	for _, instance in ipairs(RootFolder:GetChildren()) do
		if tonumber(instance.Name) and tonumber(instance.Name) > index then index = tonumber(instance.Name) end
	end 
	for _, instance in ipairs(SelectedItems) do
		index += 1;
		instance.Name = tostring(index);
		instance.Parent = RootFolder;
	end
end)
	

PluginButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled;
end)