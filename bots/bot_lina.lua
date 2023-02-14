bot = GetBot()
botRole = 2
function Think()
    Laning()
    Farming()
    GetDesire()

end

desire = 0
action = ""
actionTarget1 = nil
actionTarget2 = nil

lowHpCreepTimer = 0

function GetDesire()

    --local desire,action,actionTarget1,actionTarget2 = Laning()

    --if Laning() > Farming() and Laning() > Pushing() and Laning() > Defending() and Laning() > Attacking() and Laning() > Roshan() then
    if action == "UseAbilityOnLocation" then
        bot:Action_UseAbilityOnLocation(actionTarget1, actionTarget2)
    end

    if action == "MoveToLocation" then
        bot:Action_MoveToLocation(actionTarget1)
    end

    if action == "AttackUnit" then
        bot:Action_AttackUnit(actionTarget1, true)
    end

    ResetAction()
end

function Laning()

    local finalDesire = 0
    local finalAction = nil
    local finalActionTarget1 = nil
    local finalActionTarget2 = nil

    --move to lane pre horn
    if DotaTime() < 0 then
        desire = 5
        action = "MoveToLocation"
        actionTarget1 = GetLaneFrontLocation( GetTeam(), GetLane(), bot:GetAttackRange() * -1 )
    end

    --TP to tower while laning pre 10 mins
    if GetLane() == LANE_MID and DotaTime()/60 > 0 and DotaTime()/60 <= 100 then
        if GetTower(GetTeam(),TOWER_MID_1):IsAlive() then

            local tp = bot:GetItemInSlot(15);
            if tp ~= nil and tp:IsFullyCastable() and GetUnitToUnitDistance(bot, GetTower(GetTeam(),TOWER_MID_1)) > 4000 then
                --bot:Action_UseAbilityOnLocation(tp, GetTower(GetTeam(),TOWER_MID_1):GetLocation())
                if 10 > desire then
                    desire = 10
                    action = "UseAbilityOnLocation"
                    actionTarget1 = tp
                    actionTarget2 = GetTower(GetTeam(),TOWER_MID_1):GetLocation()
                end
            end

            --move to lane front
            if 5 > desire then
                desire = 5
                action = "MoveToLocation"
                actionTarget1 = GetLaneFrontLocation( GetTeam(), GetLane(), bot:GetAttackRange() * -1 )
            end

            --move near lowest hp enemy lane creep
            if 6 > desire then
                if GetUnitToLocationDistance(bot, GetLaneFrontLocation( GetTeam(), GetLane(), 0 ) ) < 2000 and GetLowestHpLaneCreeps(bot, true) ~= nil then
                    desire = 6
                    action = "MoveToLocation"
                    actionTarget1 = GetUnitsTowardsLocation(GetLowestHpLaneCreeps(bot, true), bot, bot:GetAttackRange() - 150) 
                end   
            end

            --retreat if there are no ally creeps
            if 7 > desire then
                if #bot:GetNearbyLaneCreeps(1600,false) <= 0 or bot:GetNearbyLaneCreeps(1600,false) == nil then
                    desire = 7
                    action = "MoveToLocation"
                    actionTarget1 =  GetTeamFountainLocation()
                end   
            end

            --prevent diving under the enemy tower
            if 7.1 > desire then
                if #bot:GetNearbyLaneCreeps(1600,false) <= 2 and GetUnitToLocationDistance(bot, GetTower(GetEnemyTeam(),TOWER_MID_1):GetLocation()) <= 700 then
                    desire = 7.1
                    action = "MoveToLocation"
                    actionTarget1 =  GetTeamFountainLocation()
                end   
            end

            --process last hitting
            --if GetLowestHpLaneCreeps(bot, true) ~= nil then
                --ProcessLastHitting(GetLowestHpLaneCreeps(bot, true))
            --end

            --TODO prioritize range creep last hit and deny especially under the tower

            --last hit creeps
            if 10 > desire then
                --if GetLowestHpLaneCreeps(bot, true) ~= nil and GetLowestHpLaneCreeps(bot, true):GetActualIncomingDamage( bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL ) > GetLowestHpLaneCreeps(bot, true):GetHealth() then
                if GetLowestHpLaneCreeps(bot, true) ~= nil then

                    local param1 = select(1, ProcessLastHitting(GetLowestHpLaneCreeps(bot, true)))
                    local param2 = select(2, ProcessLastHitting(GetLowestHpLaneCreeps(bot, true)))

                    if param1 == true then
                        desire = 10
                        action = "AttackUnit"
                        actionTarget1 =  param2
                    end

                end
            end

            --deny creeps
            if 10 > desire then
                --if GetLowestHpLaneCreeps(bot, false) ~= nil and GetLowestHpLaneCreeps(bot, false):GetActualIncomingDamage( bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL ) > GetLowestHpLaneCreeps(bot, false):GetHealth() then
                if GetLowestHpLaneCreeps(bot, false) ~= nil then 
                    if ProcessLastHitting(GetLowestHpLaneCreeps(bot, false)) == true then    
                        desire = 10
                        action = "AttackUnit"
                        actionTarget1 =  GetLowestHpLaneCreeps(bot, false)
                    end
                end
            end

            -- harass enemy hero --TODO retreat if can't fight
            if 9 > desire then
                local creeps = bot:GetNearbyLaneCreeps(501,true)
                local heros = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
                if (creeps == nil or #creeps == 0) and (heros ~= nil and #heros > 0) then
                    desire = 9
                    action = "AttackUnit"
                    actionTarget1 =  heros[1]
                end
            end
            
        end
    end

    --return finalDesire, finalAction, finalActionTarget1, finalActionTarget2

end

function ResetAction()
    desire = 0
    action = ""
    actionTarget1 = nil
    actionTarget2 = nil
end

function Farming()
    return 0
end

function GetLane()
    return LANE_MID
end

function GetLowestHpLaneCreeps(hUnit, bEnemy)
	local creep = nil
    local lowest = 10000

	for k,v in pairs(hUnit:GetNearbyLaneCreeps(1600,bEnemy))
	do
		if v then
			if GetHpPercentage(v) <= 70 and v:GetHealth() < lowest then
                creep = v
                lowest = v:GetHealth()
            end
		end
	end

	return creep
end

function GetNearestEnemyLaneCreeps(hUnit, bEnemy)
	local creep = nil
    local nearest = 10000

	for k,v in pairs(hUnit:GetNearbyLaneCreeps(1600,bEnemy))
	do
		if v then
			if v:DistanceFromFountain() < nearest then
                creep = v
                nearest = v:DistanceFromFountain()
            end
		end
	end

	return creep
end

function PointToPointDistance(a,b)
	local x1=a.x
	local x2=b.x
	local y1=a.y
	local y2=b.y
	return math.sqrt(math.pow((y2-y1),2)+math.pow((x2-x1),2))
end

function GetUnitsTowardsLocation(unit, target, nUnits)
	local vMyLocation,vTargetLocation = unit:GetLocation(),target:GetLocation()
	local tempvector = (vTargetLocation-vMyLocation) / PointToPointDistance(vMyLocation,vTargetLocation)
	return vMyLocation + nUnits * tempvector
end

function GetTeamFountainLocation()
    if GetTeam() == TEAM_RADIANT then
        return Vector(-6950,-6275)
    end
    return Vector(7150, 6300)

end

function GetEnemyTeam()
    if GetTeam() == TEAM_RADIANT then
        return TEAM_DIRE
    end
    return TEAM_RADIANT
end

function GetHpPercentage(hUnit)
    return (hUnit:GetHealth() / hUnit:GetMaxHealth()) * 100
end

function ProcessLastHitting(hUnit)

    local botAttackPoint = bot:GetAttackPoint();
    local botAttackProjectileSpeed = bot:GetAttackProjectileSpeed();
    local botAttackDamage = bot:GetAttackDamage();
    local botDistanceToAttackTarget = GetUnitToUnitDistance(bot, hUnit)
    local botAttackLandTime = (botAttackPoint + GetUnitToUnitFacingTime(bot, hUnit)) + (botDistanceToAttackTarget / botAttackProjectileSpeed)

    if (bot:GetAttackRange() ~= 150) then
        botAttackLandTime = (botAttackPoint + (botDistanceToAttackTarget / botAttackProjectileSpeed))
    end
      
      local attackers = {};
      
      local allyCreeps = bot:GetNearbyLaneCreeps(1599, false)
      for i, creep in pairs(allyCreeps) do
        if (creep:GetAttackTarget() == hUnit) then
          attackers[#attackers + 1] = creep;
        end
      end
      
      local enemyCreeps = bot:GetNearbyLaneCreeps(1599, true)
      for i, creep in pairs(enemyCreeps) do
        if (creep:GetAttackTarget() == hUnit) then
          attackers[#attackers + 1] = creep;
        end
      end

      local allyTowers = bot:GetNearbyTowers(1599, false)
      for i, tower in pairs(allyTowers) do
        if (tower:GetAttackTarget() == hUnit) then
          attackers[#attackers + 1] = tower;
        end
      end

      local enemyTowers = bot:GetNearbyTowers(1599, true)
      for i, tower in pairs(enemyTowers) do
        if (tower:GetAttackTarget() == hUnit) then
          attackers[#attackers + 1] = tower;
        end
      end

      local enemyHeroes = bot:GetNearbyHeroes(1599, true, BOT_MODE_NONE)
      for i, hero in pairs(enemyHeroes) do
        if (hero:GetAttackTarget() == hUnit) then
          attackers[#attackers + 1] = hero;
        end
      end

      -- Sort attackers by attackLandTime
      table.sort(attackers, function(a,b) return (a:GetAttackPoint() + GetAttackLandingTime(a,hUnit)) < (b:GetAttackPoint() + GetAttackLandingTime(a,hUnit)) end)
      
      local lastAttackTime = 0
      local lastAttackDamage = 0
      
        for _, attacker in pairs(attackers) do
            local attackPoint = attacker:GetAttackPoint()
            local attackProjectileSpeed = attacker:GetAttackProjectileSpeed()
            --print(attackProjectileSpeed .. "  " .. attacker:GetAttackRange())
            local attackDamage = attacker:GetAttackDamage()
            local totalDamage = lastAttackDamage + attackDamage
            local distanceToAttackTarget = GetUnitToUnitDistance(attacker, hUnit)
            local attackLandTime = attackPoint

            if (attacker:GetAttackRange() ~= 100 and attacker:GetAttackRange() ~= 150) then
                attackLandTime = (attackPoint + (distanceToAttackTarget / attackProjectileSpeed)) - 0.5
            end
            
            local futureDamage = totalDamage
            local futureHealth = (hUnit:GetHealth() + (attackLandTime * hUnit:GetHealthRegen())) - (futureDamage)

            --print("Attacker:" .. hUnit:GetUnitName() .. " " .. attackLandTime .. "  " .. attacker:GetHealth())
            --print("hUnit: " .. hUnit:GetHealth() .. "  " .. futureDamage .. "  " .. futureHealth)

            if ((futureHealth) < bot:GetAttackDamage()) then
                if (true) then
                    --print("TRUEEEEE")
                    return true, hUnit
                end
            end

        end

    if ((hUnit:GetHealth() + (hUnit:GetHealthRegen() * botAttackLandTime)) <= bot:GetAttackDamage()) then
        return true, hUnit
    end

    return false, nil

end

function GetAttackLandingTime(hAttacker, hUnit)
    local attackLandTime = 0
    local attackPoint = hAttacker:GetAttackPoint();
    local attackProjectileSpeed = hAttacker:GetAttackProjectileSpeed()
    local distanceToAttackTarget = GetUnitToUnitDistance(hAttacker, hUnit)
    attackLandTime = attackPoint
    if (hAttacker:GetAttackRange() ~= 100) then
        attackLandTime = attackPoint + (distanceToAttackTarget / attackProjectileSpeed)
    end
    return attackLandTime
end

function GetTableHighestValue(tTable)
    local highest = 0
    for _,i in pairs(tTable) do
        if i >= highest then
            highest = i
        end
    end
    return highest
end

function GetTableLowestValue(tTable)
    local lowest = 10000
    for _,i in pairs(tTable) do
        if i <= lowest then
            lowest = i
        end
    end
    return lowest
end

function GetTurnRateTime() --TODO
    return 0.26
end

function GetUnitToUnitFacingTime(hUnit1, hUnit2)

    local facingTime = GetTurnRateTime()
    
    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 11.5) == true then
        facingTime = 0
    end

    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 69.7) == false then
        facingTime = (facingTime / 5) 
    end

    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 139.4) == false then
        facingTime = (facingTime / 5) + (facingTime / 5) 
    end

    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 209.1) == false then
        facingTime = (facingTime / 5) + (facingTime / 5) + (facingTime / 5)
    end

    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 278.8) == false then
        facingTime = (facingTime / 5) + (facingTime / 5) + (facingTime / 5) + (facingTime / 5)
    end

    if hUnit1:IsFacingLocation(hUnit2:GetLocation(), 348.5) == false then
        facingTime = (facingTime / 5) + (facingTime / 5) + (facingTime / 5) + (facingTime / 5) + (facingTime / 5)
    end

    return facingTime

end
