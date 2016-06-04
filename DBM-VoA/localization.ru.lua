﻿if GetLocale() ~= "ruRU" then return end

local L

----------------------------------
--  Archavon the Stone Watcher  --
----------------------------------
L = DBM:GetModLocalization("Archavon")

L:SetGeneralLocalization({
	name = "Аркавон Страж Камня"
})

L:SetWarningLocalization({
	WarningGrab	= "Аркавон хватает |3-1(>%s<)"
})

L:SetTimerLocalization({
	ArchavonEnrage	= "Берсерк Аркавона"
})

L:SetMiscLocalization({
	TankSwitch	= "%%s бросается к (%S+)!"
})

L:SetOptionLocalization({
	WarningGrab		= "Объявлять о захвате цели",
	ArchavonEnrage	= "Отсчет времени до $spell:26662"
})

--------------------------------
--  Emalon the Storm Watcher  --
--------------------------------
L = DBM:GetModLocalization("Emalon")

L:SetGeneralLocalization{
	name = "Эмалон Страж Бури"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
	timerMobOvercharge	= "Взрыв в результате перегрузки",
	EmalonEnrage		= "Берсерк Эмалона"
}

L:SetOptionLocalization{
	timerMobOvercharge	= "Отсчет времени для моба с Перегрузкой (стакающего дебафф)",
	EmalonEnrage		= "Отсчет времени до $spell:26662",
	RangeFrame			= "Показывать окно проверки дистанции (10)"
}

---------------------------------
--  Koralon the Flame Watcher  --
---------------------------------
L = DBM:GetModLocalization("Koralon")

L:SetGeneralLocalization{
	name = "Коралон Страж Огня"
}

L:SetWarningLocalization{
	BurningFury		= "Пылающая ярость >%d<"
}

L:SetTimerLocalization{
	KoralonEnrage	= "Берсерк Коралона"
}

L:SetOptionLocalization{
	BurningFury			= "Предупреждение для $spell:66721",
	KoralonEnrage		= "Отсчет времени до $spell:26662"
}

L:SetMiscLocalization{
	Meteor	= "%s применяет заклинание \"Кулаки-метеоры\"!"
}

-------------------------------
--  Toravon the Ice Watcher  --
-------------------------------
L = DBM:GetModLocalization("Toravon")

L:SetGeneralLocalization{
	name = "Торавон Страж Льда"
}

L:SetWarningLocalization{
	Frostbite	= "Обморожение на |3-5(>%s<) (%d)"
}

L:SetTimerLocalization{
	ToravonEnrage	= "Берсерк Торавона"
}

L:SetOptionLocalization{
	Frostbite	= "Предупреждение для $spell:72004"
}

L:SetMiscLocalization{
	ToravonEnrage	= "Отсчет времени до Берсерка"
}