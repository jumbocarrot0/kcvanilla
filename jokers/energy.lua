SMODS.Joker {
    key = "energy",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('energy')
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    enhancement_gate = 'm_wild',
    config = {
        kcv = {
            chips = 100,
            mult = 10,
            Xmult = 2,
            money = 5
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        return {
            vars = {card.ability.kcv.mult, card.ability.kcv.chips, card.ability.kcv.Xmult, card.ability.kcv.money}
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other.ability.name == 'Wild Card' and not other.debuff then
                local roll = pseudorandom_element({'amult', 'chips', 'xmult', 'money'})
                if roll == 'amult' then
                    return {
                        mult = card.ability.kcv.mult
                    }
                elseif roll == 'chips' then
                    return {
                        chips = card.ability.kcv.chips
                    }
                elseif roll == 'xmult' then
                    return {
                        xmult = card.ability.kcv.Xmult
                    }
                elseif roll == 'money' then
                    return {
                        dollars = card.ability.kcv.money
                    }
                end
            end
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
            },
            reminder_text = {
                { text = "+", colour = G.C.CHIPS },
                { ref_table = "card.ability.kcv", ref_value = "chips", colour = G.C.CHIPS },
                { text = " " },
                { text = "+", colour = G.C.MULT },
                { ref_table = "card.ability.kcv", ref_value = "mult", colour = G.C.MULT },
                { text = " " },
                {
                    border_nodes = {
                        { text = "X", colour = G.C.WHITE },
                        { ref_table = "card.ability.kcv", ref_value = "Xmult", colour = G.C.WHITE }
                    }
                },
                { text = " " },
                { text = "$", colour = G.C.GOLD },
                { ref_table = "card.ability.kcv", ref_value = "money", colour = G.C.GOLD },
            },
            calc_function = function(card)
                local count = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card.ability.name and scoring_card.ability.name == 'Wild Card' then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end

                card.joker_display_values.count = count
            end,
        }
    end
}
