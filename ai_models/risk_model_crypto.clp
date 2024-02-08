;template for position data
(deftemplate position-data
(slot ot_pos_dealid)
(slot ot_instr_name)
(slot ot_instr_id)
(slot ot_instrument_type)
(slot ot_pos_direction)
(slot ot_pos_opening)
(slot ot_pos_limit)
(slot ot_pos_stop)
(slot ot_instr_lotsize)
(slot ot_pos_contractsize)
(slot ot_pos_size)
(slot ot_instr_offer)
(slot ot_instr_bid)
(slot ot_pos_controlled)
(slot ot_pos_weight)
(slot ot_pos_cc)
(slot ot_pos_exchange)
(slot ot_pos_margin)
(slot ot_instr_type)
(slot ot_risk_check)
)

;template for correlation data
(deftemplate correlation-data
(slot ot_instr_id_1)
(slot ot_instr_id_2)
(slot corr-is)
)

;template for risk data
(deftemplate risk-data
(slot risk-is)
(slot ot_pos_dealid)
(slot name_1)
(slot param_1)
(slot param_2)
(slot param_3)
(slot param_4)
(slot param_5)
(slot param_6)
)

;template for indicator data, with a one slot for sentiment for sma
(deftemplate indicator-data
(slot ot_instr_id )
(slot ot_indicator_type )
(slot ot_indicator_value )
(slot ot_instr_sentiment)
)

;temporary rule for asserting position weight in non base currency
(defrule weight-exchange
?fact <- (position-data (ot_pos_dealid ?deal1)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_weight ?weight)(ot_pos_exchange ?exchange)(ot_pos_margin ?marginlevel)(ot_pos_size ?lotsize))
(ot_user_balance ?balance)
(test (neq ?balance nil))
(test (neq ?size nil))
(test (neq ?opening nil))
(test (eq ?weight nil))
(test (neq ?exchange 1.0))
(test (neq ?marginlevel nil))
(test (neq ?lotsize nil))
=>
(modify ?fact (ot_pos_weight (/ (/ (/ (* (* (* ?opening ?size) ?lotsize) ?marginlevel) 100) ?exchange) ?balance))))

;temporary rule for asserting position weight in base currency
(defrule weight
?fact <- (position-data (ot_pos_dealid ?deal1)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_weight ?weight)(ot_pos_exchange ?exchange)(ot_pos_margin
?marginlevel)(ot_pos_size ?lotsize))
(ot_user_balance ?balance)
(test (neq ?balance nil))
(test (neq ?size nil))
(test (neq ?opening nil))
(test (eq ?weight nil))
(test (eq ?exchange 1.0))
(test (neq ?marginlevel nil))
(test (neq ?lotsize nil))
=>
(modify ?fact (ot_pos_weight (/ (/ (* (* (* ?opening ?size) ?lotsize) ?marginlevel) 100) ?balance))))

;rule find-pos-corr: checks whether two instruments are correlated
(defrule find-pos-corr
(position-data (ot_pos_dealid ?deal1)(ot_instr_id ?id1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_id ?id2))
(test (neq ?deal1 ?deal2))
(test (eq (check_pos_corr ?id1 ?id2) TRUE))
=>
(assert (correlation-data (ot_instr_id_1 ?id1)(ot_instr_id_2 ?id2)(corr-is positive)))
)

;rule find-neg-corr: checks whether two instruments are negatively correlated
(defrule find-neg-corr
(position-data (ot_pos_dealid ?deal1)(ot_instr_id ?id1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_id ?id2))
(test (neq ?deal1 ?deal2))
(test (eq (check_neg_corr ?id1 ?id2) TRUE))
=>
(assert (correlation-data (ot_instr_id_1 ?id1)(ot_instr_id_2 ?id2)(corr-is negative)))
)

;rule positive-same: checks whether two positions are correlated and in the same direction
(defrule positive-same
(position-data (ot_pos_dealid ?deal1)(ot_instr_name ?var_name1)(ot_instr_id ?id1)(ot_pos_direction ?dir1)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_name ?var_name2)(ot_instr_id ?id2)(ot_pos_direction ?dir2)(ot_risk_check ?check2))
(correlation-data (ot_instr_id_1 ?id3)(ot_instr_id_2 ?id4)(corr-is positive))
(test (neq ?deal1 ?deal2))
(test (eq ?check1 true))
(or
(and
(test (eq ?id1 ?id3))
(test (eq ?id2 ?id4))
)
(and
(test (eq ?id1 ?id4))
(test (eq ?id2 ?id3))
)
)
(test (eq ?dir1 ?dir2))
 =>
(assert (risk-data (risk-is position-positive-same-corr)(ot_pos_dealid ?deal1)(param_1 ?deal2)(name_1 ?id1)(param_3 ?id2)(param_4 ?dir1)(param_5 ?var_name1)(param_6 ?var_name2))))

;rule positive-opposite: checks whether two positions are correlated and in the opposite direction
(defrule positive-opposite
(position-data (ot_pos_dealid ?deal1)(ot_instr_name ?var_name1)(ot_instr_id ?id1)(ot_pos_direction ?dir1)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_name ?var_name2)(ot_instr_id ?id2)(ot_pos_direction ?dir2)(ot_risk_check ?check2))
(correlation-data (ot_instr_id_1 ?id3)(ot_instr_id_2 ?id4)(corr-is positive))
(test (neq ?deal1 ?deal2))
(test (eq ?check1 true))
(or
(and
(test (eq ?id1 ?id3))
(test (eq ?id2 ?id4))
)
(and
(test (eq ?id1 ?id4))
(test (eq ?id2 ?id3))
)
)
(test (neq ?dir1 ?dir2))
 =>
(assert (risk-data (risk-is position-positive-oposite-corr)(ot_pos_dealid ?deal1)(param_1 ?deal2)(name_1 ?id1)(param_3 ?id2)(param_4 ?dir1)(param_5 ?var_name1)(param_6 ?var_name2)))
)

;rule negative-same: checks whether two positions are negatively correlated and in the same direction
(defrule negative-same
(position-data (ot_pos_dealid ?deal1)(ot_instr_name ?var_name1)(ot_instr_id ?id1)(ot_pos_direction ?dir1)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_name ?var_name2)(ot_instr_id ?id2)(ot_pos_direction ?dir2)(ot_risk_check ?check2))
(correlation-data (ot_instr_id_1 ?id3)(ot_instr_id_2 ?id4)(corr-is negative))
(test (neq ?deal1 ?deal2))
(test (eq ?check1 true))
(or
(and
(test (eq ?id1 ?id3))
(test (eq ?id2 ?id4))
)
(and
(test (eq ?id1 ?id4))
(test (eq ?id2 ?id3))
)
)
(test (eq ?dir1 ?dir2))
 =>
(assert (risk-data (risk-is position-negative-same-corr)(ot_pos_dealid ?deal1)(param_1 ?deal2)(name_1 ?id1)(param_3 ?id2)(param_4 ?dir1)(param_5 ?var_name1)(param_6 ?var_name2))))


;rule negative-opposite: checks whether two positions are negatively correlated and in the opposite direction
(defrule negative-opposite
(position-data (ot_pos_dealid ?deal1)(ot_instr_name ?var_name1)(ot_instr_id ?id1)(ot_pos_direction ?dir1)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_name ?var_name2)(ot_instr_id ?id2)(ot_pos_direction ?dir2)(ot_risk_check ?check2))
(correlation-data (ot_instr_id_1 ?id3)(ot_instr_id_2 ?id4)(corr-is negative))
(test (neq ?deal1 ?deal2))
(test (eq ?check1 true))
(or
(and
(test (eq ?id1 ?id3))
(test (eq ?id2 ?id4))
)
(and
(test (eq ?id1 ?id4))
(test (eq ?id2 ?id3))
)
)
(test (neq ?dir1 ?dir2))
 =>
(assert (risk-data (risk-is position-negative-oposite-corr)(ot_pos_dealid ?deal1)(param_1 ?deal2)(name_1 ?id1)(param_3 ?id2)(param_4 ?dir1)(param_5 ?var_name1)(param_6 ?var_name2))))

;rule counter-sentiment: checks whether the position direction is against moving average sentiment
(defrule counter-sentiment
(or
(and
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_direction BUY)(ot_risk_check ?check))
(indicator-data (ot_instr_id ?id2)(ot_instr_sentiment bearish))
(ot_user_timeframe ?timeframe)
(test (eq ?id ?id2))
(test (eq ?check true)))
(and
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_direction SELL)(ot_risk_check ?check))
(indicator-data (ot_instr_id ?id2)(ot_instr_sentiment bullish))
(ot_user_timeframe ?timeframe)
(test (eq ?id ?id2))
(test (eq ?check true)))
)
 =>
(assert (risk-data (risk-is position-counter-sentiment)(ot_pos_dealid ?deal)(name_1 ?id)(param_5 ?var_name1)(param_6 ?timeframe))))

;rule position-oversized: checks whether % weight of the position in the portfolio is not higher than default
(defrule position-oversized
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_weight ?weight)(ot_risk_check ?check))
(ot_user_diversification ?diversification)
(test (neq nil ?weight))
(test (> ?weight ?diversification))
(test (eq ?check true))
=>
(assert (risk-data (risk-is position-oversized)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?diversification))(param_5 ?var_name1))))

;rule position-not-oversized: checks whether % weight of the position in the portfolio is not higher than default
(defrule position-not-oversized
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_weight ?weight)(ot_risk_check ?check))
(ot_user_diversification ?diversification)
(test (neq nil ?weight))
(test (<= ?weight ?diversification))
(test (eq ?check true))
=>
(assert (risk-data (risk-is position-not-oversized)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?diversification))(param_5 ?var_name1))))

;rule position-risk: checks whether the risk (potential loss) associated with position is higher than the default limit
(defrule position-risk
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_instr_offer ?offer)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(test (eq ?controlled false))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?offer))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(and
(test (< (- ?offer ?opening ) 0.0))
(test (> (/ (/ (* (* (- ?opening ?offer) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
)
=>
(assert (risk-data (risk-is position-risk-limit)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?risk-limit))(param_5 ?var_name1)(param_6 (/ (* (* (- ?opening ?offer) ?lotsize) ?size) ?exchange))
)))

;rule position-risk-norma: checks whether the risk (potential loss) associated with position is lower than the default limit
(defrule position-risk-norma
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_instr_offer ?offer)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(test (eq ?controlled false))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?offer))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(and
(test (< (- ?offer ?opening ) 0.0))
(test (<= (/ (/ (* (* (- ?opening ?offer) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
)
=>
(assert (risk-data (risk-is position-ok-risk-limit)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?risk-limit))(param_5 ?var_name1)(param_6 (/ (* (* (- ?opening ?offer) ?lotsize) ?size) ?exchange))
)))

;rule position-ok-risk-reward: checks whether the risk reward is within default limit
(defrule position-ok-risk
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_instr_offer ?offer)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled false))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?offer))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(and
(test (>= (- ?offer ?opening ) 0.0))
(test (>= (/ (/ (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit) (* 0.8 ?riskrewardratio) ))
(test (<= (/ (/ (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit) (* 1.2 ?riskrewardratio) ))
)
=>
(assert (risk-data (risk-is position-ok-risk-reward)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1)(param_6 (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange))
)))

;rule position-high-risk-reward: checks whether the risk reward is above default limit
(defrule position-high-risk
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_instr_offer ?offer)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled false))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?offer))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(and
(test (>= (- ?offer ?opening ) 0.0))
(test (> (/ (/ (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit) (* 1.2 ?riskrewardratio) ))
)
=>
(assert (risk-data (risk-is position-high-risk-reward)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1)(param_6 (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange))
)))

;rule position-low-risk-reward: checks whether the risk reward is above default limit
(defrule position-low-risk
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_instr_offer ?offer)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled false))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?offer))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(and
(test (>= (- ?offer ?opening ) 0.0))
(test (< (/ (/ (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit) (* 0.8 ?riskrewardratio) ))
)
=>
(assert (risk-data (risk-is position-low-risk-reward)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1)(param_6 (/ (* (* (- ?offer ?opening) ?lotsize) ?size) ?exchange))
)))



;rule double-crypto-position: checks whether there are two positions on a one coin;
(defrule double-crypto-position
(position-data (ot_pos_dealid ?deal1)(ot_instr_name ?var_name1)(ot_instr_id ?id1)(ot_pos_direction ?direction1)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_instr_name ?var_name2)(ot_instr_id ?id2)(ot_pos_direction ?direction2)(ot_risk_check ?check2)(ot_pos_contractsize ?quantity))
(test (eq ?check1 true))
(test (eq ?check2 false))
(test (eq ?deal1 ?deal2))
=>
(assert (risk-data (risk-is position-double-crypto)(ot_pos_dealid ?deal1)(param_2 ?quantity))))


;double position weight in base currency
(defrule double-weight
(position-data (ot_pos_dealid ?deal1)(ot_pos_opening ?opening)(ot_pos_contractsize ?size)(ot_pos_weight ?weight)(ot_pos_exchange ?exchange)(ot_pos_margin
?marginlevel)(ot_pos_size ?lotsize)(ot_risk_check ?check1))
(position-data (ot_pos_dealid ?deal2)(ot_pos_opening ?opening2)(ot_pos_contractsize ?size2)(ot_pos_weight ?weight2)(ot_pos_exchange ?exchange2)(ot_pos_margin
?marginlevel2)(ot_pos_size ?lotsize2)(ot_risk_check ?check2))
(test (eq ?check2 false))
(ot_user_diversification ?diversification)
(test (eq ?check1 true))
(test (eq ?deal1 ?deal2))
(test (neq nil ?weight))
(test (neq nil ?weight2))
(test (> (+ ?weight ?weight2) ?diversification))
=>
(assert (risk-data (risk-is position-double-weight)(ot_pos_dealid ?deal1)(param_2 (* 100 ?diversification)))))

;rule stop-loss: checks whether there is a stop loss order
(defrule stop-loss
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_stop ?stop)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(test (eq ?stop nil))
(test (eq ?check true))
(test (eq ?controlled true))
 =>
(assert (risk-data (risk-is position-stop-loss)(ot_pos_dealid ?deal)(param_1 ?id)(param_5 ?var_name1))))

;rule take-profit: checks whether there is a take profit order
(defrule take-profit
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_limit ?limit)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(test (eq ?limit nil))
(test (eq ?check true))
(test (eq ?controlled true))
 =>
(assert (risk-data (risk-is position-take-profit)(ot_pos_dealid ?deal)(name_1 ?id)(param_5 ?var_name1))))


;rule position-volatility-high: checks whether the volatility is higher than normal
(defrule position-volatility-high
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_risk_check ?check))
(indicator-data (ot_instr_id ?id2)(ot_indicator_type ot_indicator_bbw)(ot_indicator_value ?bbw))
(indicator-data (ot_instr_id ?id3)(ot_indicator_type ot_indicator_abbw)(ot_indicator_value ?abbw))
(test (eq ?id ?id2))
(test (eq ?id2 ?id3))
(test (neq nil ?abbw))
(test (neq nil ?bbw))
(test (eq ?check true))
(test (> (* 100 (/ (- ?bbw ?abbw) ?abbw)) 40) )
=>
(assert (risk-data (risk-is position-volatility-high)(ot_pos_dealid ?deal)(name_1 ?id)(param_5 ?var_name1))))

;rule position-volatility-low: checks whether the volatility is lower than normal
(defrule position-volatility-low
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_risk_check ?check))
(indicator-data (ot_instr_id ?id2)(ot_indicator_type ot_indicator_bbw)(ot_indicator_value ?bbw))
(indicator-data (ot_instr_id ?id3)(ot_indicator_type ot_indicator_abbw)(ot_indicator_value ?abbw))
(test (eq ?id ?id2))
(test (eq ?id2 ?id3))
(test (neq nil ?abbw))
(test (neq nil ?bbw))
(test (eq ?check true))
(test (< (* 100 (/ (- ?bbw ?abbw) ?abbw)) -40) )
=>
(assert (risk-data (risk-is position-volatility-low)(ot_pos_dealid ?deal)(name_1 ?id)(param_5 ?var_name1))))




;rule high-risk-reward: checks whether the risk reward ratio is considerably higher than the default value
(defrule high-risk-reward
(position-data (ot_pos_dealid ?deal)(ot_instr_id ?id)(ot_instr_name ?var_name1)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_limit ?limit)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled true))
(test (neq nil ?limit))
(test (neq nil ?stop))
(test (neq nil ?opening))
(test (eq ?check true))
(
or
(
and
(test (> (- ?limit ?opening) 0.0))
(test (> (/ (- ?limit ?opening) (- ?opening ?stop)) (* 1.2 ?riskrewardratio)))
)
(
and
(test (< (- ?limit ?opening) 0.0))
(test (> (/ (- ?opening ?limit) (- ?stop ?opening)) (* 1.2 ?riskrewardratio)))
)
)
=>
(assert (risk-data (risk-is position-high-risk-reward-two)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1))))

;rule low-risk-reward: checks whether the risk reward ratio is considerably lower than the default value
(defrule low-risk-reward
(position-data (ot_pos_dealid ?deal)(ot_instr_id ?id)(ot_instr_name ?var_name1)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_limit ?limit)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_riskrewardratio ?riskrewardratio)
(position-data (ot_pos_dealid ?deal)(ot_instr_id ?id)(ot_instr_name ?var_name1)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_limit ?limit)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled true))
(test (neq nil ?limit))
(test (neq nil ?stop))
(test (neq nil ?opening))
(test (eq ?check true))
(
or
(
and
(test (> (- ?limit ?opening) 0.0))
(test (< (/ (- ?limit ?opening) (- ?opening ?stop)) (* 0.8 ?riskrewardratio)))
)
(
and
(test (< (- ?limit ?opening) 0.0))
(test (< (/ (- ?opening ?limit) (- ?stop ?opening)) (* 0.8 ?riskrewardratio)))
)
)
=>
(assert (risk-data (risk-is position-low-risk-reward-two)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1))))

;ok-risk-reward: checks whether the risk reward ratio is equal to default value
(defrule ok-risk-reward
(position-data (ot_pos_dealid ?deal)(ot_instr_id ?id)(ot_instr_name ?var_name1)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_limit ?limit)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_riskrewardratio ?riskrewardratio)
(test (eq ?controlled true))
(test (neq nil ?limit))
(test (neq nil ?stop))
(test (neq nil ?opening))
(test (eq ?check true))
(
or
(
and
(test (> (- ?limit ?opening) 0.0))
(test (>= (/ (- ?limit ?opening) (- ?opening ?stop)) (* 0.8 ?riskrewardratio)))
(test (<= (/ (- ?limit ?opening) (- ?opening ?stop)) (* 1.2 ?riskrewardratio)))
)
(
and
(test (< (- ?limit ?opening) 0.0))
(test (>= (/ (- ?opening ?limit) (- ?stop ?opening)) (* 0.8 ?riskrewardratio)))
(test (<= (/ (- ?opening ?limit) (- ?stop ?opening)) (* 1.2 ?riskrewardratio)))
)
)
=>
(assert (risk-data (risk-is position-ok-risk-reward-two)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 ?riskrewardratio)(param_5 ?var_name1))))

;rule position-risk: checks whether the risk (potential loss) associated with position is not higher than the default limit
(defrule position-risk-two
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(test (eq ?controlled true))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?stop))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(or
(test (> (/ (/ (* (* (- ?opening ?stop) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
(test (> (/ (/ (* (* (- ?stop ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
)
=>
(assert (risk-data (risk-is position-risk-limit-two)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?risk-limit))(param_5 ?var_name1))))

;rule position-risk: checks whether the risk (potential loss) associated with position is as default
(defrule position-ok-risk-two
(position-data (ot_pos_dealid ?deal)(ot_instr_name ?var_name1)(ot_instr_id ?id)(ot_pos_opening ?opening)(ot_pos_stop ?stop)(ot_pos_contractsize ?size)(ot_pos_exchange ?exchange)(ot_pos_size ?lotsize)(ot_risk_check ?check)(ot_pos_controlled ?controlled))
(ot_user_balance ?account-balance)
(ot_user_limitpertrade ?risk-limit)
(test (eq ?controlled true))
(test (neq nil ?account-balance))
(test (neq nil ?opening))
(test (neq nil ?stop))
(test (neq nil ?size))
(test (neq ?exchange nil))
(test (neq ?lotsize nil))
(test (eq ?check true))
(or
(and
(test (> (- ?opening ?stop) 0.0))
(test (<= (/ (/ (* (* (- ?opening ?stop) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
)
(and
(test (> (- ?stop ?opening) 0.0))
(test (<= (/ (/ (* (* (- ?stop ?opening) ?lotsize) ?size) ?exchange) ?account-balance) ?risk-limit))
)
)
=>
(assert (risk-data (risk-is position-ok-risk-limit-two)(ot_pos_dealid ?deal)(name_1 ?id)(param_2 (* 100 ?risk-limit))(param_5 ?var_name1))))