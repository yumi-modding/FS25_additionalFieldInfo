AdditionalFieldInfo = {};
AdditionalFieldInfo.PrecisionFarming = "FS25_precisionFarming"
AdditionalFieldInfo.InfoMenu = "FS25_InfoMenu"


function AdditionalFieldInfo:loadedMission() print("This is a development version of AdditionalFieldInfo for FS25, which may and will contain bugs.") end
Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, AdditionalFieldInfo.loadedMission)

function AdditionalFieldInfo:buildFarmlandsMapOverlay(selectedFarmland)
    -- print("AdditionalFieldInfo:buildFarmlandsMapOverlay")
    if selectedFarmland then
        local farmLandArea =  g_i18n:formatArea(selectedFarmland.areaInHa, 2)
        self.selectedFarmlandAreaInHa = farmLandArea
    end
end
-- MapOverlayGenerator.buildFarmlandsMapOverlay = Utils.appendedFunction(MapOverlayGenerator.buildFarmlandsMapOverlay, AdditionalFieldInfo.buildFarmlandsMapOverlay)

function AdditionalFieldInfo:onFarmlandOverlayFinished(a, b, c, d)
    -- print("AdditionalFieldInfo:onFarmlandOverlayFinished")
    if not g_modIsLoaded[AdditionalFieldInfo.InfoMenu] then
        if self.mapOverlayGenerator.selectedFarmlandAreaInHa then
            if self.areaText == nil then
                local areaLabel = self.farmlandValueText:clone(self)
                self.farmlandValueText.parent:addElement(areaLabel)
                -- areaLabel:setBold(false)
                areaLabel:setText(g_i18n:getText("additionalFieldInfo_AREA")..":")
                areaLabel:applyProfile("ingameMenuMapMoneyLabel")
                areaLabel:setTextColor(1, 1, 1, 1)
                self.areaLabel = areaLabel
                local areaText = self.farmlandValueText:clone(self)
                self.farmlandValueText.parent:addElement(areaText)
                areaText:setText(self.mapOverlayGenerator.selectedFarmlandAreaInHa)
                areaText:applyProfile(InGameMenuMapFrame.PROFILE.MONEY_VALUE_NEUTRAL)
                self.areaText = areaText
                -- areaLabel:setTextColor(1, 1, 1, 1)
                areaText:setPosition(0.06, 0.04)
                areaLabel:setPosition(0, 0.04)
                -- local selfX, selfY = areaLabel:getPosition()
                -- print(string.format("Label x: %s, y: %s", selfX, selfY))
                -- local selfX, selfY = areaText:getPosition()
                -- print(string.format("Text  x: %s, y: %s", selfX, selfY))
            else
                local areaText = self.areaText
                local areaLabel = self.areaLabel
                areaText:setVisible(false)
                areaLabel:setVisible(false)
                areaText:setPosition(0.06, 0.04)
                areaLabel:setPosition(0, 0.04)
                areaText:setText(self.mapOverlayGenerator.selectedFarmlandAreaInHa)
                areaText:setVisible(true)
                areaLabel:setVisible(true)
            end
        else
            if self.areaText then
                self:removeElement(self.areaText)
            end
            if self.areaLabel then
                self:removeElement(self.areaLabel)
            end
        end
    end
end
-- InGameMenuMapFrame.onFarmlandOverlayFinished = Utils.prependedFunction(InGameMenuMapFrame.onFarmlandOverlayFinished, AdditionalFieldInfo.onFarmlandOverlayFinished)

function AdditionalFieldInfo:fieldAddFarmland(data, box)
    -- print("AdditionalFieldInfo:fieldAddFarmland")
    if self.currentField == nil then self.currentField = 4 end
    -- DebugUtil.printTableRecursively(data, " ", 1, 3)
    -- print("---------------")
    -- DebugUtil.printTableRecursively(box, " ", 1, 3)
    for _, farmLand in pairs(g_fieldManager.farmlandIdFieldMapping) do
        local bFound = false
        local farmLandArea = 0.
        local fieldAreaSum = 0.
        local farmLandPrice = 0.
        local isOwned = false
        if farmLand.farmland.id ~= nil then
            print("farmLand id:")
            print(farmLand.farmland.id) --.famrland.id)
            print("farmLand areaHa:")
            print(farmLand.areaHa) --.famrland.id)
            print("farmLand areaInHa:")
            print(farmLand.farmland.areaInHa) --.famrland.id)
            if farmLand.farmland.id == data.farmlandId then
                print("Found current farmland: ")
                print(data.farmlandId)
                bFound = true
                local areaInHa =  g_i18n:formatArea(farmLand.areaHa, 2)
                fieldAreaSum = fieldAreaSum + farmLand.areaHa
                -- farmLandArea =  g_i18n:formatArea(farmLand.farmland.areaInHa, 2)
                farmLandPrice = farmLand.farmland.price
                isOwned = farmLand.farmland.isOwned
                local Field_xx_Area = string.format(g_i18n:getText("additionalFieldInfo_FIELD_AREA"), farmLand.farmland.id)
                box:addLine(Field_xx_Area, areaInHa)
                -- local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
                -- box:addLine(Farm_Land_Area, farmLandArea)
                if data.lastFruitTypeIndex ~= nil then
                    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(data.lastFruitTypeIndex)
                    local fruitGrowthState = data.lastGrowthState
                    if fruitType ~= nil then
                        -- DebugUtil.printTableRecursively(fruitType, " ", 1, 3)
                        if fruitType.growthStateToName[fruitGrowthState] == "harvestReady" then
                            local sprayFactor = data.sprayLevel
                            local plowFactor = data.plowLevel
                            local limeFactor = 1 - data.limeLevel
                            local weedFactor = data.weedFactor
                            local stubbleFactor = data.stubbleShredLevel
                            local rollerFactor = 1 - data.rollerLevel
                            local stoneFactor = data.stoneLevel
                            local missionInfo = g_currentMission.missionInfo
                
                            if not missionInfo.plowingRequiredEnabled then
                                plowFactor = 1
                            end
                
                            if not missionInfo.limeRequired then
                                limeFactor = 1
                            end
                
                            if not missionInfo.weedsEnabled then
                                weedFactor = 1
                            end

                            if not missionInfo.stonesEnabled then
                                stoneFactor = 1
                            end
                            local harvestMultiplier = g_currentMission:getHarvestScaleMultiplier(fruitType, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, 0)
                            -- print("multiplier "..tostring(harvestMultiplier))
                            local fillType = g_fruitTypeManager:getFillTypeByFruitTypeIndex(fruitType.index)
                            local massPerLiter = fillType.massPerLiter
                            local literPerSqm = fruitType.literPerSqm
                            -- Display Potential harvest quantity
                            local Potential_Harvest = g_i18n:getText("additionalFieldInfo_POTENTIAL_HARVEST")
                            local potentialHarvestQty = literPerSqm * farmLand.areaHa * harvestMultiplier * 10000 -- ha to sqm
                            -- potentialHarvestQty = g_missionManager:testHarvestField(farmland)
                                -- local harvestMission = g_missionManager.fieldToMission[farmland.fieldId]
                                -- if harvestMission then
                                --     potentialHarvestQty = harvestMission:getMaxCutLiters()
                                --     -- print("harvestMission: "..tostring(potentialHarvestQty))
                                -- endActionEventsModification
                            box:addLine(Potential_Harvest, g_i18n:formatVolume(potentialHarvestQty, 0))
    
                            -- Display Potential yield
                            local Potential_Yield = g_i18n:getText("additionalFieldInfo_POTENTIAL_YIELD")
                            local potentialYield = (potentialHarvestQty * massPerLiter) / g_i18n:getArea(farmLand.areaHa)
                            box:addLine(Potential_Yield, string.format("%1.2f T/"..tostring(g_i18n:getAreaUnit()), potentialYield))
                            -- lastGrowthState :: 0
                            -- sprayType :: 1
                            -- stubbleShredLevel :: 0
                            -- growthState :: 0
                            -- lastFruitTypeIndex :: 0
                            -- limeLevel :: 0
                            -- ownerFarmId :: 1
                            -- weedState :: 0
                            -- isValid :: true
                            -- stoneLevel :: 0
                            -- farmlandId :: 4
                            -- weedFactor :: 0
                            -- sprayLevel :: 0
                            -- fruitTypeIndex :: 0
                            -- rollerLevel :: 0
                            -- plowLevel :: 0
                            -- waterLevel :: 0
                            -- groundType :: 5
                            -- box:addLine("harvestReady", g_i18n:formatArea(harvestMultiplier, 2))
                        end
                    end
                    -- if fruitType.minHarvestingGrowthState <= fruitGrowthState and fruitGrowthState <= fruitType.maxHarvestingGrowthState then
                    --     print("fruitype ready for harvest")
                    -- end
                end
            end
        else
            print("farmLand id is nil:")
            print(farmLand.areaHa) --.famrland.id)
        end
        if bFound then
            local farmland = g_farmlandManager:getFarmlandById(data.farmlandId)
            if farmland ~= nil then
                local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
                farmLandArea =  g_i18n:formatArea(farmland.areaInHa, 2)
                box:addLine(Farm_Land_Area, farmLandArea)
                if fieldAreaSum > 0. and not farmland.isOwned then
                    local areaUnit = tostring(g_i18n:getAreaUnit())
                    local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
                    local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
                    -- Display Price per ha (per ac) of the cultivated area on land you don't own
                    box:addLine(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..areaUnit)
                end
            end
            break
        end
        -- for fieldIndex, farmland in pairs(farmLand) do
        --     print(farmland)
        --     print(data.farmlandId)
        --     if farmland == data.farmlandId then
        --         if self.currentField > (4 * #farmLand + 2) then self.currentField = 4 end
        --         if fieldIndex == math.floor(self.currentField / 4) then
        --             bFound = true
        --             local areaInHa =  g_i18n:formatArea(farmland.areaInHa, 2)
        --             fieldAreaSum = fieldAreaSum + farmland.areaInHa
        --             farmLandArea =  g_i18n:formatArea(farmland.farmland.areaInHa, 2)
        --             farmLandPrice = farmland.farmland.price
        --             isOwned = farmland.farmland.isOwned
        --             local Field_xx_Area = string.format(g_i18n:getText("additionalFieldInfo_FIELD_AREA"), farmland.fieldId)
        --             -- if not g_modIsLoaded[AdditionalFieldInfo.PrecisionFarming] then
        --             -- Display Area of each field in the current land
        --             box:addLine(Field_xx_Area, areaInHa)
        --             -- end

        --             if data.fruitTypeMax ~= nil then
        --                 local fruitType = g_fruitTypeManager:getFruitTypeByIndex(data.fruitTypeMax)
        --                 local fruitGrowthState = data.fruitStateMax
        --                 if fruitType.minHarvestingGrowthState <= fruitGrowthState and fruitGrowthState <= fruitType.maxHarvestingGrowthState then

        --                     local sprayFactor = data.fertilizerFactor
        --                     local plowFactor = data.plowFactor
        --                     local limeFactor = 1 - data.needsLimeFactor
        --                     local weedFactor = data.weedFactor
        --                     local stubbleFactor = data.stubbleFactor
        --                     local rollerFactor = 1 - data.needsRollingFactor
        --                     local missionInfo = g_currentMission.missionInfo
                
        --                     if not missionInfo.plowingRequiredEnabled then
        --                         plowFactor = 1
        --                     end
                
        --                     if not missionInfo.limeRequired then
        --                         limeFactor = 1
        --                     end
                
        --                     if not missionInfo.weedsEnabled then
        --                         weedFactor = 1
        --                     end
        --                     local harvestMultiplier = g_currentMission:getHarvestScaleMultiplier(fruitType, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, 0)

        --                 end
        --             end
        --         end
        --     end
        -- end
        -- if bFound then
        --     self.currentField = self.currentField + 1
        --     local farmland = g_farmlandManager:getFarmlandById(data.farmlandId)
        --     if farmland ~= nil then
        --         local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
        --         farmLandArea =  g_i18n:formatArea(farmland.areaInHa, 2)
        --         box:addLine(Farm_Land_Area, farmLandArea)
        --         if fieldAreaSum > 0. and not farmland.isOwned then
        --             local areaUnit = tostring(g_i18n:getAreaUnit())
        --             local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
        --             local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
        --             -- Display Price per ha (per ac) of the cultivated area on land you don't own
        --             box:addLine(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..areaUnit)
        --         end
        --     end
        --     break
        -- end
    end
end
PlayerHUDUpdater.fieldAddFarmland = Utils.appendedFunction(PlayerHUDUpdater.fieldAddFarmland, AdditionalFieldInfo.fieldAddFarmland)
