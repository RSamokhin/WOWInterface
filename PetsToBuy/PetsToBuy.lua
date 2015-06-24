local EventWatcher = CreateFrame("Frame", "EventWatcher", UIParent);

local function EventHandler(self, event, ...)
   if ( AuctionatorLoaded ) then
      if ( not CollectionsJournal ) then
         CollectionsJournal_LoadUI();
      end
      C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true);
      C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, true);
      C_PetJournal.AddAllPetTypesFilter();
      C_PetJournal.AddAllPetSourcesFilter();
      PetJournalSearchBoxClearButton:Click();
      PetJournal_UpdatePetList();
      local slist = Atr_SList.FindByName("Pets to buy", nil);
      if ( not slist ) then
         slist = Atr_SList.create("Pets to buy", false, true);
      end
      slist:Clear();
      local numPets = C_PetJournal.GetNumPets();
      for i = 1, numPets do
         local _, _, owned, _, _, _, _, name, _, _, _, _, _, _, _, tradeable, _, _ = C_PetJournal.GetPetInfoByIndex(i);
         if (( not owned ) and ( tradeable )) then
            slist:AddItem("\""..name.."\"");
         end
      end
      Atr_Onclick_SaveTempList();
   end
end

EventWatcher:RegisterEvent("AUCTION_HOUSE_SHOW");
EventWatcher:SetScript("OnEvent", EventHandler);
