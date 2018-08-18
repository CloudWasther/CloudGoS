if myHero.charName ~= "Blitzcrank" then return end -- Hero

--Local

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

local function GetDistanceSqr(p1, p2)
    local p2 = p2 or myHero
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx * dx + dz * dz
end

local function GetDistance(p1, p2)
    local squaredDistance = GetDistanceSqr(p1, p2)
    return math.sqrt(squaredDistance)
end

local function count_enemies_in_range(targetPos, range) -- ty Kornis Thank you for allowing your code
	local enemies_in_range = {}
    for i = 1, Game.HeroCount() do
        local enemy = Game.Hero(i)
		if targetPos:DistanceTo(myHero.pos) < range then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

--Class
class "CloudBT"

function TargetSelectionCurrent(range) -- API (RMAN)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function CloudBT:Loading()
    --Load Menu
    self:LoadingMenu()
    self:SpellPronto()
    --Load Game
    Callback.Add("Tick", function() self:OnPressTick() end)
    Callback.Add("Draw", function() self:OnDraw() end)
end 

function CloudBT:SpellPronto()
    Q = { range = 925, delay = 0.25, Radius = 70, speed = 1800, width = 70, Collision = true, aoe = false, type = "linear" }
end 

function CloudBT:OnPressTick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() or MyAttacking() then return end

    if self.MenuBT.CBK.CKey:Value() then
        ComboBlitz()
    end 
end 

function CloudBT:ComboBlitz()
    local QCombo = TargetSelectionCurrent(910)
    local WCombo = TargetSelectionCurrent(800)
    local ECombo = TargetSelectionCurrent(270)
    local QPrediction = QCombo:GetPrediction(1800, 0.25)
    for i, target in ipairs(self:GetEnemyHeroes()) do
        if target ~= 0 then
            if self:Pronto(_Q) --[[and IsValidTarget(target, 910)]] then
                if self.MenuBT.CBB.CQ:Value() and QCombo and QCombo:GetCollision(70, 1800, 0.25) == 0 then
                    local WT = {}
                    for i  = 1, Game.HeroCount() do
                        local IsEnd = Game.Hero(i)
                        if IsEnd and self.MenuBT.List[IsEnd.charName] and self.MenuBT.List[IsEnd.charName]:Value() then
                            WT[IsEnd.charName] = true
                        end
                    end
                   if IsValidTarget(QCombo, 910) and WT[QCombo.charName] and  QCombo:GetCollision(70, 1800, 0.25) == 0 then
                        Control.CastSpell(HK_Q, QPrediction)
                    end 
                end 
            end 
            if self:Pronto(_W) and IsValidTarget(WCombo, 800) and self:Pronto(_Q) then
                if self.MenuBT.CBB.CW:Value() then
                    Control.CastSpell(HK_W)
                end 
            end 
            if self:Pronto(_E) and IsValidTarget(ECombo, 270) then
                Control.CastSpell(HK_E, ECombo)
                Control.Attack(ECombo)
            end 
            if self:Pronto(_R) and IsValidTarget(target, 600) then
                if #count_enemies_in_range(target, 600) <= self.MenuBT.CBB.CountEnty:Value() then
                    Control.CastSpell(HK_R)
                end 
            end 
        end 
    end 
end 

function CloudBT:OnDraw()
    if self:Pronto(_Q) and self.MenuBT.CBD.DQ:Value() then 
        Draw.Circle(myHero.pos, 950, 3,  Draw.Color(255,255,255,255)) 
    end
    if self:Pronto(_R) and self.MenuBT.CBD.DR:Value() then 
        Draw.Circle(myHero.pos, 600, 3,  Draw.Color(255,0,0,255)) 
    end
    for i, hero in pairs(self:GetEnemyHeroes()) do
        if hero ~= 0 then
            if self:Pronto(_Q) and IsValidTarget(hero, 950) then
                Draw.Circle(hero.pos, 150, 3,  Draw.Color(255,0,255,255)) 
            end 
        end 
    end
end 

function CloudBT:GetPriority(charName)
    local p1 = {"Alistar", "Amumu", "Bard", "Blitzcrank", "Braum", "Chogath", "Dr Mundo", "Garen", "Gnar", "Hecarim", "Janna", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nami", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Sona", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Zyra"}
    local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax", "Lee Sin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Kayn"}
    local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean"}
    local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka", "Xayah", "Zoe"}
    if table.contains(p1, charName) then 
        return 1 
    end
    if table.contains(p2, charName) then 
        return 2
    end
    if table.contains(p3, charName) then 
        return 3 
    end
    return table.contains(p4, charName) and 4 or 1
end

function CloudBT:GetEnemyHeroes()
	self.Inimigos = {}
	for s = 1, Game.HeroCount() do
		local Hero = Game.Hero(s)
		if Hero.isEnemy then
			table.insert(self.Inimigos, Hero)
		end
	end
	return self.Inimigos
end

function CloudBT:LoadingMenu()
    --Elemento:
    self.MenuBT = MenuElement({type = MENU, id = "Clouding Blitzcrank", name = Scriptname}) -- Type, ID For name, Name.
    --Combo:
	self.MenuBT:MenuElement({id = "CBB", name = "Combo", type = MENU})
	self.MenuBT.CBB:MenuElement({id = "CQ", name = "Use [Q]", value = true})
	self.MenuBT.CBB:MenuElement({id = "CW", name = "Use [W]", value = true})
    self.MenuBT.CBB:MenuElement({id = "CE", name = "Use [E]", value = true})
    self.MenuBT.CBB:MenuElement({id = "CEB", name = "Use [E] Buff Rocket Grab", value = true})
    self.MenuBT.CBB:MenuElement({id = "CR", name = "Use [R]", value = true})
    self.MenuBT.CBB:MenuElement({id = "CountEnty", name = "Count Enemies In Range", value = 2, min = 1, max = 5, step = 5 })
    --Draw?
    self.MenuBT:MenuElement({id = "CBD", name = "Drawings", type = MENU}) --whiteList 
    self.MenuBT.CBD:MenuElement({id = "DQ", name = "Use Draw [Q]", value = true})
    self.MenuBT.CBD:MenuElement({id = "DR", name = "Use Draw [R]", value = true})
    --Keys
    self.MenuBT:MenuElement({id = "CBK", name = "Keys", type = MENU})
    self.MenuBT.CBK:MenuElement({id = "CKey", name = "KeyCombo", key = string.byte(" ")})
    --Ls
    self.MenuBT:MenuElement({id = "List", name = "WhiteList", type = MENU})
    for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isEnemy then
			self.MenuBT.List:MenuElement({id = hero.charName, name = hero.charName, value = true })
		end
	end
end 

--Variaveis para o script:
function IsValidTarget(unit, range)
    local range = range or math.huge
    local distance = GetDistance(unit)
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and distance <= range
end

function IsRecalling()
	for i = 1, myHero.buffCount do 
		local buff = myHero:GetBuff(i)
		if buff.name == "recall" and buff.duration > 0 then
			return true
		end
	end
	return false
end

function MyAttacking()
    if myHero.attackData and myHero.attackData.target and myHero.attackData.state == STATE_WINDUP then 
        return true 
    end
	return false
end

function table.contains(t, what, member)
    for i, v in pairs(t) do
        if member and v[member] == what or v == what then 
            return i, v 
        end
    end
end

function CloudBT:Pronto(sp)
	return Game.CanUseSpell(sp) == 0
end

--Funcion
function OnLoad()
	CloudBT()
end



