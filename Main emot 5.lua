if getgenv().Invisible_MainLoaded then return end
getgenv().Invisible_MainLoaded = true

local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local player = Players.LocalPlayer

local translations = {
	["pt-br"] = {
		Author = "Feito Por Weliton",
		Invisible = "Invisível",
	},
	["pt-pt"] = {
		Author = "Feito Por Weliton",
		Invisible = "Invisível",
	},
	["en-us"] = {
		Author = "Made By Weliton",
		Invisible = "Invisible",
	},
	["en-gb"] = {
		Author = "Made By Weliton",
		Invisible = "Invisible",
	},
	["es-es"] = {
		Author = "Hecho Por Weliton",
		Invisible = "Invisible",
	},
	["fr-fr"] = {
		Author = "Créé Par Weliton",
		Invisible = "Invisible",
	},
	["de-de"] = {
		Author = "Erstellt Von Weliton",
		Invisible = "Unsichtbar",
	},
	["it-it"] = {
		Author = "Creato Da Weliton",
		Invisible = "Invisibile",
	},
	["ja-jp"] = {
		Author = "Weliton 製",
		Invisible = "透明",
	},
	["ko-kr"] = {
		Author = "Weliton 제작",
		Invisible = "투명",
	},
	["zh-cn"] = {
		Author = "由 Weliton 制作",
		Invisible = "隐身",
	},
	["zh-tw"] = {
		Author = "由 Weliton 製作",
		Invisible = "隱身",
	},
	["ru-ru"] = {
		Author = "Сделано Weliton",
		Invisible = "Невидимый",
	},
	["tr-tr"] = {
		Author = "Weliton Tarafından Yapıldı",
		Invisible = "Görünmez",
	},
	["pl-pl"] = {
		Author = "Wykonane Przez Weliton",
		Invisible = "Niewidzialny",
	},
	["nl-nl"] = {
		Author = "Gemaakt Door Weliton",
		Invisible = "Onzichtbaar",
	},
	["sv-se"] = {
		Author = "Gjord Av Weliton",
		Invisible = "Osynlig",
	},
	["da-dk"] = {
		Author = "Lavet Af Weliton",
		Invisible = "Usynlig",
	},
	["nb-no"] = {
		Author = "Laget Av Weliton",
		Invisible = "Usynlig",
	},
	["fi-fi"] = {
		Author = "Welitonin Tekemä",
		Invisible = "Näkymätön",
	},
	["cs-cz"] = {
		Author = "Vytvořil Weliton",
		Invisible = "Neviditelný",
	},
	["uk-ua"] = {
		Author = "Зроблено Weliton",
		Invisible = "Невидимий",
	},
	["vi-vn"] = {
		Author = "Được Làm Bởi Weliton",
		Invisible = "Vô hình",
	},
	["th-th"] = {
		Author = "สร้างโดย Weliton",
		Invisible = "ล่องหน",
	},
	["id-id"] = {
		Author = "Dibuat Oleh Weliton",
		Invisible = "Tak Terlihat",
	},
}

local function getTranslation()
	local localeId = string.lower(LocalizationService.RobloxLocaleId or "en-us")

	if translations[localeId] then
		return translations[localeId]
	end

	local language = string.sub(localeId, 1, 2)

	for locale, data in pairs(translations) do
		if string.sub(locale, 1, 2) == language then
			return data
		end
	end

	return translations["en-us"]
end

local translation = getTranslation()

local function translateInvisibleGui(gui)
	for _, object in ipairs(gui:GetDescendants()) do
		if object:IsA("TextLabel")
			or object:IsA("TextButton")
			or object:IsA("TextBox") then

			if object.Text == "Invisible" then
				object.Text = translation.Invisible
			end
		end
	end
end

task.spawn(function()
	local gui = player:WaitForChild("PlayerGui")

	if gui:FindFirstChild("InvisibleMessage") then
		return
	end

	local sg = Instance.new("ScreenGui")
	sg.Name = "InvisibleMessage"
	sg.ResetOnSpawn = false
	sg.Parent = gui

	local frame = Instance.new("Frame")
	frame.Parent = sg
	frame.Size = UDim2.new(0, 260, 0, 40)
	frame.Position = UDim2.new(0.5, -130, 0.12, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local text = Instance.new("TextLabel")
	text.Parent = frame
	text.Size = UDim2.new(1, -20, 1, 0)
	text.Position = UDim2.new(0, 10, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = translation.Author
	text.TextColor3 = Color3.fromRGB(0, 0, 0)
	text.Font = Enum.Font.Cartoon
	text.TextScaled = true
	text.TextXAlignment = Enum.TextXAlignment.Center

	task.delay(5, function()
		if sg then
			sg:Destroy()
		end

		if not getgenv().Invisible_LoadstringLoaded then
			getgenv().Invisible_LoadstringLoaded = true

			pcall(function()
				loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))()
			end)

			task.wait(1)

			translateInvisibleGui(gui)

			gui.DescendantAdded:Connect(function(object)
				task.wait()

				if object:IsA("TextLabel")
					or object:IsA("TextButton")
					or object:IsA("TextBox") then

					if object.Text == "Invisible" then
						object.Text = translation.Invisible
					end
				end
			end)
		end
	end)
end)
