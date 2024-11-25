local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local thresholds = {
	-- default color green will be returned if count is less than the first threshold
	[3] = colors.yellow,
	[5] = colors.orange,
	[10] = colors.red,
}

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	drawing = "off",
	icon = {
		string = icons.brew.empty,
		color = colors.green,
		align = "left",
	},
	label = {
		string = "0",
		font = { family = settings.font.numbers },
	},
	updates = "on",
	update_freq = 10,
})

brew:subscribe({ "routine", "brew_update" }, function()
	sbar.exec("brew outdated | wc -l | tr -d ' '", function(brew_outdated)
		local function getThresholdColor(count)
			local thresholdKeys = {}
			for key in pairs(thresholds) do
				table.insert(thresholdKeys, key)
			end

			table.sort(thresholdKeys, function(a, b)
				return a > b
			end)

			for _, threshold in ipairs(thresholdKeys) do
				if tonumber(count) >= threshold then
					return thresholds[threshold]
				end
			end
			return colors.green
		end

		local icon = icons.brew.empty
		local color = colors.green
		local label = "0"
		local count = brew_outdated
		local drawing = "off"

		if tonumber(count) > 0 then
			icon = icons.brew.full
			label = count
			color = getThresholdColor(count)
			drawing = "on"
		end
		--print("color: ", color, "count: ", count, "icon: ", icon, "label: ", label, "drawing: ", drawing)
		brew:set({
			icon = {
				string = icon,
				color = color,
			},
			drawing = drawing,
			label = { string = label },
		})
	end)
end)

sbar.add("bracket", "widgets.brew.bracket", { brew.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.brew.padding", {
	position = "right",
	width = settings.group_paddings,
})
