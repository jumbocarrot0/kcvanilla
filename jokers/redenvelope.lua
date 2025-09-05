SMODS.Joker {
    key = "redenvelope",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('redenvelope')
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    config = {
        extra = 8
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra * kcv_common_joker_count()}
        }
    end,
    calc_dollar_bonus = function(self, card)
        if G.GAME.blind.boss then
            return card.ability.extra * kcv_common_joker_count()
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                { text = "+$" },
                { ref_table = "card.joker_display_values", ref_value = "money" },
            },
            text_config = { colour = G.C.GOLD },
            reminder_text = {
                { ref_table = "card.joker_display_values", ref_value = "localized_text" },
            },
            calc_function = function(card)
                card.joker_display_values.money = card.ability.extra * kcv_common_joker_count()
                card.joker_display_values.localized_text = "(Boss Blind)"
            end
        }
    end
}
