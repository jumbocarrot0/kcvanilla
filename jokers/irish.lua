SMODS.Joker {
    key = "irish",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('irish')
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    enhancement_gate = 'm_lucky',
    config = {
        factor = 3
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return {
            vars = {card.ability.factor}
        }
    end,
    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint then
            local lucky_card = context.trigger_obj
            local is_lucky_event = context.identifier == 'lucky_mult' or context.identifier == 'lucky_money'
            if lucky_card and lucky_card.is_suit and lucky_card:is_suit("Clubs") and is_lucky_event then
                return {
                    numerator = context.numerator * card.ability.factor
                }
            end
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                {
                    border_nodes = {
                        { ref_table = "card.ability", ref_value = "factor", retrigger_type = "exp" },
                        { text = "X" }
                    },
                    border_colour = G.C.CHANCE
                },
                { text = " " },
                { ref_table = "card.joker_display_values", ref_value = "clubs", retrigger_type = "exp", colour = G.C.SUITS.Clubs },
                { text = " " },
                { ref_table = "card.joker_display_values", ref_value = "lucky_card", retrigger_type = "exp", colour = G.C.IMPORTANT },
            },
            calc_function = function(card)
                card.joker_display_values.lucky_card = localize { type = 'name_text', set = 'Enhanced', key = 'm_lucky' }
                card.joker_display_values.clubs = localize("Clubs", "suits_singular")
            end
        }
    end
}
