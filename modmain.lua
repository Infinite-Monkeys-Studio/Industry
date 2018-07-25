modimport "create_tech_tree.lua"

PrefabFiles = 
{
  "autochest",
  "industrymachine",
  "worker",
}

Assets = 
{
  Asset("IMAGE", "images/inventoryimages/autochest.tex"),
  Asset("ATLAS", "images/inventoryimages/autochest.xml"),
  
  Asset("IMAGE", "images/inventoryimages/industrymachine.tex"),
  Asset("ATLAS", "images/inventoryimages/industrymachine.xml"),
  
  Asset("IMAGE", "images/inventoryimages/steam.tex"),
  Asset("ATLAS", "images/inventoryimages/steam.xml"),
  
  Asset("IMAGE", "images/hud/tab_industry.tex"),
  Asset("ATLAS", "images/hud/tab_industry.xml"),
  
  Asset("IMAGE", "images/minimap/industrymachine.tex"),
  Asset("ATLAS", "images/minimap/industrymachine.xml"),
  
  Asset("IMAGE", "images/minimap/autochest.tex"),
  Asset("ATLAS", "images/minimap/autochest.xml"),
  
  Asset("IMAGE", "images/minimap/steam.tex"),
  Asset("ATLAS", "images/minimap/steam.xml"),
}

-- THESE ARE JUST FOR TESTING
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require( 'debugkeys' )

local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local Ingredient = GLOBAL.Ingredient
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH

----------- global changes -------
--rec_str, rec_sort, rec_atlas, rec_icon, rec_owner_tag, rec_crafting_station
local industry_tab = AddRecipeTab("Industry", 998, "images/hud/tab_industry.xml", "tab_industry.tex", nil, true)

AddNewTechTree("INDUSTRY", 2)

AddMinimapAtlas("images/minimap/industrymachine.xml")
AddMinimapAtlas("images/minimap/autochest.xml")
AddMinimapAtlas("images/minimap/steam.xml")

---------------- Auto Chest -------------------
STRINGS.NAMES.AUTOCHEST = "Auto Chest"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AUTOCHEST = "Can be used by workers."
STRINGS.RECIPE_DESC.AUTOCHEST = "Can be used by workers."

local autochest = AddRecipe("autochest",
  {
    Ingredient("twigs",1),
    Ingredient("flint",1)
  }, 
  industry_tab, TECH.INDUSTRY_ONE, "autochest_placer", 1.6)
autochest.atlas = "images/inventoryimages/autochest.xml"
AddPrefabPostInit("autochest")

-------------- industry science machine ---------------------
STRINGS.NAMES.INDUSTRYMACHINE = "Industry Machine"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.INDUSTRYMACHINE = "Used to prototype Industry machines"
STRINGS.RECIPE_DESC.INDUSTRYMACHINE = "Used to prototype Industry machines"
STRINGS.UI.CRAFTING.INDUSTRY_ONE = "You need a Industry Machine to make it."

local industrymachine = AddRecipe("industrymachine",
  {
    Ingredient("twigs",1),
    Ingredient("flint",1)
  }, 
RECIPETABS.SCIENCE, TECH.SCIENCE_TWO, "industrymachine_placer", 1.6)
industrymachine.atlas = "images/inventoryimages/industrymachine.xml"
AddPrefabPostInit("industrymachine")


--------------- Steam Worker ------------------------------
STRINGS.NAMES.WORKER = "Steam Worker"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORKER = "The backbone of any industry."
STRINGS.RECIPE_DESC.WORKER = "automate stuff."

local steam = AddRecipe("steam",
  {
    Ingredient("twigs",1),
    Ingredient("flint",1)
  }, 
industry_tab, TECH.INDUSTRY_ONE, "steam_placer", 1.6)
steam.atlas = "images/inventoryimages/steam.xml"
AddPrefabPostInit("steam")

--------------- Electric Worker ------------------------------
STRINGS.NAMES.WORKER = "Electric Worker"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WORKER = "The backbone of any industry."
STRINGS.RECIPE_DESC.WORKER = "automate stuff."

local electric = AddRecipe("electric",
  {
    Ingredient("twigs",1),
    Ingredient("flint",1)
  }, 
industry_tab, TECH.INDUSTRY_ONE, "electric_placer", 1.6)
electric.atlas = "images/inventoryimages/electric.xml"
AddPrefabPostInit("electric")