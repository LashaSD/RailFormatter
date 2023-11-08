-- Services
local Selection = game:GetService("Selection");

-- Vars
local RootFolder = script.Parent;
local MainFrame = RootFolder.MainFrame;

-- Constants
local RAIL_TAG = "GrindRail";

local ORIGIN_COLOR = MainFrame.RootFolderSelector.BackgroundColor3;
local RED = Color3.fromRGB(255, 0, 0);
local GREEN = Color3.fromRGB(0, 255, 0);

local ORIGIN_FOLDER_TEXT = "Root Folder";
local ORIGIN_ITEMS_TEXT = "Rail Instances";

local MAX_DISTANCE_BETWEEN_BOUND_RAILS = 3;

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
	if (not Selected[1]:IsA("Folder")) then 
		warn("Selected Instance has to be a Folder");
		MainFrame.RootFolderSelector.BackgroundColor3 = RED;
		return nil;
	end
	RootFolder = Selected[1];
	MainFrame.RootFolderSelector.Button.Text = Selected[1].Name;
	MainFrame.RootFolderSelector.BackgroundColor3 = GREEN;
end)

MainFrame.RootFolderSelector.Button.MouseButton2Click:Connect(function()
	MainFrame.RootFolderSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.RootFolderSelector.Button.Text = ORIGIN_FOLDER_TEXT;
	RootFolder = nil;
end)

MainFrame.ItemSelector.Button.MouseButton1Click:Connect(function() 
	local Selected = Selection:Get();
	for _, instance in ipairs(Selected) do
		if (instance:HasTag(RAIL_TAG) and instance:IsA("Part")) then
			table.insert(SelectedItems, instance);
			continue;
		end

		if (not instance:HasTag(RAIL_TAG)) then 
			warn("One of the selected Parts is not Tagged a GrindRail");
		end
		if (not instance:IsA("Part")) then
			warn("One of the selected Parts is not a Part");
		end

		MainFrame.ItemSelector.Button.Text = ORIGIN_ITEMS_TEXT;
		MainFrame.ItemSelector.BackgroundColor3 = RED;
		return nil;
	end 
	MainFrame.ItemSelector.Button.Text = "<Instances>";
	MainFrame.ItemSelector.BackgroundColor3 = GREEN;
end)

MainFrame.ItemSelector.Button.MouseButton2Click:Connect(function() 
	SelectedItems = {};
	MainFrame.ItemSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.ItemSelector.Button.Text = ORIGIN_ITEMS_TEXT;
end)

MainFrame.RunSelector.RunButton.MouseButton1Click:Connect(function() 
	local index : number = 0;
	for _, instance in ipairs(RootFolder:GetChildren()) do
		if (table.find(SelectedItems, instance) ~= nil) then continue end
		if (tonumber(instance.Name) and tonumber(instance.Name) > index) then index = tonumber(instance.Name) end
	end 
	for _, instance in ipairs(SelectedItems) do
		index += 1;
		local name = tostring(index);
		if (index < 10) then
			name = "00"..index;
		elseif (index < 100) then
			name = "0"..index;
		end
		instance.Name = name;
		instance.Parent = RootFolder;
	end
	SelectedItems = {};
	MainFrame.ItemSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.ItemSelector.Button.Text = ORIGIN_ITEMS_TEXT;
	RootFolder = nil;
	MainFrame.RootFolderSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.RootFolderSelector.Button.Text = ORIGIN_FOLDER_TEXT;
end)

-- Run But Break apart Rails that are not close to eachother
MainFrame.RunSelector.RunFolderButton.MouseButton1Click:Connect(function()
	if (not RootFolder) then return nil; end
	local InstanceIndex : number = 1;
	local FolderIndex : number = 1;
	local CurrentFolder = Instance.new("Folder", RootFolder);
	CurrentFolder.Name = tostring(FolderIndex);
	FolderIndex += 1;
	for i, instance in ipairs(SelectedItems) do
		-- Give Name To the Instance
		local name = tostring(InstanceIndex);
		if (InstanceIndex < 10) then
			name = "00"..InstanceIndex;
		elseif (InstanceIndex < 100) then
			name = "0"..InstanceIndex;
		end
		instance.Name = name;
		instance.Parent = CurrentFolder;
		InstanceIndex += 1;
		-- Check Distance and Generate Folders Accordingly
		local EndPosition : CFrame = instance.CFrame * CFrame.new(instance.Size.X / -2, 0, 0)
		local StartPosition : CFrame;
		if (SelectedItems[i+1]) then
			StartPosition = SelectedItems[i+1].CFrame * CFrame.new(SelectedItems[i+1].Size.X / 2, 0, 0);
			local diff = (StartPosition.Position - EndPosition.Position).Magnitude
			if (diff >= MAX_DISTANCE_BETWEEN_BOUND_RAILS) then
				CurrentFolder = Instance.new("Folder", RootFolder);
				CurrentFolder.Name = tostring(FolderIndex);
				FolderIndex += 1;
				InstanceIndex = 1;
			end
		end 
	end
	SelectedItems = {};
	MainFrame.ItemSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.ItemSelector.Button.Text = ORIGIN_ITEMS_TEXT;
	RootFolder = nil;
	MainFrame.RootFolderSelector.BackgroundColor3 = ORIGIN_COLOR;
	MainFrame.RootFolderSelector.Button.Text = ORIGIN_FOLDER_TEXT;
end)

MainFrame.RunSelector.AddDefaultSubfoldersButton.MouseButton1Click:Connect(function() 
	if (not RootFolder) then return nil; end
	for i = 1, 3 do
		local Folder = Instance.new("Folder", RootFolder);
		Folder.Name = tostring(i);
	end
end)
	

PluginButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled;
end)