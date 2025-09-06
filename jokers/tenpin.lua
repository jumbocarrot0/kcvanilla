SMODS.Joker {
    key = "tenpin",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('tenpin')
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        xmult = 1,
        hands_remaining = 0
    },
    loc_vars = function(self, info_queue, card)
        local remaining_txt
        if card.ability.hands_remaining > 0 then
            remaining_txt = localize {
                type = 'variable',
                key = 'kcv_active_for_X_more_hands',
                vars = {card.ability.hands_remaining}
            }
        else
            remaining_txt = localize('kcv_inactive')
        end
        return {
            vars = {remaining_txt}
        }
    end,
    calculate = function(self, card, context)
        if context.after and context.scoring_hand and not context.blueprint then
            local has_10
            for i, other_card in ipairs(context.scoring_hand) do
                if other_card:get_id() == 10 and not other_card.debuff then
                    has_10 = true
                    break
                end
            end
            if has_10 then
                card.ability.hands_remaining = 2
                card.ability.xmult = 2
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        local eval = function(card) return not card.REMOVED and card.ability.x_mult > 1 end
                        juice_card_until(card, eval, true)
                        return true
                    end
                }))
                return {
                    message = localize('k_active_ex')
                }
            else
                card.ability.hands_remaining = card.ability.hands_remaining - 1
                if card.ability.hands_remaining > 0 then
                    return {
                        message = localize{type='variable',key='a_remaining',vars={card.ability.hands_remaining}}
                    }
                elseif card.ability.xmult == 2 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            card.ability.xmult = 1
                            return true
                        end
                    }))
                    return {
                        message = localize('k_reset')
                    }
                end
            end
        end
        if context.joker_main and card.ability.xmult > 1 then
            return {
                xmult = card.ability.xmult,
            }
        end
    end,


    joker_display_def = function(JokerDisplay)
        ---@type JDJokerDefinition
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.ability", ref_value = "xmult", retrigger_type = "exp" }
                    }
                }
            },
        }
    end
}
