-- This is temporary until we get a proper way to build stylesheets directly
-- from a file that isn't Luau.

type Rule = {
	Priority: number?,
	[string | number]: any,
}

type StylesheetDoc = {
	-- rule:
	Name: string?,
	DeriveFromBase: boolean?,
	Derive: { [StyleSheet]: number }?,
	-- if key starts with $, assume token
	-- otherwise, is a rule
	[string]: any,
}

local TOKEN_CHAR = "$"
local START_WITH_LETTER = "^(%a)"

local baseStyleSheet: StyleSheet

local function makeRule(selector: string, rule: Rule): StyleRule
	local setPropsTable = {}
	-- we need to find non-standard children before creating the main prop table
	-- these are any that start with a special char, or "Priority"

	local ruleObj = Instance.new("StyleRule")
	ruleObj.Name = selector
	ruleObj.Selector = selector
	ruleObj.Priority = rule.Priority or 0
	rule.Priority = nil

	for prop, def in rule do
		if string.match(prop, START_WITH_LETTER) then
			setPropsTable[prop] = def
		else
			makeRule(prop, def).Parent = ruleObj
		end
	end

	ruleObj:SetProperties(setPropsTable)
	return ruleObj
end

local function isToken(name: string): boolean
	return string.sub(name, 1, 1) == TOKEN_CHAR
end

local function getStyleSheetFromModule(m: ModuleScript | StyleSheet): StyleSheet
	if m:IsA("StyleSheet") then return m end

	local style = require(m)
	if typeof(style) ~= "Instance" or not style:IsA("StyleSheet") then
		error(`Module {m} does not return a StyleSheet`)
	end

	return style
end

local function makeStyleSheet(t: StylesheetDoc): StyleSheet
	local sheet = Instance.new("StyleSheet")
	sheet.Archivable = false
	sheet.Name = t.Name
	t.Name = nil

	if t.DeriveFromBase then
		local derive = Instance.new("StyleDerive")
		derive.Archivable = false
		derive.StyleSheet = baseStyleSheet
		derive.Name = "BaseDerive"
		derive.Parent = sheet
	end
	t.DeriveFromBase = nil

	if t.Derive then
		for derive, priority in t.Derive do
			local styleDerive = Instance.new("StyleDerive")
			styleDerive.Name = `->{derive.Name}`
			styleDerive.Priority = priority
			styleDerive.StyleSheet = getStyleSheetFromModule(derive)
			styleDerive.Archivable = false
			styleDerive.Parent = sheet
		end
	end
	t.Derive = nil

	-- unlike descendent rules, which have a defined shape, because tokens exist, we need to handle these a bit differently
	for k, def in t do
		if isToken(k) then
			sheet:SetAttribute(string.sub(k, 2), def)
		else
			makeRule(k, def).Parent = sheet
		end
	end

	sheet.Parent = script
	return sheet
end

baseStyleSheet = makeStyleSheet {
	Name = "BaseStyleSheet",
	DeriveFromBase = false,

	CanvasGroup = {
		Priority = 9,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
	},

	Frame = {
		Priority = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
	},

	ImageButton = {
		Priority = 5,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		Size = UDim2.fromOffset(100, 100),
	},

	ImageLabel = {
		Priority = 5,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		Size = UDim2.fromOffset(100, 100),
	},

	ScrollingFrame = {
		Priority = 1,
		Active = true,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromOffset(100, 100),
	},

	TextBox = {
		Priority = 4,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.fromEnum(Enum.Font.SourceSans),
		Size = UDim2.fromOffset(200, 50),
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
	},

	TextButton = {
		Priority = 3,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.fromEnum(Enum.Font.SourceSans),
		Size = UDim2.fromOffset(200, 50),
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
	},

	TextLabel = {
		Priority = 2,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.fromEnum(Enum.Font.SourceSans),
		Size = UDim2.fromOffset(200, 50),
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
	},

	UIGridLayout = {
		Priority = 11,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	UIListLayout = {
		Priority = 10,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	UIPageLayout = {
		Priority = 12,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	UITableLayout = {
		Priority = 13,
		SortOrder = Enum.SortOrder.LayoutOrder,
	},

	VideoFrame = {
		Priority = 8,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
	},

	ViewportFrame = {
		Priority = 7,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
	},
}

return {
	new = makeStyleSheet,
	getStyleSheetFromModule = getStyleSheetFromModule,
}
