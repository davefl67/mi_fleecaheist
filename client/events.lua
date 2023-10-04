local debug = CG.debug
local resourceName = GetCurrentResourceName()
FH = {}
FH.chosenbank = nil
FH.inprogress = false

local blip

local timer = false
local cool = CG.heistcooldown
local function cooldown(choice)
    timer = true
    SetTimeout(cool * 60000, function()
        timer = false
        FH.inprogress = false
        UT.mfhnotify('fleecareset', 'Time limit reached', 'Fleeca systems reset')
        TriggerEvent('mifh:reset:all', choice)
    end)
end

RegisterCommand('dodoor', function()
    TriggerEvent('mifh:start:vault', BK.banks.legion)
end, false)

local function heiststartloc()
    exports.ox_target:addBoxZone({
        coords = CG.start.loc,
        size = CG.start.size,
        rotation = CG.start.head,
        debug = Debug,
        options = {
            {
                name = 'fleecastart',
                icon = 'fa-solid fa-ticket',
                label = 'Pick bank location',
                canInteract = function(_, distance)
                    return distance < 2.0 and not FH.inprogress
                end,
                onSelect = function()
                    lib.showContext('fleecaheist_menu')
                end,
            },
        }

    })
end

RegisterCommand('drilltest', function()
    local choice = BK.banks.legion
    TriggerEvent('mifh:start:vault', choice)
end, false)

---@param bank 'alta' | 'legion' | 'burton' | 'delperro' | 'chumash' | 'harmony'
local startRobbery = function(bank)
    if not timer then
        FH.chosenbank, FH.inprogress = BK.banks[bank], true;
        local bloc = FH.chosenbank.vaultdoor.loc
        blip = AddBlipForCoord(bloc.x, bloc.y, bloc.z)
        UT.mfhroute(blip)
        UT.mfhnotify('fleecastart', 'CNS: Bank system isolated', 'time to heist some money')
        TriggerEvent('mifh:start:mngr', FH.chosenbank)
        TriggerEvent('mifh:start:security', FH.chosenbank)
        TriggerEvent('mifh:start:vault', FH.chosenbank)
        TriggerEvent('mifh:start:trollys', FH.chosenbank)
        cooldown(FH.chosenbank)
        UT.mfhremove_blip(blip)
    end
end

lib.registerContext({
    id = 'fleecaheist_menu',
    title = 'Darkweb: Fleeca Heist Plan',
    options = {
        {
            title = 'Fleeca: location #1',
            description = 'Los Santos, Alta St & Harwick Ave',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('alta');
            end,
        },
        {
            title = 'Fleeca: location #2',
            description = 'Los Santos, Mission Row & Straberry Ave',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('legion');
            end,
        },
        {
            title = 'Fleeca: location #3',
            description = 'Los Santos, Burton St & San Vitus Blvd',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('burton');
            end,
        },
        {
            title = 'Fleeca: location #4',
            description = 'Los Santos, Rockford Hills & Blvd Del Perro',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('delperro');
            end,
        },
        {
            title = 'Fleeca: location #5',
            description = 'Chumash, Banham Canyon & Great Ocean Highway',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('chumash');
            end,
        },
        {
            title = 'Fleeca: location #6',
            description = 'Harmony, Route 68 & Grand Senora Desert',
            icon = 'piggy-bank',
            onSelect = function()
                startRobbery('harmony');
            end,
        },
    }
});

AddEventHandler('mifh:reset:all', function(choice)
    TriggerEvent('mifh:reset:mngr', choice)
    TriggerEvent('mifh:reset:security', choice)
    TriggerEvent('mifh:reset:vault', choice)
    TriggerEvent('mifh:reset:trollys', choice)
end)

--[[

RegisterCommand('breset', function(choice)
    TriggerEvent('mifh:reset:mngr', choice)
    TriggerEvent('mifh:reset:security', choice)
    TriggerEvent('mifh:reset:vault', choice)
    TriggerEvent('mifh:reset:trollys', choice)
end, false)

RegisterCommand('bstart1', function()
    FH.inprogress = true
    FH.chosenbank = BK.banks.alta
    TriggerEvent('mifh:start:mngr', FH.chosenbank)
    TriggerEvent('mifh:start:security', FH.chosenbank)
    TriggerEvent('mifh:start:vault', FH.chosenbank)
    TriggerEvent('mifh:start:trollys', FH.chosenbank)
end, false)

RegisterCommand('bstart2', function()
    FH.inprogress = true
    FH.chosenbank = BK.banks.legion
    TriggerEvent('mifh:start:mngr', FH.chosenbank)
    TriggerEvent('mifh:start:security', FH.chosenbank)
    TriggerEvent('mifh:start:vault', FH.chosenbank)
    TriggerEvent('mifh:start:trollys', FH.chosenbank)
end, false)
]]

Citizen.CreateThread(function()
    if resourceName == GetCurrentResourceName() then
        if not FH.inprogress then
            heiststartloc()
        else
            return end
        Citizen.Wait(1000)
    end
end)