bot = GetBot()
botRole = 2

local coreItems = {
    "item_branches",
    "item_branches",
    "item_branches",
    "item_blades_of_attack",
    "item_sobi_mask",
    "item_fluffy_hat",
    "item_recipe_falcon_blade",
    "item_boots",
    "item_magic_stick",
    "item_recipe_magic_wand",
    "item_javelin",
    "item_mithril_hammer",
    "item_mithril_hammer",
    "item_ogre_axe",
    "item_recipe_black_king_bar",
    "item_staff_of_wizardry",
    "item_crown",
    "item_crown",
    "item_recipe_rod_of_atos",
    "item_recipe_gungir",
    "item_recipe_travel_boots",
}

local Linken = {
    "item_ultimate_orb",
    "item_ring_of_health",
    "item_void_stone",
    "item_recipe_sphere",
}

local Silver_Edge = {
    "item_blitz_knuckles",
    "item_broadsword",
    "item_shadow_amulet",
    "item_broadsword",
    "item_blades_of_attack",
    "item_recipe_lesser_crit",
    "item_recipe_silver_edge",
}

local MKB = {
    "item_demon_edge",
    "item_javelin",
    "item_blitz_knuckles",
    "item_recipe_monkey_king_bar",
}

local Satanic = {
    "item_lifesteal",
    "item_reaver",
    "item_claymore",
}

function ItemPurchaseThink()

    local table = ItemLogic()

    local sNextItem = nil

    if ( #coreItems ~= 0 ) then
		sNextItem = coreItems[1]
	elseif #table ~= 0 then
        sNextItem = table[1]
    end

    if sNextItem == nil then
        bot:SetNextItemPurchaseValue( 0 );
		return;
    end

	bot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( bot:GetGold() >= GetItemCost( sNextItem ) )
	then
		bot:ActionImmediate_PurchaseItem( sNextItem );
        if ( #coreItems ~= 0 ) then
		    table.remove( coreItems, 1 );
        end
        if ( #table ~= 0 ) then
		    table.remove( table, 1 );
        end
	end
    
end

function ItemLogic()
    local item = {}
    if #coreItems ~= 0 then
        return item
    end

    local enemyTeam
    local need_Linken = false
    local need_Silver_Edge = false
    local need_MKB = false

    if GetTeam() == TEAM_RADIANT then
        enemyTeam = TEAM_DIRE
    else
        enemyTeam = TEAM_RADIANT
    end

    for _,id in pairs(GetTeamPlayers(enemyTeam)) do
        if (GetSelectedHeroName(id) == "npc_dota_hero_batrider") then
            need_Linken = true
        end
    end

    for _,id in pairs(GetTeamPlayers(enemyTeam)) do
        if (GetSelectedHeroName(id) == "npc_dota_hero_bristle_back") then
            need_Silver_Edge = true
        end
    end

    for _,id in pairs(GetTeamPlayers(enemyTeam)) do
        if (GetSelectedHeroName(id) == "npc_dota_hero_phantom_assassin") then
            need_MKB = true
        end
    end

    if need_Linken and (bot:GetItemInSlot(bot:FindItemSlot("item_ultimate_orb")) ~= nil or bot:GetItemInSlot(bot:FindItemSlot("item_sphere"))) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_branches")) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_magic_wand")) ~= nil then
        bot:ActionImmediate_SellItem( bot:GetItemInSlot(bot:FindItemSlot("item_branches")) )
    end
    if need_Silver_Edge and (bot:GetItemInSlot(bot:FindItemSlot("item_blitz_knuckles")) ~= nil or bot:GetItemInSlot(bot:FindItemSlot("item_invis_sword")) or bot:GetItemInSlot(bot:FindItemSlot("item_silver_edge"))) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_branches")) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_magic_wand")) ~= nil then
        bot:ActionImmediate_SellItem( bot:GetItemInSlot(bot:FindItemSlot("item_branches")) )
    end
    if need_MKB and (bot:GetItemInSlot(bot:FindItemSlot("item_demon_edge")) ~= nil or bot:GetItemInSlot(bot:FindItemSlot("item_monkey_king_bar"))) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_branches")) ~= nil and bot:GetItemInSlot(bot:FindItemSlot("item_magic_wand")) ~= nil then
        bot:ActionImmediate_SellItem( bot:GetItemInSlot(bot:FindItemSlot("item_branches")) )
    end

    if need_Linken and #Linken ~= 0 then
        return Linken
    end

    if need_Linken and need_Silver_Edge and need_MKB and #MKB ~= 0 then
        return MKB
    end
    
    if need_Linken == false and need_Silver_Edge and #Silver_Edge ~= 0 then
        return Silver_Edge
    end

    if need_MKB and #MKB ~= 0 then
        return MKB
    end

    if #Satanic ~= 0 then
        return Satanic
    end

    return item

end 
