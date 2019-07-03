--[[
	太阳神三国杀武将扩展包·金装武将（AI部分）
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
]]--
--[[****************************************************************
	编号：GOLD - 001
	称号：独眼的罗刹
	武将：夏侯惇
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：刚烈
	描述：你每受到1点伤害，你可以选择一项：1、获得一枚“烈”标记；2、弃置伤害来源两张牌。一名角色的回合结束时，若你有“烈”标记，你可以弃置所有“烈”标记，对其造成等量的伤害。
]]--
--room:askForChoice(player, "gold_ganglie", choices, data)
sgs.ai_skill_choice["gold_ganglie"] = function(self, choices, data)
	if string.find(choices, "discard") then
		local damage = data:toDamage()
		local source = damage.from
		if not source then
			return "mark"
		elseif self:isFriend(source) then
			return "mark"
		end
		if source:hasSkill("jijiu") and self:getSuitNum("red", true, source) > 0 then
			return "discard"
		end
		if source:hasSkill("nosrenxin") and source:getHandcardNum() <= 2 then
			return "discard"
		end
		if source:getPhase() == sgs.Player_Play then
			if source:hasSkill("luanji") and source:getHandcardNum() > 2 then
				return "discard"
			end
			if self:hasCrossbowEffect(source) then
				if sgs.Slash_IsAvailable(source) and getCardsNum("Slash", source, self.player) > 1 then
					return "discard"
				end
			end
		end
	end
	return "mark"
end
--room:askForCardChosen(player, target, "he", "gold_ganglie", false, sgs.Card_MethodDiscard)
--p:askForSkillInvoke("gold_ganglie", data)
sgs.ai_skill_invoke["gold_ganglie"] = function(self, data)
	local target = self.room:getCurrent()
	if target and self:isEnemy(target) then
		local damage = self.player:getMark("@gold_ganglie_mark")
		if damage > 1 and target:hasArmorEffect("silver_lion") and not self.player:hasSkill("jueqing") then
			return false
		elseif self:damageIsEffective(target) then
			if damage >= target:getHp() + self:getAllPeachNum(target) then
				if self.role == "renegade" and target:isLord() and self.room:alivePlayerCount() > 2 then
					return false
				end
				return true
			end
			if self:isWeak() and self:getAllPeachNum() == 0 then
				return true
			end
			return false
		end
	end
	return false
end
--[[****************************************************************
	编号：GOLD - 002
	称号：虎痴
	武将：许褚
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：裸衣
	描述：以你为来源的伤害结算开始时，你可以弃置一张装备牌，令此伤害+1；你可以将一张非基本牌当做【杀】打出。
]]--
--LuoYiVS:response
sgs.ai_view_as["gold_luoyi"] = function(card, player, card_place, class_name)
	if class_name == "Slash" and not card:isKindOf("BasicCard") then
		local reason = sgs.Sanguosha:getCurrentCardUseReason()
		if reason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			local id = card:getEffectiveId()
			local suit = card:getSuitString()
			local point = card:getNumberString()
			return string.format("slash:gold_luoyi[%s:%s]=%s", suit, point, id)
		end
	end
end
--room:askForCard(source, pattern, prompt, data, sgs.Card_MethodDiscard, nil, false, "gold_luoyi")
function discard_equip(self, who)
	local armor = who:getArmor()
	if armor and self:needToThrowArmor(who, false) then
		return armor:getEffectiveId()
	end
	if armor and self:evaluateArmor(armor, who) < -5 then
		return armor:getEffectiveId()
	end
	local weapon = who:getWeapon()
	if weapon then
		local value, flag = self:evaluateWeapon(weapon, who)
		if value <= 0 then
			return weapon:getEffectiveId()
		end
	end
	local equips = who:getEquips()
	if equips:length() == 1 then
		local equip = equips:first()
		if equip:isKindOf("Crossbow") then
			if self:hasSkills("paoxiao|gold_paoxiao") then
				return equip:getEffectiveId()
			elseif self:getCardsNum("Slash", "h") < 2 then
				return equip:getEffectiveId()
			end
		elseif equip:isKindOf("DefensiveHorse") then
			if not self:hasSkills(sgs.lose_equip_skill) then
				return -1
			end
		elseif equip:isKindOf("WoodenOx") then
			if self.player:getPile("wooden_ox"):length() > 0 then
				return -1
			end
		end
	end
	local ohorse = who:getOffensiveHorse()
	if self:hasSkills(sgs.lose_equip_skill, who) and self:isWeak(who) then
		if weapon then
			return weapon:getEffectiveId()
		elseif ohorse then
			return ohorse:getEffectiveId()
		end
	end
	if math.random(0, 100) <= 40 then
		return -1
	end
	equips = sgs.QList2Table(equips)
	self:sortByKeepValue(equips)
	return equips[1]:getEffectiveId()
end
sgs.ai_skill_cardask["@gold_luoyi"] = function(self, data, pattern, target, target2, arg, arg2)
	if self:isFriend(target) then
		return "."
	elseif target:hasArmorEffect("silver_lion") and not self.player:hasSkill("jueqing") then
		return "."
	end
	local damage = data:toDamage()
	if not self:damageIsEffective_(damage) then
		return "."
	end
	local to_throw = self:askForCard(pattern, "dummy", data)
	if to_throw then
		return to_throw
	elseif self.player:canDiscard(self.player, "e") then
		local id = discard_equip(self, self.player)
		if id and id >= 0 then
			return "$" .. id
		end
	end
	return "."
end
--相关信息
sgs.gold_luoyi_keep_value = {
	Peach = 6,
	Jink = 5.1,
	EquipCard = 6,
	TrickCard = 5,
}
--[[****************************************************************
	编号：GOLD - 003
	称号：前将军
	武将：张辽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：突袭
	描述：摸牌阶段，你可以少摸至少一张牌，然后将等量其他角色的各一张牌置入你的对应区域。
]]--
--room:askForCardChosen(source, target, "he", "gold_tuxi")
--room:askForUseCard(player, "@@gold_tuxi", "@gold_tuxi")
sgs.ai_skill_use["@@gold_tuxi"] = function(self, prompt, method)
	local n = self.player:getMark("gold_tuxi_total")
	if n == 0 then
		return "."
	end
	local can_select = self:findPlayerToDiscard("he", false, false, nil, true)
	local count = math.min(n, #can_select)
	if count == 0 then
		return "."
	end
	local targets = {}
	local selected = {}
	for index, target in ipairs(can_select) do
		local key = target:objectName() 
		if selected[key] then
		else
			table.insert(targets, key)
			selected[key] = true
			if #targets >= count then
				break
			end
		end
	end
	local card_str = string.format("#gold_tuxi_card:.:->%s", table.concat(targets, "+"))
	return card_str
end
--相关信息
sgs.ai_choicemade_filter["cardChosen"].gold_tuxi = function(self, player, promptlist)
	local from = findPlayerByObjectName(self.room, promptlist[4])
	local to = findPlayerByObjectName(self.room, promptlist[5])
	if from and to then
		local id = tonumber(promptlist[3])
		local place = self.room:getCardPlace(id)
		local card = sgs.Sanguosha:getCard(id)
		local intention = 70
		if to:hasSkills("tuntian+zaoxian") and to:getPile("field") == 2 and to:getMark("zaoxian") == 0 then intention = 0 end
		if place == sgs.Player_PlaceEquip then
			if card:isKindOf("Armor") and self:evaluateArmor(card, to) <= -2 then intention = 0 end
			if card:isKindOf("SilverLion") then
				if to:getLostHp() > 1 then
					if to:hasSkills(sgs.use_lion_skill) then
						intention = self:willSkipPlayPhase(to) and -intention or 0
					else
						intention = self:isWeak(to) and -intention or 0
					end
				else
					intention = 0
				end
			elseif to:hasSkills(sgs.lose_equip_skill) then
				if self:isWeak(to) and (card:isKindOf("DefensiveHorse") or card:isKindOf("Armor")) then
					intention = math.abs(intention)
				else
					intention = 0
				end
			end
			if (card:isKindOf("OffensiveHorse") or card:isKindOf("Weapon")) and self:isFriend(from, to) then
				local canAttack
				for _, p in sgs.qlist(self.room:getOtherPlayers(from)) do
					if from:inMyAttackRange(p) and self:isEnemy(p, from) then canAttack = true break end
				end
				if not canAttack then intention = 0 end
			end
		elseif place == sgs.Player_PlaceHand then
			if self:needKongcheng(to, true) and to:getHandcardNum() == 1 then
				intention = 0
			end
		end
		sgs.updateIntention(from, to, intention)
	end
end
--[[****************************************************************
	编号：GOLD - 004
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：仁德
	描述：出牌阶段，你可以将至少一张牌交给一名其他角色，出牌阶段结束时，若你本阶段内以此法给出的牌数不少于你本阶段内使用的红色牌数，你可以回复1点体力或摸两张牌。
]]--
--RenDeCard:play
local rende_skill = {
	name = "gold_rende",
	getTurnUseCard = function(self, inclusive)
		if self.player:isNude() then
			return nil
		end
		return sgs.Card_Parse("#gold_rende_card:.:")
	end,
}
table.insert(sgs.ai_skills, rende_skill)
sgs.ai_skill_use_func["#gold_rende_card"] = function(card, use, self)
	local to_give, target, cur_card = {}, nil, nil
	local handcards = self.player:getHandcards()
	handcards = sgs.QList2Table(handcards)
	self:sortByUseValue(handcards, true)
	local equips = self.player:getEquips()
	equips = sgs.QList2Table(equips)
	self:sortByKeepValue(equips)
	cur_card, target = self:getCardNeedPlayer(handcards, true)
	if target and cur_card then
		if target:objectName() == self.player:objectName() then
			target, cur_card = nil, nil
		else
			table.insert(to_give, cur_card:getEffectiveId())
		end
	end
	if not target then
		cur_card, target = self:getCardNeedPlayer(equips, true)
		if target and cur_card then
			if target:objectName() == self.player:objectName() then
				target, cur_card = nil, nil
			else
				table.insert(to_give, cur_card:getEffectiveId())
			end
		end
	end
	if not target and #self.friends_noself > 0 then
		self:sort(self.friends_noself, "defense")
		for _,friend in ipairs(self.friends_noself) do
			if not friend:hasSkill("manjuan") then
				target = friend
				break
			end
		end
		if target then
			local armor = self.player:getArmor()
			if armor and self:needToThrowArmor() then
				table.insert(to_give, armor:getEffectiveId())
			elseif self:getOverflow() > 0 then
				for _,c in ipairs(handcards) do
					local dummy_use = {
						isDummy = true,
					}
					if c:isKindOf("BasicCard") then
						self:useBasicCard(c, dummy_use)
					elseif c:isKindOf("TrickCard") then
						self:useTrickCard(c, dummy_use)
					elseif c:isKindOf("EquipCard") then
						self:useEquipCard(c, dummy_use)
					end
					if not dummy_use.card then
						table.insert(to_give, c:getEffectiveId())
						break
					end
				end
			elseif #equips > 0 and self:hasSkills(sgs.lose_equip_skill) then
				table.insert(to_give, equips[1]:getEffectiveId())
			end
		end
	end
	if target and #to_give == 1 and target:hasSkill("enyuan") and self:isFriend(target) then
		local card_id = to_give[1]:getEffectiveId()
		if self:getOverflow() > 0 then
			for _,c in ipairs(handcards) do
				if c:getEffectiveId() ~= card_id then
					table.insert(to_give, c:getEffectiveId())
					break
				end
			end
		end
		if #to_give == 1 then
			if #equips > 0 and self:hasSkills(sgs.lose_equip_skill) then
				for _,c in ipairs(equips) do
					if c:getEffectiveId() ~= card_id then
						table.insert(to_give, c:getEffectiveId())
						break
					end
				end
			end
		end
		if #to_give == 1 then
			local cards = self.player:getCards("he")
			cards = sgs.QList2Table(cards)
			self:sortByKeepValue(cards)
			for _,c in ipairs(cards) do
				if c:getEffectiveId() ~= card_id then
					table.insert(to_give, c:getEffectiveId())
					break
				end
			end
		end
	end
	if target and #to_give > 0 then
		local card_str = string.format("#gold_rende_card:%s:", table.concat(to_give, "+"))
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--room:askForChoice(player, "gold_rende", choices, data)
sgs.ai_skill_choice["gold_rende"] = function(self, choices, data)
	if string.find(choices, "recover") then
		if self:isWeak() then
			return "recover"
		elseif self:getOverflow() > -2 then
			return "recover"
		end
	end
	return "draw"
end
--相关信息
sgs.ai_use_value["gold_rende_card"] = sgs.ai_use_value["RendeCard"] or 8.5
sgs.ai_use_priority["gold_rende_card"] = sgs.ai_use_priority["RendeCard"] or 8.8
sgs.ai_card_intention["gold_rende_card"] = sgs.ai_card_intention["RendeCard"]
sgs.dynamic_value["benefit"].gold_rende_card = true
--[[
	技能：激将（主公技）
	描述：每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。
]]--
--[[****************************************************************
	编号：GOLD - 005
	称号：万夫不当
	武将：张飞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：咆哮（锁定技）
	描述：每当你使用或打出一张【杀】后，你翻开牌堆顶的一张牌并获得之；若此为你的出牌阶段且该牌不为红心牌，本阶段你可以额外使用一张【杀】。
]]--
--相关信息
sgs.ai_cardneed["gold_paoxiao"] = sgs.ai_cardneed["paoxiao"]
--[[****************************************************************
	编号：GOLD - 006
	称号：少年将军
	武将：赵云
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：龙胆
	描述：你或你攻击范围内的一名角色成为【杀】或锦囊牌的目标时，若使用者不为你，你可以弃一张【杀】或【闪】令此牌对该角色无效，然后你获得此牌。
]]--
--room:askForCard(source, "Slash,Jink", prompt, data, sgs.Card_MethodDiscard, nil, false, "gold_longdan")
sgs.ai_skill_cardask["@gold_longdan"] = function(self, data, pattern, target, target2, arg, arg2)
	local use = data:toCardUse()
	local user = use.from
	local card = use.card
	if card:isKindOf("Slash") and not self:slashIsEffective(card, target, user) then
		return "."
	elseif card:isKindOf("TrickCard") and not self:hasTrickEffective(card, target, user) then
		return "."
	end
	if arg == "ex_nihilo" then
		if self:isEnemy(target) then
			return self:askForCard(pattern, "dummy", nil)
		end
	elseif arg == "god_salvation" then
		if self:isEnemy(target) and target:getLostHp() > 0 then
			return self:askForCard(pattern, "dummy", nil)
		end		
	elseif arg == "amazing_grace" then
		if self:isEnemy(target) then
			if target:hasSkill("manjuan") then
				if target:getPhase() == sgs.Player_NotActive then
					return "."
				end
				return self:askForCard(pattern, "dummy", nil)
			end
			return self:askForCard(pattern, "dummy", nil)
		end
	elseif arg == "iron_chain" then
		if target:isChained() then
			return "."
		elseif self:isGoodChainTarget(target, user) then
			return "."
		elseif self:getCardsNum("Slash", "he") + self:getCardsNum("Jink", "he") < 3 then
			return "."
		elseif self:isFriend(target) then
			return self:askForCard(pattern, "dummy", nil)
		end
	else
		if target:objectName() == self.player:objectName() then
			return self:askForCard(pattern, "dummy", nil)
		elseif self:isFriend(target) and self:isWeak(target) then
			return self:askForCard(pattern, "dummy", nil)
		end
	end
	return "."
end
--相关信息
sgs.gold_longdan_keep_value = {
	Peach = 6,
	Analeptic = 5.8,
	Jink = 5.7,
	FireSlash = 5.7,
	Slash = 5.6,
	ThunderSlash = 5.5,
	ExNihilo = 4.7
}
sgs.ai_cardneed["gold_longdan"] = function(to, card, self)
	return card:isKindOf("Slash") or card:isKindOf("Jink")
end
sgs.ai_choicemade_filter["cardResponded"]["@gold_longdan"] = function(self, player, promptlist)
	local name = promptlist[4]
	if name == player:objectName() then
		return
	end
	local _id_ = promptlist[8]
	if _id_ == "_nil_" then
		return 
	end
	local target = findPlayerByObjectName(self.room, name)
	if target then
		local card_name = promptlist[6]
		local card = sgs.Sanguosha:cloneCard(card_name)
		card:deleteLater()
		if card:isKindOf("Slash") and not self:slashIsEffective(card, target) then
			return 
		elseif card:isKindOf("TrickCard") and not self:hasTrickEffective(card, target) then
			return 
		end
		if card:isKindOf("Slash") then
		elseif card_name == "ex_nihilo" then
			sgs.updateIntention(player, target, 30)
		elseif card_name == "god_salvation" then
			if target:getLostHp() > 0 then
				sgs.updateIntention(player, target, 80)
			end
		elseif card_name == "amazing_grace" then
			if not hasManjuanEffect(target) then
				sgs.updateIntention(player, target, 20)
			end
		elseif card_name == "iron_chain" then
			if not target:isChained() then
				sgs.updateIntention(player, target, -80)
			elseif not self:isGoodChainTarget(target) then
				sgs.updateIntention(player, target, 40)
			end
		else
			sgs.updateIntention(player, target, -60)
		end
	end
end
--[[****************************************************************
	编号：GOLD - 007
	称号：嗜血的独狼
	武将：魏延
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：狂骨（锁定技）
	描述：你对一名距离为1以内的角色造成1点伤害后，你选择一项：回复1点体力，或摸两张牌；你计算的与其他角色的距离-X（X为该角色已损失的体力）。
]]--
--room:askForChoice(player, "gold_kuanggu", choices, data)
sgs.ai_skill_choice["gold_kuanggu"] = function(self, choices, data)
	if string.find(choices, "recover") then
		if self:isWeak() then
			return "recover"
		end
		local phase = self.player:getPhase()
		if phase == sgs.Player_NotActive then
			if self:hasSkills(sgs.notActive_cardneed_skill) then
				return "draw"
			end
		elseif phase <= sgs.Player_Play then
			if self:hasCrossbowEffect() then
				return "draw"
			elseif self:hasSkills(sgs.Active_cardneed_skill) then
				return "draw"
			elseif self:getOverflow() > -2 then
				return "draw"
			end
		else
			if self.player:getHp() >= getBestHp(self.player) then
				return "draw"
			end
		end
		return "recover"
	end
	return "draw"
end
--[[****************************************************************
	编号：GOLD - 008
	称号：轻身为国
	武将：黄盖
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--KuRouCard:play
local kurou_skill = {
	name = "gold_kurou",
	getTurnUseCard = function(self, inclusive)
		return sgs.Card_Parse("#gold_kurou_card:.:")
	end,
}
table.insert(sgs.ai_skills, kurou_skill)
local function need_death(self)
	if #self.enemies == 0 then
		return false
	elseif self.role == "lord" or self.role == "renegade" then
		return false
	elseif self.player:getHp() > 1 then
		return false
	elseif self.room:alivePlayerCount() == 2 then
		return false
	elseif not self:isWeak() then
		return false
	end
	local lord = getLord(self.player)
	if self.player:hasSkill("wuhun") then
		local victims = self:getWuhunRevengeTargets()
		if #victims > 0 then
			for _,p in ipairs(victims) do
				if p:isLord() and self.role == "rebel" then
					return true
				elseif lord and lord:objectName() == p:objectName() then
					return false
				end
			end
		end
	end
	if self.player:hasSkill("gold_wuhun") then
		local others = self.room:getOtherPlayers(self.player)
		local victims, mark = {}, 0
		for _,p in sgs.qlist(others) do
			local n = p:getMark("@gold_wuhun_mark")
			if n > mark then
				victims = { p }
				mark = n
			elseif n == mark and mark > 0 then
				table.insert(victims, p)
			end
		end
		if #victims > 0 then
			for _,p in ipairs(victims) do
				if p:isLord() and self.role == "rebel" then
					return true
				elseif lord and lord:objectName() == p:objectName() then
					return false
				end
			end
		end
	end
	local peachNum = self:getAllPeachNum()
	local next_player = self.player:getNextAlive()
	local next_will_play = not self:willSkipPlayPhase(next_player)
	if self:isFriend(next_player) then
		if peachNum == 0 and self.role == "rebel" and self.player:getEquips():isEmpty() then
			for _,p in ipairs(self.enemies) do
				if p:hasSkill("xiaoguo") and not p:isKongcheng() then
					return true
				end
			end
		end
		if next_will_play then
			if next_player:hasSkill("jieyin") and self.player:isMale() then
				if next_player:getHandcardNum() > 1 or not self:willSkipDrawPhase(next_player) then
					return false
				end
			end
			if next_player:hasSkill("qingnang") then
				if next_player:isKongcheng() and self:willSkipDrawPhase(next_player) then
				else
					return false
				end
			end
		end
	elseif self:isEnemy(next_player) then
		if peachNum == 0 and self.role == "rebel" then
			if next_will_play or next_player:hasSkill("shensu") then
				return true
			end
		end
	end
	if self.role == "loyalist" and peachNum == 0 then
		if lord and lord:objectName() ~= self.player:objectName() and not lord:isNude() then
			if self:hasSkills("noslijian|lijian", next_player) then
				if lord:isMale() and self.player:isMale() then
					return true
				end
			end
			if next_player:hasSkill("quhu") then
				if lord:getHp() > next_player:getHp() and not lord:isKongcheng() then
					if lord:inMyAttackRange(self.player) then
						return true
					end
				end
			end
		end
	end
	return false
end
sgs.ai_skill_use_func["#gold_kurou_card"] = function(card, use, self)
	local source = nil
	if need_death(self) then
		if self:hasSkills("wuhun|gold_wuhun") then
			if self.role == "rebel" then
				local lord = self.room:getLord()
				if lord and not self:isFriend(lord) then
					source = lord
				end
			end
		end
		if not source then
			if self:hasSkills("huilei|duanchang|dushi|tangqiang") then
				self:sort(self.enemies, "threat")
				for _,enemy in ipairs(self.enemies) do
					if self.player:hasSkill("huilei") and not enemy:canDiscard(enemy, "he") then
					elseif self.player:hasSkill("dushi") and enemy:hasSkill("benghuai") then
					elseif self.player:hasSkill("duanchang") then
						local skills = enemy:getVisibleSkillList()
						local hasSkill = false
						for _,skill in sgs.qlist(skills) do
							if skill:inherits("SPConvertSkill") then
							elseif skill:isLordSkill() and enemy:hasLordSkill(skill:objectName()) then
								hasSkill = true
								break
							else
								hasSkill = true
								break
							end
						end
						if hasSkill then
							source = enemy
							break
						end
					else
						source = enemy
						break
					end
				end
			elseif self.role == "rebel" then
				source = self:findPlayerToDraw(false, 3) or self.player
			elseif self.role == "loyalist" then
				source = self.player
			end
		end
	end
	local hp = self.player:getHp()
	local amLord = isLord(self.player)
	local lord = self.room:getLord()
	if not source then
		local lost_hp = amLord and 0 or 1
		local num = self.player:getHandcardNum()
		local overflow = self:getOverflow()
		if hp > 3 and self.player:getLostHp() <= lost_hp and ( overflow < 0 or self:getCardsNum("Peach") > 1 ) then
			source = self.player
		elseif overflow <= -2 and not (amLord and sgs.turncount <= 1) then
			source = self.player
			sgs.ai_gold_kurou_choice = "draw"
		end
	end
	local care_flag = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	if not source and hp > 1 then
		for _,enemy in ipairs(self.enemies) do
			if enemy:getHp() < 1 and enemy:hasSkill("nosbuqu") then
				if enemy:hasSkill("nosdanshou") or enemy:hasSkill("jueqing") then
				elseif care_flag and enemy:isLord() and self:getAllPeachNum(enemy) == 0 then
				else
					source = enemy
					sgs.ai_gold_kurou_choice = "skill"
					break
				end
			end
		end
	end
	if not source then
		if self.role == "rebel" and self:hasSkills("wuhun|gold_wuhun") then
			if lord and self:isEnemy(lord) and not lord:hasSkill("jueqing") then
				local isMost = true
				local others = room:getOtherPlayers(self.player)
				if self.player:hasSkill("wuhun") then
					local mark = lord:getMark("@nightmare")
					if mark == 0 then
						isMost = false
					else
						for _,p in sgs.qlist(others) do
							if p:objectName() == lord:objectName() then
							elseif p:getMark("@nightmare") > mark then
								isMost = false
								break
							end
						end
					end
				end
				if isMost and self.player:hasSkill("gold_wuhun") then
					local mark = lord:getMark("@gold_wuhun_mark")
					if mark == 0 then
						isMost = false
					else
						for _,p in sgs.qlist(others) do
							if p:objectName() == lord:objectName() then
							elseif p:getMark("@gold_wuhun_mark") > mark then
								isMost = false
								break
							end
						end
					end
				end
				if not isMost then
					source = lord
				end
			end
		end
	end
	if not source and self:hasCrossbowEffect() and hp > 1 then
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		for _,enemy in ipairs(self.enemies) do
			if enemy:hasSkill("kongcheng") and enemy:isKongcheng() then
			elseif self:hasSkills("fankui|guixin", enemy) and not self.player:hasSkill("paoxiao") then
			elseif self:hasSkills("fenyong|jilei|zhichi", enemy) then
			elseif self.player:canSlash(enemy, nil, true) and self:slashIsEffective(slash, enemy) then
				if sgs.isGoodTarget(enemy, self.enemies, self) then
					if not self:slashProhibit(slash, enemy) then
						source = self.player
						sgs.ai_gold_kurou_choice = "skill"
						break
					end
				end				
			end
		end
	end
	if not source then
		local JinXuanDi = self.room:findPlayerBySkillName("wuling")
		if JinXuanDi and JinXuanDi:getMark("@earth") > 0 then
		else
			if self.player:hasSkill("yeyan") and self.player:getMark("@flame") > 0 then
				local dummy_use = {
					isDummy = true,
				}
				local card = sgs.Card_Parse("@SmallYeyanCard=.")
				card:deleteLater()
				self:useSkillCard(card, dummy_use)
				if dummy_use.card then
					source = self.player
					sgs.ai_gold_kurou_choice = "fire"
				end
				if not source then
					card = sgs.Card_Parse("@GreatYeyanCard=.")
					card:deleteLater()
					self:useSkillCard(card, dummy_use)
					if dummy_use.card then
						source = self.player
						sgs.ai_gold_kurou_choice = "fire"
					end
				end
			end
			if not source then
				if self:getCardsNum("FireAttack", "he") > 1 then
					if self.player:getHandcardNum() > 4 and self.player:canDiscard(self.player, "h") then
						local fire_attack = sgs.Sanguosha:cloneCard("fire_attack")
						fire_attack:deleteLater()
						local dummy_use = {
							isDummy = true,
						}
						self:useTrickCard(fire_attack, dummy_use)
						if dummy_use.card then
							source = self.player
							sgs.ai_gold_kurou_choice = "fire"
						end
					end
				end
			end
			if not source then
				if self:hasCrossbowEffect() then
					if self:getCardsNum("FireSlash", "he") > 1 then
						local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
						fire_slash:deleteLater()
						local dummy_use = {
							isDummy = true,
						}
						self:useBasicCard(fire_slash, dummy_use)
						if dummy_use.card then
							source = self.player
							sgs.ai_gold_kurou_choice = "fire"
						end
					end
				end
			end
		end
	end
	if not source then
		if hp == 1 and self:getCardsNum("Analeptic") > 0 then
			source = self.player
			sgs.ai_gold_kurou_choice = "draw"
		end
	end
	if source then
		use.card = card
		if use.to then
			use.to:append(source)
		end
	end
end
--room:askForChoice(player, "gold_kurou", choices, data)
sgs.ai_skill_choice["gold_kurou"] = function(self, choices, data)
	local meetSkill = string.find(choices, "skill")
	local meetFire = string.find(choices, "fire")
	local JinXuanDi = self.room:findPlayerBySkillName("wuling")
	if meetFire then
		if JinXuanDi and JinXuanDi:getMark("@earth") > 0 then
			meetFire = false
		end
	end
	local choice = sgs.ai_gold_kurou_choice
	if choice then
		sgs.ai_gold_kurou_choice = nil
		if meetSkill and choice == "skill" then
			return "skill"
		elseif meetFire and choice == "fire" then
			return "fire"
		elseif choice == "draw" then
			return "draw"
		end
	end
	local damage = data:toDamage()
	local source = damage.from
	local isEnemy = source and self:isEnemy(source)
	local isFriend = source and self:isFriend(source)
	local isMe = source and ( source:objectName() == self.player:objectName() )
	local amPlaying = ( self.player:getPhase() == sgs.Player_Play )
	local isCurrent = source and ( source:getPhase() ~= sgs.Player_NotActive )
	local isPlaying = source and ( source:getPhase() == sgs.Player_Play )
	local careLord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	careLord = cardLord and source and source:isLord()
	if meetSkill and isEnemy and not careLord then
		if source:getHp() < 1 and source:hasSkill("nosbuqu") then
			return "skill"
		end
	end
	if meetSkill and isEnemy and isCurrent then
		if source:getHandcardNum() > 2 then
			if source:hasSkill("luanji") then
				return "skill"
			elseif source:hasSkill("fuhun") and source:getMark("fuhun") > 0 then
				return "skill"
			elseif source:hasSkill("nosfuhun") and source:getMark("nosfuhun") > 0 then
				return "skill"
			elseif source:hasSkill("shuangxiong") and source:getMark("shuangxiong") > 0 then
				return "skill"
			end
		end
	end
	if meetFire and isFriend and isCurrent then
		if source:getHandcardNum() > 2 then
			if not self:hasSkills("wuyan|noswuyan", source) then
				if ( isMe and self:getCardsNum("FireAttack") or getCardsNum("FireAttack", source, self.player) ) > 0 then
					return "fire"
				end
			end
			if ( isMe and self:getCardsNum("FireSlash") or getCardsNum("FireSlash", source, self.player) ) > 0 then
				return "fire"
			end
			if source:hasSkill("yeyan") and source:getMark("@flame") > 0 then
				return "fire"
			end
		end
	end
	if meetSkill and isEnemy and amPlaying then
		local qclist = "noswuyan|weimu|wuyan|guixin|fenyong|liuli|yiji|jieming|neoganglie|fankui|"..
			"fangzhu|enyuan|nosenyuan|vsganglie|ganglie|langgu|qingguo|luoying|guzheng|jianxiong|"..
			"longdan|xiangle|renwang|huangen|tianming|yizhong|bazhen|jijiu|beige|longhun|"..
			"gushou|buyi|mingzhe|danlao|qianxun|jiang|yanzheng|juxiang|huoshou|anxian|"..
			"zhichi|feiying|tianxiang|xiaoji|xuanfeng|nosxuanfeng|xiaoguo|guhuo|guidao|guicai|"..
			"nosshangshi|lianying|sijian|mingshi|yicong|zhiyu|lirang|xingshang|shushen|shangshi|"..
			"leiji|nosleiji|wusheng|wushuang|tuntian|quanji|kongcheng|jieyuan|jilve|wuhun|"..
			"kuangbao|tongxin|shenjun|ytchengxiang|sizhan|toudu|xiliang|tanlan|shien"
		if self:hasSkills(qclist, source) then
			return "fire"
		end
	end
	if meetFire and isFriend and isPlaying then
		if JinXuanDi and JinXuanDi:getMark("@fire") > 0 then
			return "fire"
		end
	end
	return "draw"
end
--room:askForPlayerChosen(player, targets, "gold_kurou", "@gold_kurou", true, false)
sgs.ai_skill_playerchosen["gold_kurou"] = function(self, targets)
	local enemies = {}
	for _,p in sgs.qlist(targets) do
		if self:isEnemy(p) then
			table.insert(enemies, p)
		end
	end
	if #enemies > 0 then
		self:sort(enemies, "threat")
		for _,enemy in ipairs(enemies) do
			if enemy:getPhase() == sgs.Player_NotActive then
				if self:hasSkills(sgs.masochism_skill, enemy) then
					return enemy
				elseif enemy:getHandcardNum() > 1 and self:hasSkills(sgs.notActive_cardneed_skill, enemy) then
					return enemy
				end
			elseif self:hasSkills(sgs.priority_skill, enemy) then
				return enemy
			end
		end
		return enemies[1]
	end
	return targets:first()
end
--相关信息
sgs.gold_kurou_keep_value = {
	Peach = 7,
	Analeptic = 5.8,
	Crossbow = 5.7,
	Jink = 5.7,
	FireSlash = 5.6,
	FireAttack = 5.2,
	Fan = 3.7,
}
sgs.ai_use_value["gold_kurou_card"] = sgs.ai_use_value["KurouCard"] or 7.2
sgs.ai_use_priority["gold_kurou_card"] = sgs.ai_use_priority["NosKurouCard"] or 6.8
sgs.ai_cardneed["gold_kurou"] = function(to, card, self)
	if card:isKindOf("Crossbow") and not self:hasCrossbowEffect(to) then
		return true
	elseif card:isKindOf("OffensiveHorse") then
		if to:objectName() == self.player:objectName() then
			if self:getCardsNum("OffensiveHorse", "he", true) == 0 then
				return true
			end
		else
			if getCardsNum("OffensiveHorse", to, self.player) == 0 and not to:getOffensiveHorse() then
				return true
			end
		end
	elseif isCard("Peach", card, to) or isCard("Analeptic", card, to) then
		return true
	end
	return false
end
sgs.ai_choicemade_filter["playerChosen"].gold_kurou = function(self, player, promptlist)
	local name = promptlist[3]
	if name == player:objectName() then
		return
	end
	local target = findPlayerByObjectName(self.room, name)
	if target then
		if not self:hasSkills(sgs.bad_skills, target) then
			sgs.updateIntention(player, target, 80)
		end
	end
end
sgs.ai_choicemade_filter["skillChoice"].gold_kurou = function(self, player, promptlist)
	local choice = promptlist[3]
	if choice == "fire" then
		local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
		if damage then
			local source = damage.from
			if source and source:objectName() ~= player:objectName() then
				sgs.updateIntention(player, source, -50)
			end
		end
	end
end
--[[****************************************************************
	编号：GOLD - 009
	称号：儒生雄才
	武将：陆逊
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：谦逊（锁定技）
	描述：你不能成为体力不小于你的角色使用的【顺手牵羊】、【乐不思蜀】、【决斗】的目标；你对体力不大于你的目标使用的非延时性锦囊牌不能被【无懈可击】抵消。
]]--
--[[
	技能：连营
	描述：出牌阶段限一次，你可以摸两张牌，然后你可以将一张红色手牌当做【火攻】对你攻击范围内的一名角色使用。若此牌造成伤害，你可以对该角色攻击范围内的另一名角色重复此流程。然后你弃两张牌。
]]--
--room:askForDiscard(source, "gold_lianying", 2, 2, false, true)
--LianYingCard:play
local lianying_skill = {
	name = "gold_lianying",
	getTurnUseCard = function(self, inclusive)
		if not self.player:hasUsed("#gold_lianying_card") then
			local card_str = "#gold_lianying_card:.:"
			return sgs.Card_Parse(card_str)
		end
	end,
}
table.insert(sgs.ai_skills, lianying_skill)
sgs.ai_skill_use_func["#gold_lianying_card"] = function(card, use, self)
	use.card = card
end
--room:askForUseCard(source, "@@gold_lianying", "@gold_lianying:::red:")
local function can_fire_attack(self, source, trick, enemy, enemies)
	if source:hasFlag("FireAttackFailed_" .. enemy:objectName()) then
		return false
	elseif not self:hasTrickEffective(trick, enemy) then
		return false
	elseif not sgs.isGoodTarget(enemy, enemies, self) then
		return false
	end
	local damage = 1
	if not source:hasSkill("jueqing") then
		if enemy:hasArmorEffect("vine") or enemy:hasArmorEffect("gale_shell") then
			damage = damage + 1
		end
		if enemy:getMark("@gale") > 0 then
			damage = damage + 1
		end
		if enemy:hasSkill("mingshi") and source:getEquips():length() <= enemy:getEquip():length() then
			damage = damage - 1
		end
		if enemy:hasArmorEffect("silver_lion") then
			damage = math.min(1, damage)
		end
	end
	if self:cantbeHurt(enemy, source, damage) then
		return false
	end
	if source:hasSkill("jueqing") then
		return true
	end
	if enemy:hasSkill("jianxiong") and not self:isWeak(enemy) then
		return false
	elseif self:getDamagedEffects(enemy, source) then
		return false
	elseif enemy:isChained() and not self:isGoodChainTarget(enemy, source, sgs.DamageStruct_Fire, nil, trick) then
		return false
	end
	return true
end
sgs.ai_skill_use["@@gold_lianying"] = function(self, prompt, method)
	if self.player:hasSkill("wuyan") and not self.player:hasSkill("jueqing") then
		return "."
	elseif self.player:hasSkill("noswuyan") then
		return "."
	elseif not self.player:canDiscard(self.player, "h") then
		return "."
	end
	local reds = {}
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		if c:isRed() then
			table.insert(reds, c)
		end
	end
	if #reds == 0 then
		return "."
	end
	local count = {
		spade = 0,
		heart = 0,
		club = 0,
		diamond = 0,
	}
	local can_discard = {}
	local isXiaoQiao = self.player:hasSkill("hongyan")
	for _,c in sgs.qlist(handcards) do
		local suit = c:getSuitString()
		if isXiaoQiao and suit == "spade" then
			suit = "heart"
		end
		count[suit] = ( count[suit] or 0 ) + 1
		if self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(can_discard, c)
		end
	end
	if #can_discard == 0 or count["heart"] + count["diamond"] == 1 then
		return "."
	end
	local to_use = nil
	self:sortByUseValue(reds, true)
	local threshold = sgs.ai_use_value["FireAttack"] or 4.8
	for _,red in ipairs(reds) do
		local value = sgs.ai_use_value[red:getClassName()] or 0
		if value < threshold then
			to_use = red
			break
		end
		local dummy_use = {
			isDummy = true,
		}
		if red:isKindOf("BasicCard") then
			self:useBasicCard(red, dummy_use)
		elseif red:isKindOf("TrickCard") then
			self:useTrickCard(red, dummy_use)
		elseif red:isKindOf("EquipCard") then
			self:useEquipCard(red, dummy_use)
		end
		if not dummy_use.card then
			if value == threshold and red:isKindOf("FireAttack") then
				return "."
			end
			to_use = red
			break
		end
	end
	if to_use then
		local suit = to_use:getSuitString()
		count[suit] = math.max( 0, ( count[suit] or 0 ) - 1 )
	else
		return "."
	end
	local fa = sgs.Sanguosha:cloneCard("fire_attack", to_use:getSuit(), to_use:getNumber())
	fa:deleteLater()
	local center = self.player
	if not center:hasFlag("gold_lianying_center") then
		local others = self.room:getOtherPlayers(center)
		for _,p in sgs.qlist(others) do
			if p:hasFlag("gold_lianying_center") then
				center = p
				break
			end
		end
	end
	local can_select = {}
	local alives = self.room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if center:inMyAttackRange(p) and not p:isKongcheng() then
			if not self.player:isProhibited(p, fa) then
				table.insert(can_select, p)
			end
		end
	end
	if #can_select == 0 then
		return "."
	end
	local suit_num = 0
	for suit, num in pairs(count) do
		if num > 0 then
			suit_num = suit_num + 1
		end
	end
	local all_enemies, all_friends = {}, {}
	for _,p in ipairs(can_select) do
		if self:isFriend(p) then
			table.insert(all_friends, p)
		else
			table.insert(all_enemies, p)
		end
	end
	local target = nil
	if #all_enemies > 0 then
		self:sort(all_enemies, "defense")
		local enemies = {}
		for _,enemy in ipairs(all_enemies) do
			if can_fire_attack(self, self.player, fa, enemy, all_enemies) then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			for _,enemy in ipairs(enemies) do
				if enemy:getHandcardNum() == 1 then
					local c = enemy:getHandcards():first()
					if count[c:getSuitString()] > 0 then
						target = enemy
						break
					end
				end
			end
			local lack = false
			if suit_num <= 1 or ( suit_num == 2 and count["diamond"] > 0 ) then
				if self:getOverflow() <= ( self.player:hasSkills("jizhi|nosjizhi") and -2 or 0 ) then
					lack = true
				end
			end
			if not lack then
				target = enemies[1]
			end
		end
	end
	if not target and #all_friends > 0 then
		local can_attack_myself = false
		for _,p in ipairs(all_friends) do
			if p:objectName() == self.player:objectName() then
				can_attack_myself = true
				break
			end
		end
		if can_attack_myself and self.player:isChained() then
			if self:isGoodChainTarget(self.player, self.player, sgs.DamageStruct_Fire, nil, fa) then
				if self.player:hasSkill("jueqing") or self.player:hasSkill("mingshi") then
				elseif self:cantbeHurt(self.player) then
				elseif self:hasTrickEffective(fa, self.player) then
					if self.player:hasSkill("niepan") and self.player:getMark("@nirvana") > 0 then
						target = self.player
					elseif hasBuquEffect(self.player) then
						target = self.player
					else
						local damage = 1
						if self.player:hasArmorEffect("vine") or self.player:hasArmorEffect("gale_shell") then
							damage = damage + 1
						end
						if self.player:getMark("@gale") then
							damage = damage + 1
						end
						local JinXuanDi = self.room:findPlayerBySkillName("wuling")
						if JinXuanDi and JinXuanDi:getMark("@wind") > 0 then
							damage = damage + 1
						end
						if self.player:hasArmorEffect("silver_lion") then
							damage = 1
						end
						if self.player:getHp() > damage then
							target = self.player
						elseif self:getAllPeachNum() + self.player:getHp() + self:getCardsNum("Analeptic") > damage then
							target = self.player
						end
					end
				end
			end
		end
	end
	if target then
		local id = to_use:getEffectiveId()
		local name = target:objectName()
		local card_str = string.format("#gold_lianying_trick:%d:->%s", id, name)
		return card_str
	end
	return "."
end
--source:askForSkillInvoke("gold_lianying", data)
sgs.ai_skill_invoke["gold_lianying"] = true
--相关信息
sgs.ai_use_value["gold_lianying_card"] = ( sgs.ai_use_value["FireAttack"] or 4.8 ) + 0.2
sgs.ai_use_priority["gold_lianying_card"] = ( sgs.ai_use_priority["FireAttack"] or 4.5 ) + 0.1
sgs.ai_cardneed["gold_lianying"] = sgs.ai_cardneed["huoji"]
--[[****************************************************************
	编号：GOLD - 010
	称号：鬼神再临
	武将：关羽
	势力：神
	性别：男
	体力上限：5勾玉
]]--****************************************************************
--[[
	技能：武神（锁定技）
	描述：你的红心手牌视为火【杀】；你使用红色【杀】无距离限制且对手牌数不少于你的角色造成的伤害+1。
]]--
--WuShen:play
--[[
	技能：武魂（锁定技）
	描述：你每受到1点伤害，伤害来源获得一枚“梦魇”标记；你的手牌上限+X（X为场上“梦魇”标记的数目）；你死亡时，你选择一名拥有“梦魇”标记最多的角色进行一次判定，若结果不为【桃】或【桃园结义】，该角色立即死亡。
]]--
--room:askForPlayerChosen(player, targets, "gold_wuhun", "@gold_wuhun", false, true)
sgs.ai_skill_playerchosen["gold_wuhun"] = function(self, targets)
	local enemies = {}
	for _,p in sgs.qlist(targets) do
		if self:isEnemy(p) then
			table.insert(enemies, p)
		end
	end
	if #enemies > 0 then
		self:sort(enemies, "defense")
		enemies = sgs.reverse(enemies)
		for _,enemy in ipairs(enemies) do
			if enemy:isLord() then
				return enemy
			end
		end
		return enemies[1]
	end
	return targets:first()
end