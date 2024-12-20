AdditionalFieldInfo = {};
AdditionalFieldInfo.PrecisionFarming = "FS25_precisionFarming"
AdditionalFieldInfo.InfoMenu = "FS25_InfoMenu"


-- function AdditionalFieldInfo:loadedMission() --[[----------------------------------------------------------------]] print("This is a development version of AdditionalFieldInfo for FS22, which may and will contain bugs.") end
-- Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, AdditionalFieldInfo.loadedMission)

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

    for _, farmland in pairs(g_farmlandManager.farmlands) do
        local bFound = false
        local farmLandArea = 0.
        local fieldAreaSum = 0.
        local farmLandPrice = 0.
        local isOwned = false
        if farmland.id ~= nil then
            if farmland.id == data.farmlandId then
                bFound = true
                if farmland.field ~= nil then
                    local areaInHa =  g_i18n:formatArea(farmland.field.areaHa, 2)
                    fieldAreaSum = fieldAreaSum + farmland.field.areaHa
                    local Field_xx_Area = string.format(g_i18n:getText("additionalFieldInfo_FIELD_AREA"), farmland.id)
                    box:addLine(Field_xx_Area, areaInHa)
                end
                farmLandPrice = farmland.price
                isOwned = farmland.isOwned
                if data.lastFruitTypeIndex ~= nil then
                    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(data.lastFruitTypeIndex)
                    local fruitGrowthState = data.lastGrowthState
                    if fruitType ~= nil and farmland.field ~= nil then
                        if fruitType.growthStateToName[fruitGrowthState] == "harvestReady" then
                            local harvestMultiplier = data:getHarvestScaleMultiplier()

                            -- print("multiplier "..tostring(harvestMultiplier))
                            
                            local fillType = g_fruitTypeManager:getFillTypeByFruitTypeIndex(fruitType.index)
                            local massPerLiter = fillType.massPerLiter
                            local literPerSqm = fruitType.literPerSqm
                            -- Display Potential harvest quantity
                            local Potential_Harvest = g_i18n:getText("additionalFieldInfo_POTENTIAL_HARVEST")
                            local potentialHarvestQty = literPerSqm * farmland.field.areaHa * harvestMultiplier * 10000 -- ha to sqm
                            -- potentialHarvestQty = g_missionManager:testHarvestField(farmland)
                                -- local harvestMission = g_missionManager.fieldToMission[farmland.farmland.fieldId]
                                -- if harvestMission then
                                --     potentialHarvestQty = harvestMission:getMaxCutLiters()
                                --     -- print("harvestMission: "..tostring(potentialHarvestQty))
                                -- endActionEventsModification
                            box:addLine(Potential_Harvest, g_i18n:formatVolume(potentialHarvestQty, 0))
    
                            -- Display Potential yield
                            local Potential_Yield = g_i18n:getText("additionalFieldInfo_POTENTIAL_YIELD")
                            local potentialYield = (potentialHarvestQty * massPerLiter) / g_i18n:getArea(farmland.field.areaHa)
                            box:addLine(Potential_Yield, string.format("%1.2f T/"..tostring(g_i18n:getAreaUnit()), potentialYield))
                        end
                    end
                end
            end
        end
        if bFound then
            local farmland = g_farmlandManager:getFarmlandById(data.farmlandId)
            if farmland ~= nil then
                local Farm_Land_Area = g_i18n:getText("additionalFieldInfo_FARMLAND_AREA")
                farmLandArea =  g_i18n:formatArea(farmland.areaInHa, 2)
                box:addLine(Farm_Land_Area, farmLandArea)
                if fieldAreaSum > 0. and not isOwned then
                    local areaUnit = tostring(g_i18n:getAreaUnit())
                    local pricePerArea = farmLandPrice / g_i18n:getArea(fieldAreaSum)
                    local Price_On_Area = string.format(g_i18n:getText("additionalFieldInfo_PRICE_ON_AREA"), g_i18n:getAreaUnit())
                    -- Display Price per ha (per ac) of the cultivated area on land you don't own
                    box:addLine(Price_On_Area, g_i18n:formatMoney(pricePerArea, 0)..'/'..areaUnit)
                end
            end
            break
        end
    end
end
PlayerHUDUpdater.fieldAddFarmland = Utils.appendedFunction(PlayerHUDUpdater.fieldAddFarmland, AdditionalFieldInfo.fieldAddFarmland)
