--- STEAMODDED HEADER
--- MOD_NAME: KCVanilla
--- MOD_ID: KCVanilla
--- MOD_DESCRIPTION: KCVanilla
--- MOD_AUTHOR: [krackocloud]
--- LOADER_VERSION_GEQ: 1.0.0
SMODS.Atlas {
    key = 'kcvanillajokeratlas',
    path = "jokeratlas.png",
    px = 71,
    py = 95
}

function kcv_log(str)
    sendInfoMessage(str, "KCVanilla")
end

local kcv_jokerAtlasOrder = {'5day', 'chan', 'swiss', 'collapse', 'energy', 'fortunecookie', 'guard', 'irish',
                             'composition', 'powergrid', 'redenvelope', 'robo', 'handy', 'squid', 'tenpin'}

local function kcv_getJokerAtlasIndex(jokerKey)
    for i, v in ipairs(kcv_jokerAtlasOrder) do
        if v == jokerKey then
            return i - 1
        end
    end
    return 0
end

function kcv_dump(o, depth)
    depth = depth or 0
    if depth > 3 then
        return '...'
    end
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. kcv_dump(v, depth + 1) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- function kcv_plus_chips(amt, card)
--     if (amt == 0) then
--         return
--     end
--     hand_chips = mod_chips(hand_chips + amt)
--     update_hand_text({
--         delay = 0
--     }, {
--         chips = hand_chips
--     })
--     card_eval_status_text(card, 'chips', nil, nil, nil, {
--         message = localize {
--             type = 'variable',
--             key = 'a_chips',
--             vars = {amt}
--         },
--         colour = G.C.CHIPS
--     });
-- end

-- function kcv_plus_mult(amt, card)
--     if (amt == 0) then
--         return
--     end
--     mult = mod_mult(mult + amt)
--     update_hand_text({
--         delay = 0
--     }, {
--         mult = mult
--     })
--     card_eval_status_text(card, 'mult', nil, nil, nil, {
--         message = localize {
--             type = 'variable',
--             key = 'a_mult',
--             vars = {amt}
--         },
--         colour = G.C.MULT
--     });
-- end

local function kcv_composition_calc_effect(card)
    if not G.jokers then
        -- viewing card outside a run
        return {
            chips = 0,
            mult = 0
        }
    end
    local my_pos = nil
    local cards_to_left = 0
    local cards_to_right = 0
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
            my_pos = i
        elseif my_pos == nil then
            cards_to_left = cards_to_left + 1
        else
            cards_to_right = cards_to_right + 1
        end
    end
    local chips = cards_to_right * 30
    local mult = cards_to_left * 4
    if my_pos == nil then
        chips = 0
        mult = 0
    end
    return {
        chips = chips,
        mult = mult
    }
end

SMODS.Joker {
    key = "composition",
    name = "Composition",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('composition')
    },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            chips = 0,
            mult = 0
        }
    },
    loc_txt = {
        name = "Composition",
        text = {"+4 Mult for each Joker to the left,", "+30 Chips for each Joker to the right",
                "(Currently +#1# Mult and +#2# Chips)"}
    },
    loc_vars = function(self, info_queue, card)
        local effect = kcv_composition_calc_effect(card)
        return {
            vars = {effect.mult, effect.chips}
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local effect = kcv_composition_calc_effect(card)
            aChips(effect.chips, card, context)
            aMult(effect.mult, card, context)
        end
    end
}

SMODS.Joker {
    key = "fortunecookie",
    name = "Fortune Cookie",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('fortunecookie')
    },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            chips = 150,
            chip_mod = 50
        }
    },
    loc_txt = {
        name = "Fortune Cookie",
        text = {"+#1# Chips,", "-#2# Chips when", "Tarot card is used"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.chips, card.ability.extra.chip_mod}
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and (context.consumeable.ability.set == "Tarot") and not context.blueprint then
            local new_chip_val = card.ability.extra.chips - card.ability.extra.chip_mod
            if (new_chip_val > 0) then
                card.ability.extra.chips = new_chip_val
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize {
                        type = 'variable',
                        key = 'a_chips_minus',
                        vars = {card.ability.extra.chip_mod}
                    },
                    colour = G.C.CHIPS
                });
            else
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        G.jokers:remove_card(card)
                        card:remove()
                        card = nil
                        return true;
                    end
                }))
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.FILTER
                }
            end
        end
        if context.joker_main then
            return {
                message = localize {
                    type = 'variable',
                    key = 'a_chips',
                    vars = {card.ability.extra.chips}
                },
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Joker {
    key = "tenpin",
    name = "Ten-Pin",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('tenpin')
    },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        x_mult = 1,
        hands_remaining = 0
    },
    loc_txt = {
        name = "Ten-Pin",
        text = {'If played hand contains a scoring 10,', 'X2 Mult for next 2 hands', '#1#'}
    },
    loc_vars = function(self, info_queue, card)
        local remaining_txt
        if card.ability.hands_remaining > 1 then
            remaining_txt = '(Active for ' .. card.ability.hands_remaining .. ' more hands)'
        elseif card.ability.hands_remaining == 1 then
            remaining_txt = '(Active for 1 more hand)'
        else
            remaining_txt = '(Inactive)'
        end
        return {
            vars = {remaining_txt}
        }
    end,
    calculate = function(self, card, context)
        if context.after then
            local has_10
            for i, other_card in ipairs(context.scoring_hand) do
                if other_card:get_id() == 10 then
                    has_10 = true
                    break
                end
            end
            if has_10 then
                card.ability.hands_remaining = 2
                card.ability.x_mult = 2
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('k_active_ex')
                });
            else
                card.ability.hands_remaining = card.ability.hands_remaining - 1
                if card.ability.hands_remaining > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = card.ability.hands_remaining .. ' remaining'
                    });
                elseif card.ability.x_mult == 2 then
                    card.ability.x_mult = 1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = localize('k_reset')
                    });

                end
            end
        end
    end
}

SMODS.Joker {
    key = "robo",
    name = "Robo-Joker",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('robo')
    },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    enhancement_gate = 'm_steel',
    config = {},
    loc_txt = {
        name = "Robo-Joker",
        text = {'Steel cards give', 'X1.5 Mult when scored'}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Steel Card' then
            return {
                x_mult = 1.5,
                colour = G.C.RED,
                card = card
            }
        end
    end
}

SMODS.Joker {
    key = "swiss",
    name = "Swiss Joker",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('swiss')
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        mult = 0
    },
    loc_txt = {
        name = "Swiss Joker",
        text = {'+8 Mult for each', 'unscored card played', 'in previous hand', '(Currently +#1# Mult)'}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.mult}
        }
    end,
    calculate = function(self, card, context)
        if context.after then
            card.ability.mult = 8 * (#context.full_hand - #context.scoring_hand)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = {card.ability.mult}
                },
                colour = G.C.MULT
            });
        end
        if context.joker_main then
            return {
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = {card.ability.mult}
                },
                mult_mod = card.ability.mult
            }
        end
    end
}

SMODS.Joker {
    key = "squid",
    name = "Squid",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('squid')
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        h_size = 0,
        h_mod = 5
    },
    loc_txt = {
        name = "Squid",
        text = {"+#1# hand size on", "final 2 hands of round", "#2#"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.h_mod, card.ability.h_size > 0 and "(Active)" or "(Inactive)"}
        }
    end,
    calculate = function(self, card, context)
        if context.after and G.GAME.current_round.hands_left <= 2 then
            if card.ability.h_size == 0 then
                card.ability.h_size = card.ability.h_mod
                G.hand:change_size(card.ability.h_size)
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize {
                        type = 'variable',
                        key = 'a_handsize',
                        vars = {card.ability.h_mod}
                    },
                    colour = G.C.FILTER
                });
            end
        end
        if context.end_of_round and card.ability.h_size > 0 then
            card.ability.h_size = 0
            G.hand:change_size(-card.ability.h_mod)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = localize {
                    type = 'variable',
                    key = 'a_handsize_minus',
                    vars = {card.ability.h_mod}
                },
                colour = G.C.FILTER
            });
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.GAME.current_round.hands_left <= 2 then
            card.ability.h_size = 5
        end
    end
}

SMODS.Joker {
    key = "guard",
    name = "Royal Guard",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('guard')
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    config = {
        progress = 0,
        required_progress = 13
    },
    loc_txt = {
        name = "Royal Guard",
        text = {"After #2# Kings or Queens", "score, sell this to make a", "random Joker Negative",
                "(Progress: #1#/#2#)"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.progress, card.ability.required_progress}
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other_id = context.other_card:get_id()
            if other_id == 12 or other_id == 13 then
                if card.ability.progress < card.ability.required_progress then
                    card.ability.progress = card.ability.progress + 1
                    local sell_ready = card.ability.progress >= card.ability.required_progress
                    return {
                        extra = {
                            focus = card,
                            message = sell_ready and localize('k_active_ex') or
                                (card.ability.progress .. "/" .. card.ability.required_progress)
                        },
                        card = card,
                        colour = G.C.FILTER,
                        kcv_juice_card_until = sell_ready
                    }
                end
            end
        end
        if context.selling_self and card.ability.progress >= card.ability.required_progress then
            local candidates = {}
            for i, joker in ipairs(G.jokers.cards) do
                if joker ~= card then
                    table.insert(candidates, joker)
                end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('royalguard'))
                target:set_edition({
                    negative = true
                })
            end
        end
    end
}

-- SMODS.Joker {
--     key = "redenvelope",
--     name = "Red Envelope",
--     atlas = 'kcvanillajokeratlas',
--     pos = {
--         x = 0,
--         y = kcv_getJokerAtlasIndex('redenvelope')
--     },
--     rarity = 2,
--     cost = 4,
--     unlocked = true,
--     discovered = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     config = {},
--     loc_txt = {
--         name = "Red Envelope",
--         text = {'At end of round, earn $8', 'if fewer than 2 hands remain'}
--     },
--     loc_vars = function(self, info_queue, card)
--         return {
--             vars = {}
--         }
--     end,
--     calculate = function(self, card, context)
--     end
-- }

-- SMODS.Joker {
--     key = "chan",
--     name = "Joker-chan",
--     atlas = 'kcvanillajokeratlas',
--     pos = {
--         x = 0,
--         y = kcv_getJokerAtlasIndex('chan')
--     },
--     rarity = 2,
--     cost = 4,
--     unlocked = true,
--     discovered = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     blueprint_compat = true,
--     config = {},
--     loc_txt = {
--         name = "Joker-chan",
--         text = {"Copies the abilities of Common Jokers"}
--     },
--     loc_vars = function(self, info_queue, card)
--         return {
--             vars = {}
--         }
--     end,
--     calculate = function(self, card, context)
--         for i, other_joker in ipairs(G.jokers.cards) do
--             if other_joker ~= card and other_joker.config.center.rarity == 1 then
--                 context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
--                 context.blueprint_card = context.blueprint_card or card
--                 if context.blueprint > #G.jokers.cards + 1 then
--                     return
--                 end
--                 local other_joker_ret = other_joker:calculate_joker(context)
--                 if other_joker_ret then
--                     other_joker_ret.card = context.blueprint_card or card
--                     return other_joker_ret
--                 end
--             end
--         end
--     end
-- }

-- SMODS.Joker {
--     key = "handy",
--     name = "Handy Joker",
--     atlas = 'kcvanillajokeratlas',
--     pos = {
--         x = 0,
--         y = kcv_getJokerAtlasIndex('handy')
--     },
--     rarity = 2,
--     cost = 4,
--     unlocked = true,
--     discovered = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     config = {},
--     loc_txt = {
--         name = "Handy Joker",
--         text = {'If first hand of round is a High Card, X3 Mult for rest of round'}
--     },
--     loc_vars = function(self, info_queue, card)
--         return {
--             vars = {}
--         }
--     end,
--     calculate = function(self, card, context)
--     end
-- }

SMODS.Joker {
    key = "collapse",
    name = "Cosmic Collapse",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('collapse')
    },
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {},
    loc_txt = {
        name = "Cosmic Collapse",
        text = {'At end of round, held Planet', 'cards each have 1 in 3 chance', 'to transform into a Black Hole'}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
        if context.kcv_cosmic_collapse_calculate then
            local success_planets = {}
            for i, consumable in ipairs(G.consumeables.cards) do
                if consumable.ability.set == 'Planet' then
                    local success = pseudorandom('cosmiccollapse') < G.GAME.probabilities.normal / 3
                    -- kcv_log('success? ' .. tostring(success))
                    if success then
                        table.insert(success_planets, consumable)
                    end
                end
            end
            -- kcv_log('success planets ' .. #success_planets)

            if #success_planets > 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Collapse!"
                });
            end

            for i, planet in ipairs(success_planets) do
                -- need this bc OG doesn't accomodate for transforming planets
                planet.config.card = {}
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot2', 1.1, 0.6)
                        planet:set_ability(G.P_CENTERS.c_black_hole)
                        planet:juice_up(1, 0.5)
                        return true
                    end
                }))
                delay(0.4)
            end
        end
    end
}

local function rank_up(card)
    local suit_prefix = string.sub(card.base.suit, 1, 1) .. '_'
    local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id + 1, 14)
    if rank_suffix < 10 then
        rank_suffix = tostring(rank_suffix)
    elseif rank_suffix == 10 then
        rank_suffix = 'T'
    elseif rank_suffix == 11 then
        rank_suffix = 'J'
    elseif rank_suffix == 12 then
        rank_suffix = 'Q'
    elseif rank_suffix == 13 then
        rank_suffix = 'K'
    elseif rank_suffix == 14 then
        rank_suffix = 'A'
    end
    card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
end

SMODS.Joker {
    key = "5day",
    name = "Five-Day Forecast",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('5day')
    },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = true,
    blueprint_compat = true,
    config = {},
    loc_txt = {
        name = "Five-Day Forecast",
        text = {"If played hand contains a Straight,", "increase played cards' ranks by 1", "(Excludes Aces)"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
        if context.before then
            if next(context.poker_hands["Straight"]) then
                local targets = {}
                for i, other_c in ipairs(context.scoring_hand) do
                    if other_c:get_id() ~= 14 then
                        table.insert(targets, other_c)
                    end
                end

                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('k_active_ex'),
                    colour = G.C.FILTER
                });

                for i_2, other_c_2 in ipairs(targets) do
                    local percent = 1.15 - (i_2 - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('card1', percent)
                            other_c_2:flip()
                            return true
                        end
                    }))
                    delay(0.1)
                end
                delay(0.2)
                for i_3, other_c_3 in ipairs(targets) do
                    local percent = 0.85 + (i_3 - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            rank_up(other_c_3)
                            play_sound('tarot2', percent, 0.6)
                            other_c_3:flip()
                            return true
                        end
                    }))
                    delay(0.1)
                end
                delay(0.2)
            end
        end
    end
}

-- SMODS.Joker {
--     key = "powergrid",
--     name = "Power Grid",
--     atlas = 'kcvanillajokeratlas',
--     pos = {
--         x = 0,
--         y = kcv_getJokerAtlasIndex('powergrid')
--     },
--     rarity = 3,
--     cost = 4,
--     unlocked = true,
--     discovered = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     config = {},
--     loc_txt = {
--         name = "Power Grid",
--         text = {"Mult and Steel cards count as both"}
--     },
--     loc_vars = function(self, info_queue, card)
--         return {
--             vars = {}
--         }
--     end,
--     calculate = function(self, card, context)
--     end
-- }

SMODS.Joker {
    key = "irish",
    name = "Luck of the Irish",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('irish')
    },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {},
    loc_txt = {
        name = "Luck of the Irish",
        text = {"Lucky Clubs are 4X more", "likely to succeed"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
    end
}

SMODS.Joker {
    key = "energy",
    name = "Joker Energy",
    atlas = 'kcvanillajokeratlas',
    pos = {
        x = 0,
        y = kcv_getJokerAtlasIndex('energy')
    },
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = 0.5,
        x_mult = 1
    },
    loc_txt = {
        name = "Joker Energy",
        text = {"Gains X#1# Mult when a", "Wild card scores in a", "5-card poker hand, resets",
                "if hand contains a Flush", "(Currently X#2# Mult)"}
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra, card.ability.x_mult}
        }
    end,
    calculate = function(self, card, context)
        if context.before then
            if next(context.poker_hands["Flush"]) then
                card.ability.x_mult = 1
                return {
                    message = localize('k_reset')
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if #context.scoring_hand == 5 then
                local other = context.other_card
                kcv_dump(other.ability.name)
                if other.ability.name == 'Wild Card' then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra
                    return {
                        extra = {
                            focus = card,
                            message = localize('k_upgrade_ex'),
                            colour = G.C.MULT
                        },
                        card = card
                    }
                end
            end
        end
    end
}
