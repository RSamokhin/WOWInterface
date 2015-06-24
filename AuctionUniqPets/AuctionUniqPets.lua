local AuctionUniqPets = CreateFrame("Frame", "AuctionUniqPets");

local origSetBuyData = AuctionLite.SetBuyData;
function AuctionLite.SetBuyData(...)
    local _, results = ...;    
    local petsNames = {};

    if AuctionLite_AdvSearch ~= nil 
        and AuctionLite_AdvSearch.Cat == 11 
        and AuctionLite_AdvSearch.Usable ~= nil
        and AuctionLite_AdvSearch.Usable then
        petsNames = AuctionUniqPets:GetNamesOfOwnedPets();
    end
    
    local petsNamesCount = #petsNames;
    if petsNamesCount > 0 then
        local newResults = {};
        for link, result in pairs(results) do
            local isOwnedPet = false;
            for i = 1, petsNamesCount do
                if petsNames[i] == AuctionLite.SplitLink(_, link) then
                    isOwnedPet = true;
                    break;
                end
            end 
            if not isOwnedPet then
                newResults[link] = result;
            end             
        end
        origSetBuyData(_, newResults);                
    else
        origSetBuyData(_, results);
    end 
end

function AuctionUniqPets:GetPets()
    local server = _G.C_PetJournal
    local pets = {}
    local total = server.GetNumPets()

    if total > 0 then
        for i = 1, total do
            local petID, speciesID, isOwned, customName, level, isFavorite, 
                isRevoked, speciesName, icon, petType, companionID, tooltip, 
                description, isWild, isCanBattle, isTradeable, isUnique, isObtainable = server.GetPetInfoByIndex(i)
            local pet = 
            {
                PetID = petID,
                SpeciesID = speciesID,
                CompanionID = companionID,
                CustomName = customName,
                SpeciesName = speciesName,
                PetType = petType,
                Level = level,
                Icon = icon,
                Tooltip = tooltip,
                Description = description,
                IsOwned = isOwned,
                IsFavorite = isFavorite,
                IsRevoked = isRevoked,
                IsWild = isWild,
                IsTradeable = isTradeable,
                IsUnique = isUnique,
                IsCanBattle = isCanBattle,
                IsObtainable = isObtainable,
            }
            table.insert(pets, pet)
        end
    end

    return pets
end

function AuctionUniqPets:GetOwnedPets()
    local pets = {}
    local totalPets = self:GetPets()
    local total = #totalPets

    if total > 0 then
        for i = 1, total do
            local pet = totalPets[i]
            if pet.IsOwned then
                table.insert(pets, pet)
            end
        end
    end

    return pets
end

function AuctionUniqPets:GetNamesOfOwnedPets()
    local names = {}
    local pets = self:GetOwnedPets()
    local total = #pets

    if total > 0 then
        for i = 1, total do
            table.insert(names, pets[i].SpeciesName)
        end
    end

    return names
end