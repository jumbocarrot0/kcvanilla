SMODS.Joker {
    key = "powergrid",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('powergrid')
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    enhancement_gate = 'm_mult',
    config = {
        extra = 0.2
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        local xmult = 1 + card.ability.extra + ((G.GAME.current_round.kcv_mults_scored or 0) * card.ability.extra)
        return {
            vars = { card.ability.extra, xmult }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if SMODS.has_enhancement(other, 'm_mult') and not other.debuff then
                local xmult = 1 + ((G.GAME.current_round.kcv_mults_scored or 0) * card.ability.extra)
                return {
                    x_mult = xmult,
                    card = context.blueprint_card or card
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
                        { text = "X" },
                        { ref_table = "card.ability", ref_value = "jd_xmult", retrigger_type = "exp" }
                    }
                }
            },
            calc_function = function(card)
                local total = 1
                local mod = 1 + ((G.GAME.current_round.kcv_mults_scored or 0) * card.ability.extra)
                local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card.ability.name == 'Mult' and not scoring_card.debuff then
                        mod = mod + card.ability.extra
                        total = total * mod
                    end
                end
                if not next(G.play.cards) then
                    card.ability.jd_xmult = total
                end
            end
        }
    end
}
