-- ===== SERVICES =====
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")

local player = Players.LocalPlayer
local HWID = Analytics:GetClientId()

-- ===== SUPABASE CONFIG =====
local SUPABASE_URL = "https://tdcteuwqvdkaqxclrtlf.supabase.co/rest/v1/keys"
local SUPABASE_KEY = "sb_publishable_IfCkMf8pXtHoCVhovuOjbA_OI-E0UL8"

-- ===== ENTER KEY HERE (replace with UI later) =====
local USER_KEY = getgenv().KEY or "PUT-KEY-HERE"

-- ===== REQUEST FUNCTION =====
local function request(method, url, body)
	return HttpService:RequestAsync({
		Url = url,
		Method = method,
		Headers = {
			["apikey"] = SUPABASE_KEY,
			["Authorization"] = "Bearer " .. SUPABASE_KEY,
			["Content-Type"] = "application/json",
		},
		Body = body and HttpService:JSONEncode(body) or nil
	})
end

-- ===== VALIDATE KEY =====
local function validateKey(key)
	local res = request("GET", SUPABASE_URL .. "?key=eq." .. key)
	if not res.Success then return false end

	local data = HttpService:JSONDecode(res.Body)[1]
	if not data or not data.active then return false end

	-- Bind HWID on first use
	if not data.hwid or data.hwid == "" then
		request("PATCH", SUPABASE_URL .. "?key=eq." .. key, {
			hwid = HWID
		})
		return true
	end

	return data.hwid == HWID
end

-- ===== RUN =====
if not validateKey(USER_KEY) then
	player:Kick("Invalid or expired key.")
	return
end

-- ===== LOAD YOUR PRIVATE HUB =====
loadstring(game:HttpGet("https://raw.githubusercontent.com/chatgptdemon/chatgptaimbotdogshit/refs/heads/main/pedophile.lua"))()
