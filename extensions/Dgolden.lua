--[[
	太阳神三国杀武将扩展包·金装武将
	适用版本：V2 - 终结版（版本号：20150926）
	武将总数：10
	武将一览：
		1、夏侯惇（刚烈）
		2、许褚（裸衣）
		3、张辽（突袭）
		4、刘备（仁德、激将）
		5、张飞（咆哮）
		6、赵云（龙胆）
		7、魏延（狂骨）
		8、黄盖（苦肉）
		9、陆逊（谦逊、连营）
		10、关羽（武神、武魂）
	所需标记：
		1、@gold_ganglie_mark（“烈”标记，来自技能“刚烈”）
		2、@gold_kurou_mark（“引火”标记，来自技能“苦肉”）
		3、@skill_invalidity（“技能失效”标记，来自技能“苦肉”）
		4、@gold_wuhun_mark（“梦魇”标记，来自技能“武魂”）
]]--
module("extensions.Dgolden", package.seeall)
extension = sgs.Package("Dgolden", sgs.Package_GeneralPack)
--翻译信息
sgs.LoadTranslationTable{
	["Dgolden"] = "金装武将",
}
--[[****************************************************************
	编号：GOLD - 001
	称号：独眼的罗刹
	武将：夏侯惇
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
XiaHouDun = sgs.General(extension, "gold_xiahoudun", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["gold_xiahoudun"] = "金装·夏侯惇",
	["&gold_xiahoudun"] = "夏侯惇",
	["#gold_xiahoudun"] = "独眼的罗刹",
	["designer:gold_xiahoudun"] = "DGAH",
	["cv:gold_xiahoudun"] = "喵小林",
	["illustrator:gold_xiahoudun"] = "KayaK",
	["~gold_xiahoudun"] = "诸多败绩，有负丞相重托……",
}
--[[
	技能：刚烈
	描述：你每受到1点伤害，你可以选择一项：1、获得一枚“烈”标记；2、弃置伤害来源两张牌。一名角色的回合结束时，若你有“烈”标记，你可以弃置所有“烈”标记，对其造成等量的伤害。
]]--
GangLie = sgs.CreateTriggerSkill{
	name = "gold_ganglie",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			if player:hasSkill("gold_ganglie") then
				local damage = data:toDamage()
				local target = damage.from
				for i=1, damage.damage, 1 do
					local choices = {"mark"}
					if target and target:isAlive() and player:canDiscard(target, "he") then
						table.insert(choices, "discard")
					end
					table.insert(choices, "cancel")
					choices = table.concat(choices, "+")
					local choice = room:askForChoice(player, "gold_ganglie", choices, data)
					if choice == "cancel" then
						return false
					elseif choice == "mark" then
						room:broadcastSkillInvoke("gold_ganglie", 1)
						room:notifySkillInvoked(player, "gold_ganglie")
						player:gainMark("@gold_ganglie_mark", 1)
					elseif choice == "discard" then
						local id = room:askForCardChosen(player, target, "he", "gold_ganglie", false, sgs.Card_MethodDiscard)
						if id > 0 then
							room:broadcastSkillInvoke("gold_ganglie", 2)
							room:notifySkillInvoked(player, "gold_ganglie")
							room:throwCard(id, target, player)
							if player:canDiscard(target, "he") then
								id = room:askForCardChosen(player, target, "he", "gold_ganglie", false, sgs.Card_MethodDiscard)
								if id > 0 then
									room:throwCard(id, target, player)
								end
							end
						end
					end
					if player:isDead() then
						return false
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if p:hasSkill("gold_ganglie") then
						local marks = p:getMark("@gold_ganglie_mark")
						if marks > 0 then
							if p:askForSkillInvoke("gold_ganglie", data) then
								room:broadcastSkillInvoke("gold_ganglie", 3)
								room:notifySkillInvoked(p, "gold_ganglie")
								p:loseAllMarks("@gold_ganglie_mark")
								local damage = sgs.DamageStruct()
								damage.from = p
								damage.to = player
								damage.damage = marks
								room:damage(damage)
								if player:isDead() then
									return false
								end
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
XiaHouDun:addSkill(GangLie)
--翻译信息
sgs.LoadTranslationTable{
	["gold_ganglie"] = "刚烈",
	[":gold_ganglie"] = "你每受到1点伤害，你可以选择一项：1、获得一枚“烈”标记；2、弃置伤害来源两张牌。一名角色的回合结束时，若你有“烈”标记，你可以弃置所有“烈”标记，对其造成等量的伤害。",
	["$gold_ganglie1"] = "独目苍狼，虽伤亦勇！",
	["$gold_ganglie2"] = "汝等凶逆，岂欲往生乎？！",
	["$gold_ganglie3"] = "夺目之恨犹在，今必斩汝！",
	["gold_ganglie:mark"] = "获得一枚“烈”标记",
	["gold_ganglie:discard"] = "弃置伤害来源两张牌",
	["gold_ganglie:cancel"] = "不发动“刚烈”",
	["@gold_ganglie_mark"] = "烈",
}
--[[****************************************************************
	编号：GOLD - 002
	称号：虎痴
	武将：许褚
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
XuChu = sgs.General(extension, "gold_xuchu", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["gold_xuchu"] = "金装·许褚",
	["&gold_xuchu"] = "许褚",
	["#gold_xuchu"] = "虎痴",
	["designer:gold_xuchu"] = "DGAH",
	["cv:gold_xuchu"] = "官方",
	["illustrator:gold_xuchu"] = "KayaK",
	["~gold_xuchu"] = "丞相！末将尽力了……",
}
--[[
	技能：裸衣
	描述：以你为来源的伤害结算开始时，你可以弃置一张装备牌，令此伤害+1；你可以将一张非基本牌当做【杀】打出。
]]--
LuoYiVS = sgs.CreateViewAsSkill{
	name = "gold_luoyi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
			slash:addSubcard(card)
			slash:setSkillName("gold_luoyi")
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if pattern == "slash" then
			local reason = sgs.Sanguosha:getCurrentCardUseReason()
			if reason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
				return true
			end
		end
		return false
	end,
}
LuoYi = sgs.CreateTriggerSkill{
	name = "gold_luoyi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageForseen},
	view_as_skill = LuoYiVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and source:hasSkill("gold_luoyi") then
			if source:canDiscard(source, "he") then
				local pattern = "EquipCard|.|.|."
				local prompt = string.format("@gold_luoyi:%s:", player:objectName())
				local room = player:getRoom()
				if room:askForCard(source, pattern, prompt, data, sgs.Card_MethodDiscard, nil, false, "gold_luoyi") then
					room:broadcastSkillInvoke("gold_luoyi") --播放配音
					room:notifySkillInvoked(source, "gold_luoyi") --显示技能发动
					local msg = sgs.LogMessage()
					msg.type = "#gold_luoyi_buff"
					msg.from = source
					msg.to:append(player)
					local count = damage.damage
					msg.arg = count
					count = count + 1
					msg.arg2 = count
					room:sendLog(msg) --发送提示信息
					damage.damage = count
					data:setValue(damage)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
XuChu:addSkill(LuoYi)
--翻译信息
sgs.LoadTranslationTable{
	["gold_luoyi"] = "裸衣",
	[":gold_luoyi"] = "以你为来源的伤害结算开始时，你可以弃置一张装备牌，令此伤害+1；你可以将一张非基本牌当做【杀】打出。",
	["$gold_luoyi"] = "废话少说，放马过来吧！",
	["@gold_luoyi"] = "裸衣：你可以弃一张装备牌令 %src 受到的本次伤害+1",
	["#gold_luoyi_buff"] = "%from 发动了技能“<font color=\"yellow\"><b>裸衣</b></font>”，对 %to 造成的伤害+1，由 %arg 点上升至 %arg2 点",
}
--[[****************************************************************
	编号：GOLD - 003
	称号：前将军
	武将：张辽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ZhangLiao = sgs.General(extension, "gold_zhangliao", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["gold_zhangliao"] = "金装·张辽",
	["&gold_zhangliao"] = "张辽",
	["#gold_zhangliao"] = "前将军",
	["designer:gold_zhangliao"] = "DGAH",
	["cv:gold_zhangliao"] = "官方",
	["illustrator:gold_zhangliao"] = "KayaK",
	["~gold_zhangliao"] = "真的没想到……",
}
--[[
	技能：突袭
	描述：摸牌阶段，你可以少摸至少一张牌，然后将等量其他角色的各一张牌置入你的对应区域。
]]--
TuXiCard = sgs.CreateSkillCard{
	name = "gold_tuxi_card",
	skill_name = "gold_tuxi",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local n = sgs.Self:getMark("gold_tuxi_total")
		if #targets < n then
			return not to_select:isNude()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		if target:isNude() then
			return
		elseif source:isAlive() and target:isAlive() then
			local room = source:getRoom()
			local id = room:askForCardChosen(source, target, "he", "gold_tuxi")
			if id >= 0 then
				room:addPlayerMark(source, "gold_tuxi_cost", 1)
				local place = room:getCardPlace(id)
				if place == sgs.Player_PlaceHand then
					room:obtainCard(source, id, false)
				elseif place == sgs.Player_PlaceEquip then
					local equip = sgs.Sanguosha:getCard(id)
					local to_throw = nil
					if equip:isKindOf("Weapon") then
						to_throw = source:getWeapon()
					elseif equip:isKindOf("Armor") then
						to_throw = source:getArmor()
					elseif equip:isKindOf("DefensiveHorse") then
						to_throw = source:getDefensiveHorse()
					elseif equip:isKindOf("OffensiveHorse") then
						to_throw = source:getOffensiveHorse()
					elseif equip:isKindOf("Treasure") then
						to_throw = source:getTreasure()
					end
					if to_throw then
						local throw_id = to_throw:getEffectiveId()
						local throw = sgs.CardsMoveStruct()
						throw.from = source
						throw.to = nil
						throw.from_place = sgs.Player_PlaceEquip
						throw.to_place = sgs.Player_DiscardPile
						throw.card_ids:append(throw_id)
						throw.reason = sgs.CardMoveReason(
							sgs.CardMoveReason_S_REASON_CHANGE_EQUIP, 
							source:objectName(), 
							"gold_tuxi", 
							""
						)
						room:moveCardsAtomic(throw, true)
					end
					local move = sgs.CardsMoveStruct()
					move.from = target
					move.to = source
					move.from_place = sgs.Player_PlaceEquip
					move.to_place = sgs.Player_PlaceEquip
					move.card_ids:append(id)
					move.reason = sgs.CardMoveReason(
						sgs.CardMoveReason_S_REASON_EXTRACTION,
						source:objectName(),
						target:objectName(),
						"gold_tuxi",
						""
					)
					room:moveCardsAtomic(move, true)
				end
			end
		end
	end,
}
TuXiVS = sgs.CreateViewAsSkill{
	name = "gold_tuxi",
	n = 0,
	view_as = function(self, cards)
		return TuXiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@gold_tuxi"
	end,
}
TuXi = sgs.CreateTriggerSkill{
	name = "gold_tuxi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	view_as_skill = TuXiVS,
	on_trigger = function(self, event, player, data)
		local n = data:toInt()
		if n == 0 then
			return false
		end
		local room = player:getRoom()
		room:setPlayerMark(player, "gold_tuxi_total", n)
		local skillcard = room:askForUseCard(player, "@@gold_tuxi", "@gold_tuxi")
		room:setPlayerMark(player, "gold_tuxi_total", 0)
		if skillcard then
			local cost = player:getMark("gold_tuxi_cost")
			if cost == 0 then
				return false
			end
			room:setPlayerMark(player, "gold_tuxi_cost", 0)
			local msg = sgs.LogMessage()
			msg.type = "#gold_tuxi_effect"
			msg.from = player
			msg.arg = "gold_tuxi"
			msg.arg2 = cost
			room:sendLog(msg) --发送提示信息
			data:setValue(n - cost)
		end
		return false
	end,
}
--添加技能
ZhangLiao:addSkill(TuXi)
--翻译信息
sgs.LoadTranslationTable{
	["gold_tuxi"] = "突袭",
	[":gold_tuxi"] = "摸牌阶段，你可以少摸至少一张牌，然后将等量其他角色的各一张牌置入你的对应区域。",
	["$gold_tuxi"] = "没想到吧？",
	["@gold_tuxi"] = "您可以发动技能“突袭”",
	["~gold_tuxi"] = "选择一些目标角色->点击“确定”",
	["#gold_tuxi_effect"] = "%from 发动了“%arg”，少摸了 %arg2 张牌",
}
--[[****************************************************************
	编号：GOLD - 003 - ex
	称号：前将军
	武将：张辽EX
	势力：魏
	性别：男
	体力上限：4勾玉
	说明：由于技能收益上限不可控，强度失衡，因此封禁。
]]--****************************************************************
--[[
ZhangLiaoEx = sgs.General(extension, "gold_zhangliao_ex", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["gold_zhangliao_ex"] = "金装·张辽EX",
	["&gold_zhangliao_ex"] = "张辽",
	["#gold_zhangliao_ex"] = "前将军",
	["designer:gold_zhangliao_ex"] = "DGAH",
	["cv:gold_zhangliao_ex"] = "官方",
	["illustrator:gold_zhangliao_ex"] = "KayaK",
	["~gold_zhangliao_ex"] = "金装·张辽EX 的阵亡台词",
}
]]--
--[[
	技能：突袭
	描述：摸牌阶段，你可以选择一项：1、少摸至少一张牌，然后获得等量其他角色的各一张手牌；2、弃置X张牌并放弃摸牌，然后获得至多X+2名其他角色的各一张手牌（X至少为1）。
]]--
--[[
TuXiExCard = sgs.CreateSkillCard{
	name = "gold_tuxi_ex_card",
	skill_name = "gold_tuxi_ex",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if to_select:isKongcheng() then
			return false
		end
		local n = sgs.Self:getMark("gold_tuxi_ex_count")
		local x = self:subcardsLength()
		return #targets < n + x
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		if source:isDead() or target:isDead() or target:isKongcheng() then
			return
		end
		local room = source:getRoom()
		local id = room:askForCardChosen(source, target, "h", "gold_tuxi_ex")
		if id >= 0 then
			room:addPlayerMark(source, "gold_tuxi_ex_cost", 1)
			room:obtainCard(source, id, false)
		end
	end,
}
TuXiExVS = sgs.CreateViewAsSkill{
	name = "gold_tuxi_ex",
	n = 999,
	view_filter = function(self, selected, to_select)
		return sgs.Self:canDiscard(sgs.Self, to_select:getId())
	end,
	view_as = function(self, cards)
		local card = TuXiExCard:clone()
		if #cards > 0 then
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@gold_tuxi_ex"
	end,
}
TuXiEx = sgs.CreateTriggerSkill{
	name = "gold_tuxi_ex",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	view_as_skill = TuXiExVS,
	on_trigger = function(self, event, player, data)
		local n = data:toInt()
		local room = player:getRoom()
		room:setPlayerMark(player, "gold_tuxi_ex_count", n)
		if room:askForUseCard(player, "@@gold_tuxi_ex", "@gold_tuxi_ex") then
			room:broadcastSkillInvoke("gold_tuxi_ex") --播放配音
			room:notifySkillInvoked(player, "gold_tuxi_ex") --显示技能发动
			cost = player:getMark("gold_tuxi_ex_cost")
			room:setPlayerMark(player, "gold_tuxi_ex_cost", 0)
			local msg = sgs.LogMessage()
			msg.from = player
			msg.arg = "gold_tuxi_ex"
			if cost < n then
				msg.type = "#gold_tuxi_ex_effect"
				msg.arg2 = cost
				data:setValue(n - cost)
			else
				msg.type = "#gold_tuxi_ex_giveup"
				data:setValue(0)
			end
			room:sendLog(msg) --发送提示信息
		end
		room:setPlayerMark(player, "gold_tuxi_ex_count", 0)
		return false
	end,
}
--添加技能
ZhangLiaoEx:addSkill(TuXiEx)
--翻译信息
sgs.LoadTranslationTable{
	["gold_tuxi_ex"] = "突袭",
	[":gold_tuxi_ex"] = "摸牌阶段，你可以选择一项：1、少摸至少一张牌，然后获得等量其他角色的各一张手牌；2、弃置X张牌并放弃摸牌，然后获得至多X+2名其他角色的各一张手牌（X至少为1）。",
	["$gold_tuxi_ex"] = "",
	["@gold_tuxi_ex"] = "您可以发动技能“突袭”",
	["~gold_tuxi_ex"] = "选择一些要弃置的牌（包括装备）->选择一些目标角色->点击“确定”",
	["#gold_tuxi_ex_effect"] = "%from 发动了技能“%arg”，少摸了 %arg2 张牌",
	["#gold_tuxi_ex_giveup"] = "%from 发动了技能“%arg”，放弃了摸牌",
}
]]--
--[[****************************************************************
	编号：GOLD - 004
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
LiuBei = sgs.General(extension, "gold_liubei$", "shu")
--翻译信息
sgs.LoadTranslationTable{
	["gold_liubei"] = "金装·刘备",
	["&gold_liubei"] = "刘备",
	["#gold_liubei"] = "乱世的枭雄",
	["designer:gold_liubei"] = "DGAH",
	["cv:gold_liubei"] = "官方",
	["illustrator:gold_liubei"] = "KayaK",
	["~gold_liubei"] = "这就是……桃园吗？",
}
--[[
	技能：仁德
	描述：出牌阶段，你可以将至少一张牌交给一名其他角色，出牌阶段结束时，若你本阶段内以此法给出的牌数不少于你本阶段内使用的红色牌数，你可以回复1点体力或摸两张牌。
]]--
RenDeCard = sgs.CreateSkillCard{
	name = "gold_rende_card",
	skill_name = "gold_rende",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local count = self:subcardsLength()
		room:addPlayerMark(source, "gold_rende_count", count)
		room:obtainCard(target, self)
	end,
}
RenDeVS = sgs.CreateViewAsSkill{
	name = "gold_rende",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = RenDeCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
}
RenDe = sgs.CreateTriggerSkill{
	name = "gold_rende",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.CardUsed},
	view_as_skill = RenDeVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Play then
		elseif event == sgs.EventPhaseStart then
			room:setPlayerMark(player, "gold_rende_count", 0)
			room:setPlayerMark(player, "gold_rende_times", 0)
		elseif event == sgs.EventPhaseEnd then
			local rende_count = player:getMark("gold_rende_count")
			local use_times = player:getMark("gold_rende_times")
			room:setPlayerMark(player, "gold_rende_count", 0)
			room:setPlayerMark(player, "gold_rende_times", 0)
			if rende_count >= use_times then
				local choices = {}
				if player:getLostHp() > 0 then
					table.insert(choices, "recover")
				end
				table.insert(choices, "draw")
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local choice = room:askForChoice(player, "gold_rende", choices, data)
				if choice == "recover" then
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1
					room:recover(player, recover)
				elseif choice == "draw" then
					room:drawCards(player, 2, "gold_rende")
				end
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			local card = use.card
			if card and card:isRed() and not card:isKindOf("SkillCard") then
				room:addPlayerMark(player, "gold_rende_times", 1)
			end
		end
		return false
	end,
}
--添加技能
LiuBei:addSkill(RenDe)
--翻译信息
sgs.LoadTranslationTable{
	["gold_rende"] = "仁德",
	[":gold_rende"] = "出牌阶段，你可以将至少一张牌交给一名其他角色，出牌阶段结束时，若你本阶段内以此法给出的牌数不少于你本阶段内使用的红色牌数，你可以回复1点体力或摸两张牌。",
	["$gold_rende1"] = "以德服人。",
	["$gold_rende2"] = "惟贤惟德，能服于人。",
	["gold_rende:recover"] = "回复1点体力",
	["gold_rende:draw"] = "摸两张牌",
	["gold_rende:cancel"] = "不发动“仁德”",
}
--[[
	技能：激将（主公技）
	描述：每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。
]]--
--添加技能
LiuBei:addSkill("jijiang")
--翻译信息
sgs.LoadTranslationTable{
	["gold_jijiang"] = "激将",
	[":gold_jijiang"] = "每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。",
	["$gold_jijiang1"] = "蜀将何在？",
	["$gold_jijiang2"] = "尔等敢应战否？",
}
--[[****************************************************************
	编号：GOLD - 005
	称号：万夫不当
	武将：张飞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ZhangFei = sgs.General(extension, "gold_zhangfei", "shu")
--翻译信息
sgs.LoadTranslationTable{
	["gold_zhangfei"] = "金装·张飞",
	["&gold_zhangfei"] = "张飞",
	["#gold_zhangfei"] = "万夫不当",
	["designer:gold_zhangfei"] = "DGAH",
	["cv:gold_zhangfei"] = "官方",
	["illustrator:gold_zhangfei"] = "KayaK",
	["~gold_zhangfei"] = "桃园一拜，此生……无憾！",
}
--[[
	技能：咆哮（锁定技）
	描述：每当你使用或打出一张【杀】后，你翻开牌堆顶的一张牌并获得之；若此为你的出牌阶段且该牌不为红心牌，本阶段你可以额外使用一张【杀】。
]]--
PaoXiao = sgs.CreateTriggerSkill{
	name = "gold_paoxiao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local isPlayPhase = ( player:getPhase() == sgs.Player_Play )
		if event == sgs.EventPhaseStart then
			if isPlayPhase then
				room:setPlayerMark(player, "gold_paoxiao_times", 0)
			end
			return false
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") then
				return false
			end
		elseif event == sgs.CardResponded then
			local response = data:toCardResponse()
			if not response.m_card:isKindOf("Slash") then
				return false
			end
		end
		room:broadcastSkillInvoke("gold_paoxiao") --播放配音
		room:notifySkillInvoked(player, "gold_paoxiao") --显示技能发动
		local id = room:drawCard()
		local move = sgs.CardsMoveStruct()
		move.from = nil
		move.to = player
		move.from_place = sgs.Player_DrawPile
		move.to_place = sgs.Player_PlaceTable
		move.card_ids:append(id)
		move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "gold_paoxiao", "")
		room:moveCardsAtomic(move, true)
		room:getThread():delay()
		local obtain = sgs.CardsMoveStruct()
		obtain.from = player
		obtain.to = player
		obtain.from_place = sgs.Player_PlaceTable
		obtain.to_place = sgs.Player_PlaceHand
		obtain.card_ids:append(id)
		obtain.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, player:objectName(), "gold_paoxiao", "")
		room:moveCardsAtomic(obtain, true)
		if isPlayPhase then
			local card = sgs.Sanguosha:getCard(id)
			if card:getSuit() ~= sgs.Card_Heart then
				room:addPlayerMark(player, "gold_paoxiao_times", 1)
			end
		end
		return false
	end,
}
PaoXiaoMod = sgs.CreateTargetModSkill{
	name = "#gold_paoxiao_mod",
	residue_func = function(self, player, card)
		if card:isKindOf("Slash") then
			return player:getMark("gold_paoxiao_times")
		end
		return 0
	end,
}
extension:insertRelatedSkills("gold_paoxiao", "#gold_paoxiao_mod")
--添加技能
ZhangFei:addSkill(PaoXiao)
ZhangFei:addSkill(PaoXiaoMod)
--翻译信息
sgs.LoadTranslationTable{
	["gold_paoxiao"] = "咆哮",
	[":gold_paoxiao"] = "每当你使用或打出一张【杀】后，你翻开牌堆顶的一张牌并获得之；若此为你的出牌阶段且该牌不为红心牌，本阶段你可以额外使用一张【杀】。",
	["$gold_paoxiao"] = "啊~~~~",
}
--[[****************************************************************
	编号：GOLD - 006
	称号：少年将军
	武将：赵云
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ZhaoYun = sgs.General(extension, "gold_zhaoyun", "shu")
--翻译信息
sgs.LoadTranslationTable{
	["gold_zhaoyun"] = "金装·赵云",
	["&gold_zhaoyun"] = "赵云",
	["#gold_zhaoyun"] = "少年将军",
	["designer:gold_zhaoyun"] = "DGAH",
	["cv:gold_zhaoyun"] = "官方",
	["illustrator:gold_zhaoyun"] = "KayaK",
	["~gold_zhaoyun"] = "你们谁……还敢再上……",
}
--[[
	技能：龙胆
	描述：你或你攻击范围内的一名角色成为【杀】或锦囊牌的目标时，若使用者不为你，你可以弃一张【杀】或【闪】令此牌对该角色无效，然后你获得此牌。
]]--
local function doLongDan(room, source, target, card, data)
	local prompt = string.format("@gold_longdan:%s::%s:", target:objectName(), card:objectName())
	local invoke = room:askForCard(source, "Slash,Jink", prompt, data, sgs.Card_MethodDiscard, nil, false, "gold_longdan")
	if invoke then
		if source:objectName() == target:objectName() then
			room:broadcastSkillInvoke("gold_longdan", 1) --播放配音
		else
			room:broadcastSkillInvoke("gold_longdan", 2) --播放配音
		end
		room:notifySkillInvoked(source, "gold_longdan") --显示技能发动
		room:obtainCard(source, card, true)
		local key = string.format("gold_longdan_avoid_%s", target:objectName())
		card:setTag(key, sgs.QVariant(true))
		return true
	end
	return false
end
LongDan = sgs.CreateTriggerSkill{
	name = "gold_longdan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.CardEffected, sgs.SlashEffected},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			local card = use.card
			if card:isKindOf("Slash") or card:isKindOf("TrickCard") then
				if use.to:contains(player) then
					local alives = room:getAlivePlayers()
					local user = use.from
					for _,source in sgs.qlist(alives) do
						if user and user:objectName() == source:objectName() then
						elseif source:hasSkill("gold_longdan") and source:canDiscard(source, "he") then
							if source:objectName() == player:objectName() or source:inMyAttackRange(player) then
								if doLongDan(room, source, player, card, data) then
									return false
								end
							end
						end
					end
				end
			end
		elseif event == sgs.CardEffected then
			local effect = data:toCardEffect()
			local trick = effect.card
			if trick:isKindOf("TrickCard") then
				local key = string.format("gold_longdan_avoid_%s", player:objectName())
				if trick:getTag(key):toBool() then
					trick:removeTag(key)
					local msg = sgs.LogMessage()
					msg.type = "#gold_longdan_avoid"
					msg.from = player
					msg.arg = "gold_longdan"
					msg.arg2 = trick:objectName()
					room:sendLog(msg) --发送提示信息
					return true
				end
			end
		elseif event == sgs.SlashEffected then
			local effect = data:toSlashEffect()
			local slash = effect.slash
			local key = string.format("gold_longdan_avoid_%s", player:objectName())
			if slash:getTag(key):toBool() then
				slash:removeTag(key)
				local msg = sgs.LogMessage()
				msg.type = "#gold_longdan_avoid"
				msg.from = player
				msg.arg = "gold_longdan"
				msg.arg2 = slash:objectName()
				room:sendLog(msg) --发送提示信息
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
ZhaoYun:addSkill(LongDan)
--翻译信息
sgs.LoadTranslationTable{
	["gold_longdan"] = "龙胆",
	[":gold_longdan"] = "你或你攻击范围内的一名角色成为【杀】或锦囊牌的目标时，若使用者不为你，你可以弃一张【杀】或【闪】令此牌对该角色无效，然后你获得此牌。",
	["$gold_longdan1"] = "能进能退，乃真正法器！",
	["$gold_longdan2"] = "喝！",
	["@gold_longdan"] = "您可以发动“龙胆”弃置一张【杀】或【闪】，令此【%arg】对 %src 无效",
	["#gold_longdan_avoid"] = "受技能“%arg”影响，此【%arg2】对 %from 无效",
}
--[[****************************************************************
	编号：GOLD - 007
	称号：嗜血的独狼
	武将：魏延
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
WeiYan = sgs.General(extension, "gold_weiyan", "shu")
--翻译信息
sgs.LoadTranslationTable{
	["gold_weiyan"] = "金装·魏延",
	["&gold_weiyan"] = "魏延",
	["#gold_weiyan"] = "嗜血的独狼",
	["designer:gold_weiyan"] = "DGAH",
	["cv:gold_weiyan"] = "官方",
	["illustrator:gold_weiyan"] = "KayaK",
	["~gold_weiyan"] = "谁敢杀我？啊……",
}
--[[
	技能：狂骨（锁定技）
	描述：你对一名距离为1以内的角色造成1点伤害后，你选择一项：回复1点体力，或摸两张牌；你计算的与其他角色的距离-X（X为该角色已损失的体力）。
]]--
KuangGu = sgs.CreateTriggerSkill{
	name = "gold_kuanggu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local victim = damage.to
		if victim and player:distanceTo(victim) <= 1 then
			for i=1, damage.damage, 1 do
				local choices = {}
				if player:getLostHp() > 0 then
					table.insert(choices, "recover")
				end
				table.insert(choices, "draw")
				choices = table.concat(choices, "+")
				local room = player:getRoom()
				local choice = room:askForChoice(player, "gold_kuanggu", choices, data)
				room:notifySkillInvoked(player, "gold_kuanggu") --显示技能发动
				if choice == "recover" then
					room:broadcastSkillInvoke("gold_kuanggu", 1) --播放配音
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1
					room:recover(player, recover)
				elseif choice == "draw" then
					room:broadcastSkillInvoke("gold_kuanggu", 2) --播放配音
					room:drawCards(player, 2, "gold_kuanggu")
				end
			end
		end
		return false
	end,
}
KuangGuDist = sgs.CreateDistanceSkill{
	name = "#gold_kuanggu_dist",
	correct_func = function(self, from, to)
		if from:hasSkill("gold_kuanggu") then
			return - to:getLostHp()
		end
		return 0
	end,
}
extension:insertRelatedSkills("gold_kuanggu", "#gold_kuanggu_dist")
--添加技能
WeiYan:addSkill(KuangGu)
WeiYan:addSkill(KuangGuDist)
--翻译信息
sgs.LoadTranslationTable{
	["gold_kuanggu"] = "狂骨",
	[":gold_kuanggu"] = "锁定技。你对一名距离为1以内的角色造成1点伤害后，你选择一项：回复1点体力，或摸两张牌；你计算的与其他角色的距离-X（X为该角色已损失的体力）。",
	["$gold_kuanggu1"] = "真是美味啊！",
	["$gold_kuanggu2"] = "哈哈！",
	["gold_kuanggu:recover"] = "回复1点体力",
	["gold_kuanggu:draw"] = "摸两张牌",
	["#gold_kuanggu_dist"] = "狂骨",
}
--[[****************************************************************
	编号：GOLD - 008
	称号：轻身为国
	武将：黄盖
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
HuangGai = sgs.General(extension, "gold_huanggai", "wu")
--翻译信息
sgs.LoadTranslationTable{
	["gold_huanggai"] = "金装·黄盖",
	["&gold_huanggai"] = "黄盖",
	["#gold_huanggai"] = "轻身为国",
	["designer:gold_huanggai"] = "DGAH",
	["cv:gold_huanggai"] = "官方",
	["illustrator:gold_huanggai"] = "KayaK",
	["~gold_huanggai"] = "盖……有负公瑾重托……",
}
--[[
	技能：苦肉
	描述：出牌阶段，你可以令一名角色对你造成1点伤害。每当你受到一次伤害后，你可以选择一项：1、令你攻击范围内的一名角色所有技能无效直到当前回合结束；2、伤害来源于其回合结束前造成的火焰伤害+1；3、摸两张牌。
]]--
KuRouCard = sgs.CreateSkillCard{
	name = "gold_kurou_card",
	skill_name = "gold_kurou",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	feasible = function(self, targets)
		return true
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1] or source
		local damage = sgs.DamageStruct()
		damage.from = target
		damage.to = source
		damage.damage = 1
		room:damage(damage)
	end,
}
KuRouVS = sgs.CreateViewAsSkill{
	name = "gold_kurou",
	n = 0,
	view_as = function(self, cards)
		return KuRouCard:clone()
	end,
}
KuRou = sgs.CreateTriggerSkill{
	name = "gold_kurou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged, sgs.DamageInflicted, sgs.EventPhaseStart},
	view_as_skill = KuRouVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			if player:isAlive() and player:hasSkill("gold_kurou") then
				local alives = room:getAlivePlayers()
				local targets = sgs.SPlayerList()
				for _,p in sgs.qlist(alives) do
					if player:inMyAttackRange(p) and p:getMark("gold_kurou_effect") == 0 then
						local skills = p:getVisibleSkillList()
						for _,skill in sgs.qlist(skills) do
							if not skill:inherits("SPConvertSkill") then
								targets:append(p)
								break
							end
						end
					end
				end
				local choices = {}
				if not targets:isEmpty() then
					table.insert(choices, "skill")
				end
				local damage = data:toDamage()
				local source = damage.from
				if source and source:isAlive() then
					table.insert(choices, "fire")
				end
				table.insert(choices, "draw")
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local choice = room:askForChoice(player, "gold_kurou", choices, data)
				if choice == "skill" then
					local victim = room:askForPlayerChosen(player, targets, "gold_kurou", "@gold_kurou", true, false)
					if victim then
						room:setPlayerMark(victim, "gold_kurou_effect", 1)
						victim:gainMark("@skill_invalidity", 1)
					end
				elseif choice == "fire" then
					source:gainMark("@gold_kurou_mark", 1)
				elseif choice == "draw" then
					room:drawCards(player, 2, "gold_kurou")
				end
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Fire then
				local source = damage.from
				if source and source:isAlive() then
					local extra = source:getMark("@gold_kurou_mark")
					if extra > 0 then
						local msg = sgs.LogMessage()
						msg.type = "#gold_kurou_buff"
						msg.from = source
						msg.to:append(player)
						local count = damage.damage
						msg.arg = count
						count = count + extra
						msg.arg2 = count
						room:sendLog(msg) --发送提示信息
						damage.damage = count
						data:setValue(damage)
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if p:getMark("gold_kurou_effect") > 0 then
						room:setPlayerMark(p, "gold_kurou_effect", 0)
						p:loseMark("@skill_invalidity", 1)
					end
				end
				player:loseAllMarks("@gold_kurou_mark")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--添加技能
HuangGai:addSkill(KuRou)
--翻译信息
sgs.LoadTranslationTable{
	["gold_kurou"] = "苦肉",
	[":gold_kurou"] = "出牌阶段，你可以令一名角色对你造成1点伤害。每当你受到一次伤害后，你可以选择一项：1、令你攻击范围内的一名角色所有技能无效直到当前回合结束；2、伤害来源的于其回合结束前造成的火焰伤害+1；3、摸两张牌。",
	["$gold_kurou"] = "请鞭挞我吧……公瑾！",
	["gold_kurou:skill"] = "令攻击范围内一名角色技能无效",
	["gold_kurou:fire"] = "令伤害来源造成的所有火焰伤害+1",
	["gold_kurou:draw"] = "自己摸两张牌",
	["gold_kurou:cancel"] = "不发动“苦肉”",
	["@gold_kurou"] = "苦肉：您可以选择一名攻击范围内的角色，令其本回合内所有技能无效",
	["#gold_kurou_buff"] = "受技能“<font color=\"yellow\">苦肉</font>”影响，%from 对 %to 造成的本次火焰伤害由 %arg 点上升至 %arg2 点",
	["@gold_kurou_mark"] = "引火",
	["@skill_invalidity"] = "技能失效",
}
--[[****************************************************************
	编号：GOLD - 009
	称号：儒生雄才
	武将：陆逊
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
LuXun = sgs.General(extension, "gold_luxun", "wu", 3)
--翻译信息
sgs.LoadTranslationTable{
	["gold_luxun"] = "金装·陆逊",
	["&gold_luxun"] = "陆逊",
	["#gold_luxun"] = "儒生雄才",
	["designer:gold_luxun"] = "DGAH",
	["cv:gold_luxun"] = "官方",
	["illustrator:gold_luxun"] = "KayaK",
	["~gold_luxun"] = "我的未竟之业……",
}
--[[
	技能：谦逊（锁定技）
	描述：你不能成为体力不小于你的角色使用的【顺手牵羊】、【乐不思蜀】、【决斗】的目标；你对体力不大于你的目标使用的非延时性锦囊牌不能被【无懈可击】抵消。
]]--
QianXun = sgs.CreateProhibitSkill{
	name = "gold_qianxun",
	is_prohibited = function(self, from, to, card, others)
		if card:isKindOf("Snatch") or card:isKindOf("Indulgence") or card:isKindOf("Duel") then
			if to:hasSkill("gold_qianxun") and from:getHp() >= to:getHp() then
				return true
			end
		end
		return false
	end,
}
QianXunEffect = sgs.CreateTriggerSkill{
	name = "#gold_qianxun_effect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TrickCardCanceling, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		local card = effect.card
		if card and card:isNDTrick() then
			local source = effect.from
			if source and source:hasSkill("gold_qianxun") then
				local target = effect.to
				if target and source:getHp() >= target:getHp() then
					local flag = string.format("%s_%s", source:objectName(), target:objectName())
					if not card:hasFlag(flag) then
						local msg = sgs.LogMessage()
						msg.type = "#gold_qianxun_effect"
						msg.from = source
						msg.to:append(target)
						msg.arg = "gold_qianxun"
						msg.arg2 = card:objectName()
						local room = player:getRoom()
						room:sendLog(msg) --发送提示信息
						room:setCardFlag(card, flag)
					end
					return true
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
extension:insertRelatedSkills("gold_qianxun", "#gold_qianxun_effect")
--添加技能
LuXun:addSkill(QianXun)
LuXun:addSkill(QianXunEffect)
--翻译信息
sgs.LoadTranslationTable{
	["gold_qianxun"] = "谦逊",
	[":gold_qianxun"] = "锁定技。你不能成为体力不小于你的角色使用的【顺手牵羊】、【乐不思蜀】、【决斗】的目标；你对体力不大于你的目标使用的非延时性锦囊牌不能被【无懈可击】抵消。",
	["$gold_qianxun"] = "",
	["#gold_qianxun_effect"] = "%from 的“%arg”被触发，对 %to 使用的此【%arg2】不能被无懈可击抵消",
}
--[[
	技能：连营（阶段技）
	描述：你可以摸两张牌，然后你可以将一张红色手牌当做【火攻】对你攻击范围内的一名角色使用。若此牌造成伤害，你可以对该角色攻击范围内的另一名角色重复此流程。然后你弃两张牌。
]]--
LianYingCard = sgs.CreateSkillCard{
	name = "gold_lianying_card",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:drawCards(source, 2, "gold_lianying")
		room:setPlayerFlag(source, "gold_lianying_center")
		room:askForUseCard(source, "@@gold_lianying", "@gold_lianying:::red:")
		if source:canDiscard(source, "he") then
			local success = room:askForDiscard(source, "gold_lianying", 2, 2, false, true)
			if not success then
				source:forceToDiscard(2, true)
			end
		end
	end,
}
LianYingFireAttack = sgs.CreateSkillCard{
	name = "gold_lianying_trick",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 and not to_select:isKongcheng() then
			local source = sgs.Self
			if not source:hasFlag("gold_lianying_center") then
				local others = sgs.Self:getSiblings()
				for _,p in sgs.qlist(others) do
					if p:hasFlag("gold_lianying_center") then
						source = p
						break
					end
				end
			end
			if source and source:inMyAttackRange(to_select) then
				local id = self:getSubcards():first()
				local card = sgs.Sanguosha:getCard(id)
				local trick = sgs.Sanguosha:cloneCard("fire_attack", card:getSuit(), card:getNumber())
				trick:deleteLater()
				return not sgs.Self:isProhibited(to_select, trick)
			end
		end
		return false
	end,
	on_validate = function(self, use)
		local room = use.from:getRoom()
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:hasFlag("gold_lianying_center") then
				room:setPlayerFlag(p, "-gold_lianying_center")
				break
			end
		end
		local id = self:getSubcards():first()
		local card = sgs.Sanguosha:getCard(id)
		local trick = sgs.Sanguosha:cloneCard("fire_attack", card:getSuit(), card:getNumber())
		trick:addSubcard(id)
		trick:setSkillName("gold_lianying")
		room:setCardFlag(trick, "gold_lianying_trick")
		return trick
	end,
}
LianYingVS = sgs.CreateViewAsSkill{
	name = "gold_lianying",
	n = 1,
	ask = "",
	view_filter = function(self, selected, to_select)
		if ask == "@@gold_lianying" and #selected == 0 then
			if to_select:isRed() and not to_select:isEquipped() then
				return true
			end
		end
		return false
	end,
	view_as = function(self, cards)
		if ask == "" then
			return LianYingCard:clone()
		elseif ask == "@@gold_lianying" then
			if #cards == 1 then
				local card = LianYingFireAttack:clone()
				card:addSubcard(cards[1])
				return card
			end
		end
	end,
	enabled_at_play = function(self, player)
		ask = ""
		return not player:hasUsed("#gold_lianying_card")
	end,
	enabled_at_response = function(self, player, pattern)
		ask = pattern
		return pattern == "@@gold_lianying"
	end,
}
LianYing = sgs.CreateTriggerSkill{
	name = "gold_lianying",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageComplete},
	view_as_skill = LianYingVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local trick = damage.card
		if trick and trick:isKindOf("FireAttack") and trick:hasFlag("gold_lianying_trick") then
			local room = player:getRoom()
			room:setCardFlag(trick, "-gold_lianying_trick")
			local source = damage.from
			if source and source:isAlive() and source:hasSkill("gold_lianying") then
				if source:askForSkillInvoke("gold_lianying", data) then
					room:notifySkillInvoked(source, "gold_lianying") --显示技能发动
					room:drawCards(source, 2, "gold_lianying")
					room:setPlayerFlag(damage.to, "gold_lianying_center")
					room:askForUseCard(source, "@@gold_lianying", "@gold_lianying:::red:")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--添加技能
LuXun:addSkill(LianYing)
--翻译信息
sgs.LoadTranslationTable{
	["gold_lianying"] = "连营",
	[":gold_lianying"] = "阶段技。你可以摸两张牌，然后你可以将一张红色手牌当做【火攻】对你攻击范围内的一名角色使用。若此牌造成伤害，你可以对该角色攻击范围内的另一名角色重复此流程。然后你弃两张牌。",
	["$gold_lianying1"] = "烈焰升腾，万物尽毁！",
	["$gold_lianying2"] = "以火应敌，贼人何处逃窜？",
	["@gold_lianying"] = "连营：您可以将一张 %arg 手牌当做【火攻】对攻击范围内的一名角色使用",
	["~gold_lianying"] = "选择一张红色手牌->选择一名目标角色->点击“确定”",
	["@gold_lianying_ex"] = "连营：您可以对 %src 攻击范围内的另一名角色重复上述流程",
	["gold_lianying_"] = "连营",
}
--[[****************************************************************
	编号：GOLD - 010
	称号：鬼神再临
	武将：关羽
	势力：神
	性别：男
	体力上限：5勾玉
]]--****************************************************************
GuanYu = sgs.General(extension, "gold_guanyu", "god", 5)
--翻译信息
sgs.LoadTranslationTable{
	["gold_guanyu"] = "金装·关羽",
	["&gold_guanyu"] = "关羽",
	["#gold_guanyu"] = "鬼神再临",
	["designer:gold_guanyu"] = "DGAH",
	["cv:gold_guanyu"] = "官方",
	["illustrator:gold_guanyu"] = "KayaK",
	["~gold_guanyu"] = "吾一世英名，竟葬于小人之手！",
}
--[[
	技能：武神（锁定技）
	描述：你的红心手牌视为火【杀】；你使用红色【杀】无距离限制且对手牌数不少于你的角色造成的伤害+1。
]]--
WuShen = sgs.CreateFilterSkill{
	name = "gold_wushen",
	view_filter = function(self, to_select)
		if to_select:getSuit() == sgs.Card_Heart then
			local room = sgs.Sanguosha:currentRoom()
			local id = to_select:getEffectiveId()
            local place = room:getCardPlace(id)
			if place == sgs.Player_PlaceHand then
				return true
			end
		end
		return false
	end,
	view_as = function(self, card)
		local point = card:getNumber()
		local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_Heart, point)
		slash:setSkillName("gold_wushen")
		local id = card:getEffectiveId()
		local wrapped = sgs.Sanguosha:getWrappedCard(id)
		wrapped:takeOver(slash)
		return wrapped
	end,
}
WuShenMod = sgs.CreateTargetModSkill{
	name = "#gold_wushen_mod",
	distance_limit_func = function(self, player, card)
		if player:hasSkill("gold_wushen") then
			if card:isKindOf("Slash") and card:isRed() then
				return 1000
			end
		end
		return 0
	end,
}
WuShenEffect = sgs.CreateTriggerSkill{
	name = "#gold_wushen_effect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:isKindOf("Slash") and slash:isRed() then
			local target = damage.to
			if target and target:getHandcardNum() >= player:getHandcardNum() then
				local msg = sgs.LogMessage()
				msg.type = "#gold_wushen_buff"
				msg.from = player
				msg.to:append(target)
				local count = damage.damage
				msg.arg = count
				count = count + 1
				msg.arg2 = count
				local room = player:getRoom()
				room:sendLog(msg) --发送提示信息
				damage.damage = count
				data:setValue(damage)
			end
		end
		return false
	end,
}
extension:insertRelatedSkills("gold_wushen", "#gold_wushen_mod")
extension:insertRelatedSkills("gold_wushen", "#gold_wushen_effect")
--添加技能
GuanYu:addSkill(WuShen)
GuanYu:addSkill(WuShenMod)
GuanYu:addSkill(WuShenEffect)
--翻译信息
sgs.LoadTranslationTable{
	["gold_wushen"] = "武神",
	[":gold_wushen"] = "锁定技。你的红心手牌视为火【杀】；你使用红色【杀】无距离限制且对手牌数不少于你的角色造成的伤害+1。",
	["$gold_wushen1"] = "武神现世，天下莫敌！",
	["$gold_wushen2"] = "战意，化为青龙翱翔吧！",
	["#gold_wushen_buff"] = "%from 的技能“<font color=\"yellow\">武神</font>”被触发，对 %to 造成的伤害+1，由 %arg 点上升至 %arg2 点",
}
--[[
	技能：武魂（锁定技）
	描述：你每受到1点伤害前，伤害来源获得一枚“梦魇”标记；你的手牌上限+X（X为场上“梦魇”标记的数目）；你死亡时，你选择一名拥有“梦魇”标记最多的角色进行一次判定，若结果不为【桃】或【桃园结义】，该角色立即死亡。
]]--
WuHun = sgs.CreateTriggerSkill{
	name = "gold_wuhun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			local source = damage.from
			if source and source:isAlive() then
				room:broadcastSkillInvoke("gold_wuhun", 1) --播放配音
				room:notifySkillInvoked(player, "gold_wuhun") --显示技能发动
				source:gainMark("@gold_wuhun_mark", damage.damage)
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				local alives = room:getAlivePlayers()
				local count = 0
				local targets = sgs.SPlayerList()
				for _,p in sgs.qlist(alives) do
					local mark = p:getMark("@gold_wuhun_mark")
					if mark > count then
						targets = sgs.SPlayerList()
						targets:append(p)
						count = mark
					elseif mark == count then
						targets:append(p)
					end
				end
				if count == 0 or targets:isEmpty() then
					return false
				end
				local target = room:askForPlayerChosen(player, targets, "gold_wuhun", "@gold_wuhun", false, true)
				if target then
					local judge = sgs.JudgeStruct()
					judge.who = target
					judge.reason = "gold_wuhun"
					judge.pattern = "Peach,GodSalvation"
					judge.good = true
					room:judge(judge)
					room:notifySkillInvoked(player, "gold_wuhun") --显示技能发动
					if judge:isBad() then
						room:broadcastSkillInvoke("gold_wuhun", 2) --播放配音
						room:killPlayer(target)
					else
						room:broadcastSkillInvoke("gold_wuhun", 3) --播放配音
					end
				end
				local another = room:findPlayerBySkillName("gold_wuhun")
				if not another then
					local alives = room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						p:loseAllMarks("@gold_wuhun_mark")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("gold_wuhun")
	end,
}
WuHunKeep = sgs.CreateMaxCardsSkill{
	name = "#gold_wuhun_keep",
	extra_func = function(self, player)
		if player:hasSkill("gold_wuhun") then
			local mark = player:getMark("@gold_wuhun_mark")
			local others = player:getSiblings()
			for _,p in sgs.qlist(others) do
				mark = mark + p:getMark("@gold_wuhun_mark")
			end
			return mark
		end
		return 0
	end,
}
extension:insertRelatedSkills("gold_wuhun", "#gold_wuhun_keep")
--添加技能
GuanYu:addSkill(WuHun)
GuanYu:addSkill(WuHunKeep)
--翻译信息
sgs.LoadTranslationTable{
	["gold_wuhun"] = "武魂",
	[":gold_wuhun"] = "锁定技。你每受到1点伤害前，伤害来源获得一枚“梦魇”标记；你的手牌上限+X（X为场上“梦魇”标记的数目）；你死亡时，你选择一名拥有“梦魇”标记最多的角色进行一次判定，若结果不为【桃】或【桃园结义】，该角色立即死亡。",
	["$gold_wuhun1"] = "关某记下了！",
	["$gold_wuhun2"] = "我生不能啖汝之肉，死当追汝之魂！",
	["$gold_wuhun3"] = "桃园之梦，再也不会回来了……",
	["@gold_wuhun"] = "武魂：请选择复仇的目标",
	["@gold_wuhun_mark"] = "梦魇",
}