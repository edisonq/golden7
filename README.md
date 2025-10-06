# golden7
A powerful MT5 Expert Advisor that trades based on the confluence of 7 technical indicators and your manual fundamental bias. Features advanced filters (Trend, Volatility, Time), a two-stage trailing stop with breakeven-plus, multi-trade capability, and a full alert system. Highly customizable for any market.

The Golden7 Final EA is a powerful and highly customizable trading robot for MetaTrader 5. It is designed to identify high-probability trading opportunities by scoring the confluence of multiple technical indicators, which are then qualified by a robust set of filters.

This EA is built to be a flexible trading tool. It can operate as a fully automated trading system or as a powerful assistant, providing signals and managing manual trades with its advanced trade management features. The system combines the logic of its technical scoring engine with the survival instinct of its filters and stop-loss features, giving you the confidence to act on high-conviction signals.

Key Features 📈

    Advanced Confluence Engine: Scores potential trades using a weighted system of 7 technical indicators (MA, ADX, Bollinger Bands®, RVI, SAR, RSI) and a user-defined fundamental bias.

    Multi-Trade Logic: Capable of managing multiple independent positions (max 1 buy and 1 sell), with a master control to set the maximum number of total open trades.

    Manual Fundamental Bias: Integrate your own market analysis by setting a fundamental score from +8 (strongly bullish) to -8 (strongly bearish), which directly influences the EA's decisions.

    Three-Layer Filtering System: Strictly qualifies every signal with:

        Trend Filter: Ensures trades are taken in the direction of the long-term trend.

        Volatility Filter: Avoids trading in markets that are either too sleepy or too chaotic.

        Time Filter: Restricts trading to specific user-defined sessions.

    Two-Stage Trade Management: Automatically protects winning trades with:

        Breakeven Plus: Moves the stop loss to a small profit once an initial profit target is hit.

        Trailing Stop: Dynamically trails the price to lock in gains as a trend develops.

    Manual Trade Assistant: An optional mode to allow the EA's advanced Breakeven Plus and Trailing Stop logic to manage trades that you have opened manually.

    Dynamic & Fixed SL/TP: Choose between an ATR-based (volatility-adaptive) or a fixed-point stop loss and take profit.

    Full Alert System: Never miss a signal with pop-up, mobile push, and email notifications for high-scoring trade setups.

    Customizable Display: Features an on-chart scoreboard showing the live bullish and bearish scores, with a customizable text color to match your chart theme.

Full List of Parameters ⚙️

Auto-Trading

    InpAutoTradingEnabled: Master switch to turn automated signal-based trading on/off.

    InpLotSize: The fixed lot size for each trade.

    InpMagicNumber: The unique ID for the EA's trades.

    InpMaxOpenTrades: The maximum number of trades the EA can have open at one time.

Auto SL and TP

    InpUseAtrSLTP: If true, uses ATR for SL/TP. If false, uses fixed points.

    InpAtrSLMultiplier: Multiplier for ATR to set the stop loss distance.

    InpAtrTPMultiplier: Multiplier for ATR to set the take profit distance.

    InpStopLoss: Stop loss in points (if ATR is disabled).

    InpTakeProfit: Take profit in points (if ATR is disabled).

Filters

    InpUseTrendFilter, InpUseVolatilityFilter, InpUseTimeFilter: Switches to enable/disable the Trend, Volatility, and Time filters.

    ... and all related settings for MA period, ATR range, and trading hours.

Trailing Stop & Breakeven

    InpUseBreakevenPlus, InpUseTrailingStop: Switches to enable/disable the features.

    InpBEPlusTrigger: Profit in points required to activate the Breakeven Plus move.

    InpBEPlusPoints: Amount of profit in points to lock in with the Breakeven Plus move.

    InpTrailStart: Profit in points required to activate the standard Trailing Stop.

    InpTrailDistance: Distance in points to maintain the SL behind the price.

    InpManageManualTrades: If true, the EA will manage trades with Magic Number 0.

Scoring & Alerts

    InpFundaScore: Your manual fundamental bias score (-8 to +8).

    InpUsePopupAlert, InpUsePushNotification, InpUseEmailAlert: Switches for the alert types.

    InpMinScore: The minimum confluence score required to trigger an alert or a trade.

    Inp...Weight: Individual weights for each of the 7 technical indicators.

Display

    InpLabelColor: Sets the color of the on-chart scoreboard text.

Disclaimer

Trading carries a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. It is highly recommended to thoroughly test this EA on a demo account before using it on a live account.
