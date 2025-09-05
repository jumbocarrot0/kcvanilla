SMODS.Joker {
    key = "rakugo",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('rakugo')
    },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {},
    loc_vars = function(self, info_queue, card)
        return {}
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card and context.poker_hands then
            if next(context.poker_hands["Straight"]) then
                local rank = context.other_card:get_id()
                if rank == 4 or rank == 5 or rank == 6 or rank == 7 or rank == 8 then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = card
                    }
                end
            end
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "four", colour = G.C.ORANGE },
                { text = "," },
                { ref_table = "card.joker_display_values", ref_value = "five", colour = G.C.ORANGE },
                { text = "," },
                { ref_table = "card.joker_display_values", ref_value = "six", colour = G.C.ORANGE },
                { text = "," },
                { ref_table = "card.joker_display_values", ref_value = "seven", colour = G.C.ORANGE },
                { text = "," },
                { ref_table = "card.joker_display_values", ref_value = "eight", colour = G.C.ORANGE },
                { text = ")" },
            },
            text_config = { colour = G.C.GREY, scale = 0.5 },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
                { text = ")" },
            },
            calc_function = function(card)
                card.joker_display_values.four = localize("4", 'ranks')
                card.joker_display_values.five = localize("5", 'ranks')
                card.joker_display_values.six = localize("6", 'ranks')
                card.joker_display_values.seven = localize("7", 'ranks')
                card.joker_display_values.eight = localize("8", 'ranks')
                card.joker_display_values.localized_text = localize("Straight", 'poker_hands')
            end
        }
    end
}
