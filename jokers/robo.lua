SMODS.Joker {
    key = "robo",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('robo')
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = false,
    blueprint_compat = true,
    config = {
        chips = 0,
        extra = 0
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.chips}
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if card.ability.extra == 0 then
                local id = context.other_card:get_id()
                if not context.other_card.debuff and id >= 2 and id <= 10 then
                    local chip_val = context.other_card:get_chip_bonus()
                    card.ability.extra = chip_val
                    card.ability.chips = card.ability.chips + card.ability.extra
                    return {
                        extra = {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.CHIPS,
                            focus = card
                        },
                        card = card
                    }
                end
            end
        end
        if context.end_of_round and not context.blueprint then
            card.ability.extra = 0
        end
        if context.joker_main then
            return {
                chips = card.ability.chips
            }
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                { text = "+" },
                { ref_table = "card.ability", ref_value = "chips", retrigger_type = "chips" }
            },
            text_config = { colour = G.C.CHIPS },
        }
    end
}
