//+------------------------------------------------------------------+
//|                                              Golden7_Final.mq5   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                     https://www.edisonquinones.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.edisonquinones.com"
#property version   "3.12" // Final Version with All Features
#property strict
#include <Trade\Trade.mqh>
CTrade trade;

//--- Inputs for Auto-Trading
input bool   InpAutoTradingEnabled = true;   // --- MASTER SWITCH for Signal-Based Auto-Trading
input double InpLotSize            = 0.01;   // Lot Size
input ulong  InpMagicNumber        = 12345;  // EA Magic Number
input int    InpMaxOpenTrades      = 2;      // Max number of simultaneous trades

//--- Inputs for Stop Loss & Take Profit Method
input group           "Auto SL and TP"
input bool   InpUseAtrSLTP      = true;   // --- Use ATR for SL/TP? (If false, uses points below)
input double InpAtrSLMultiplier = 2.0;    // ATR Multiplier for Stop Loss
input double InpAtrTPMultiplier = 4.0;    // ATR Multiplier for Take Profit
input int    InpStopLoss        = 500;    // Stop Loss in Points (if ATR is false)
input int    InpTakeProfit      = 3000;   // Take Profit in Points (if ATR is false)

//--- 1. TREND FILTER
input group           "Trend filter"
input bool          InpUseTrendFilter   = true;        // --- Enable/Disable Trend Filter
input int           InpTrendMAPeriod    = 200;         // Period for the long-term MA
input ENUM_TIMEFRAMES InpTrendMATimeframe = PERIOD_H1;     // Timeframe for the long-term MA

//--- 2. VOLATILITY FILTER (ATR)
input group           "Volatility filter"
input bool   InpUseVolatilityFilter = true;     // --- Enable/Disable Volatility Filter
input int    InpATRPeriod           = 14;       // Period for the ATR indicator
input double InpMinATR              = 100;      // Minimum ATR value to trade (in points)
input double InpMaxATR              = 1000;     // Maximum ATR value to trade (in points)

//--- 3. TIME FILTER
input group           "Time filter"
input bool InpUseTimeFilter = true;    // --- Enable/Disable Time Filter
input int  InpStartHour     = 9;        // Trading start hour (e.g., 9 for London open)
input int  InpEndHour       = 17;       // Trading end hour (e.g., 17 for NY close)

//--- 4. TRAILING STOP & BREAKEVEN
input group           "Trailing Stop & Breakeven"
input bool            InpUseBreakevenPlus   = true;   // --- Enable Breakeven Plus Feature
input int             InpBEPlusTrigger      = 500;    // Points in profit to trigger the move
input int             InpBEPlusPoints       = 250;    // Points of profit to lock in
input bool            InpUseTrailingStop    = true;   // --- Enable/Disable Trailing Stop
input int             InpTrailStart         = 800;    // Points in profit to start trailing
input int             InpTrailDistance      = 800;    // Distance to keep SL from price
input bool            InpManageManualTrades = false;  // Allow EA to manage manual trades (Magic #0)

//--- 5. MANUAL FUNDAMENTAL SCORE
input group "Manual Fundamental Score"
input int   InpFundaScore = 0; // Set bias: +8 (Strong Bull) to -8 (Strong Bear)

//--- 6. ALERTS & NOTIFICATIONS
input group "Alerts & Notifications"
input bool  InpUsePopupAlert      = true;  // Enable Pop-up Alert with Sound
input bool  InpUsePushNotification = false; // Enable Mobile Push Notifications
input bool  InpUseEmailAlert      = false; // Enable Email Alerts

//--- 7. DISPLAY SETTINGS
input group "Display Settings"
input color InpLabelColor = clrOrange; // Color for the scoreboard text

//--- Inputs for Indicators
input group           "Inputs for indicators"
input int    InpMAPeriod    = 20;
input int    InpADXPeriod   = 10;
input int    InpBBPeriod    = 15;
input double InpBBDeviation = 2.0;
input int    InpRVIPeriod   = 8;
input double InpSARStep     = 0.02;
input double InpSARMaximum  = 0.2;
input int    InpRSIPeriod   = 10;

//--- Inputs for Confluence Scoring
input int InpMAWeight=20, InpADXWeight=15, InpDIWeight=15, InpBBWeight=10, InpConfirmWeight=10, InpRVIWeight=10, InpSARWeight=10, InpRSIWeight=10, InpMinScore=90;

//--- Global Variables
int handleMA, handleADX, handleBB, handleRVI, handleSAR, handleRSI, handleTrendMA, handleATR;
double maBuffer[], adxBuffer[], diPlusBuffer[], diMinusBuffer[], bbMiddleBuffer[], rviMainBuffer[], rviSignalBuffer[], sarBuffer[], rsiBuffer[], trendMaBuffer[], atrBuffer[];
#define LABEL_L1 "ScoreboardLine1"
#define LABEL_L2 "ScoreboardLine2"
#define LABEL_L3 "ScoreboardLine3"
#define LABEL_L4 "ScoreboardLine4"

//+------------------------------------------------------------------+
int OnInit()
  {
   handleMA = iMA(_Symbol, PERIOD_CURRENT, InpMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
   handleADX = iADX(_Symbol, PERIOD_CURRENT, InpADXPeriod);
   handleBB = iBands(_Symbol, PERIOD_CURRENT, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE);
   handleRVI = iRVI(_Symbol, PERIOD_CURRENT, InpRVIPeriod);
   handleSAR = iSAR(_Symbol, PERIOD_CURRENT, InpSARStep, InpSARMaximum);
   handleRSI = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
   handleTrendMA = iMA(_Symbol, InpTrendMATimeframe, InpTrendMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   handleATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   if(handleMA==INVALID_HANDLE || handleADX==INVALID_HANDLE || handleBB==INVALID_HANDLE || handleRVI==INVALID_HANDLE || handleSAR==INVALID_HANDLE || handleRSI==INVALID_HANDLE || handleTrendMA==INVALID_HANDLE || handleATR==INVALID_HANDLE)
      return(INIT_FAILED);
   ArrayResize(maBuffer, 2);
   ArrayResize(adxBuffer, 2);
   ArrayResize(diPlusBuffer, 2);
   ArrayResize(diMinusBuffer, 2);
   ArrayResize(bbMiddleBuffer, 2);
   ArrayResize(rviMainBuffer, 2);
   ArrayResize(rviSignalBuffer, 2);
   ArrayResize(sarBuffer, 2);
   ArrayResize(rsiBuffer, 2);
   ArrayResize(trendMaBuffer, 2);
   ArrayResize(atrBuffer, 2);
   string labels[] = {LABEL_L1, LABEL_L2, LABEL_L3, LABEL_L4};
   for(int i=0; i<4; i++)
     {
      ObjectCreate(0, labels[i], OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labels[i], OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, labels[i], OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, labels[i], OBJPROP_YDISTANCE, 35 + (i*15));
      ObjectSetInteger(0, labels[i], OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetInteger(0, labels[i], OBJPROP_COLOR, InpLabelColor);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handleMA);
   IndicatorRelease(handleADX);
   IndicatorRelease(handleBB);
   IndicatorRelease(handleRVI);
   IndicatorRelease(handleSAR);
   IndicatorRelease(handleRSI);
   IndicatorRelease(handleTrendMA);
   IndicatorRelease(handleATR);
   ObjectDelete(0, LABEL_L1);
   ObjectDelete(0, LABEL_L2);
   ObjectDelete(0, LABEL_L3);
   ObjectDelete(0, LABEL_L4);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   static int barsCount=0;
   int currentBars=Bars(_Symbol,PERIOD_CURRENT);
   if(barsCount==currentBars)
     {
      // CORRECTED: Check if a trade is open before trying to manage it
      if((InpUseBreakevenPlus || InpUseTrailingStop) && IsTradeOpen())
         ManageTrailingStop();
      return;
     }
   barsCount=currentBars;

   MqlRates rates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) < 2)
      return;
   double barClose=rates[1].close, barLow=rates[1].low, barHigh=rates[1].high;

   if(CopyBuffer(handleMA,0,1,1,maBuffer)<=0 || CopyBuffer(handleADX,0,1,1,adxBuffer)<=0 || CopyBuffer(handleADX,1,1,1,diPlusBuffer)<=0 || CopyBuffer(handleADX,2,1,1,diMinusBuffer)<=0 || CopyBuffer(handleBB,1,1,1,bbMiddleBuffer)<=0 || CopyBuffer(handleRVI,0,1,1,rviMainBuffer)<=0 || CopyBuffer(handleRVI,1,1,1,rviSignalBuffer)<=0 || CopyBuffer(handleSAR,0,1,1,sarBuffer)<=0 || CopyBuffer(handleRSI,0,1,1,rsiBuffer)<=0 || CopyBuffer(handleTrendMA,0,1,1,trendMaBuffer)<=0 || CopyBuffer(handleATR,0,1,1,atrBuffer)<=0)
      return;

   int bullishScore=0, bearishScore=0;
   if(InpFundaScore > 0)
      bullishScore += InpFundaScore;
   else
      if(InpFundaScore < 0)
         bearishScore += MathAbs(InpFundaScore);
   if(barClose > maBuffer[0])
      bullishScore+=InpMAWeight;
   else
      bearishScore+=InpMAWeight;
   if(adxBuffer[0] > 25)
     {
      if(diPlusBuffer[0] > diMinusBuffer[0])
         bullishScore+=InpADXWeight+InpDIWeight;
      else
         bearishScore+=InpADXWeight+InpDIWeight;
     }
   if(barClose > bbMiddleBuffer[0])
      bullishScore+=InpBBWeight;
   else
      bearishScore+=InpBBWeight;
   if(rviMainBuffer[0] > rviSignalBuffer[0])
      bullishScore+=InpRVIWeight;
   else
      bearishScore+=InpRVIWeight;
   if(sarBuffer[0] < barLow)
      bullishScore+=InpSARWeight;
   else
      bearishScore+=InpSARWeight;
   if(rsiBuffer[0] > 50)
      bullishScore+=InpRSIWeight;
   else
      bearishScore+=InpRSIWeight;

   UpdateDisplay(bullishScore, bearishScore);

   bool canBuy = true, canSell = true;
   if(InpUseTrendFilter)
     {
      if(barClose < trendMaBuffer[0])
         canBuy = false;
      if(barClose > trendMaBuffer[0])
         canSell = false;
     }
   if(InpUseVolatilityFilter)
     {
      double currentATRInPoints = atrBuffer[0] / _Point;
      if(currentATRInPoints < InpMinATR || currentATRInPoints > InpMaxATR)
        {
         canBuy = false;
         canSell = false;
        }
     }
   if(InpUseTimeFilter)
     {
      MqlDateTime timeStruct;
      TimeCurrent(timeStruct);
      if(timeStruct.hour < InpStartHour || timeStruct.hour >= InpEndHour)
        {
         canBuy = false;
         canSell = false;
        }
     }

   if(bullishScore >= InpMinScore && bullishScore > bearishScore && canBuy)
      SendAlerts("STRONG BUY", bullishScore);
   else
      if(bearishScore >= InpMinScore && bearishScore > bullishScore && canSell)
         SendAlerts("STRONG SELL", bearishScore);

   if(InpAutoTradingEnabled)
     {
      if(CountOpenTrades() < InpMaxOpenTrades)
        {
         if(bullishScore >= InpMinScore && bullishScore > bearishScore && canBuy)
           {
            if(!IsTradeOpenByType(POSITION_TYPE_BUY))
               ExecuteTrade(ORDER_TYPE_BUY);
           }
         else
            if(bearishScore >= InpMinScore && bearishScore > bullishScore && canSell)
              {
               if(!IsTradeOpenByType(POSITION_TYPE_SELL))
                  ExecuteTrade(ORDER_TYPE_SELL);
              }
        }
     }
  }
//+------------------------------------------------------------------+
void SendAlerts(string signal_type, int score)
  {
   string message = _Symbol + ", " + EnumToString(_Period) + ": " + signal_type + " Signal! Score: " + (string)score;
   if(InpUsePopupAlert)
      Alert(message);
   if(InpUsePushNotification)
      SendNotification(message);
   if(InpUseEmailAlert)
      SendMail(_Symbol + " Signal Alert", message);
  }
//+------------------------------------------------------------------+
int CountOpenTrades()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         count++;
     }
   return count;
  }
//+------------------------------------------------------------------+
bool IsTradeOpenByType(long positionType)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
        {
         if(PositionGetInteger(POSITION_TYPE) == positionType)
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
// RESTORED: This function was missing in your last version
bool IsTradeOpen()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
void UpdateDisplay(int bullishScore, int bearishScore)
  {
   string signal_text="NEUTRAL / NO SIGNAL";
   if(bullishScore>=InpMinScore && bullishScore>bearishScore)
      signal_text="STRONG BUY";
   else
      if(bearishScore>=InpMinScore && bearishScore>bullishScore)
         signal_text="STRONG SELL";
   ObjectSetString(0, LABEL_L1, OBJPROP_TEXT, StringFormat("Bullish Score: %d", bullishScore));
   ObjectSetString(0, LABEL_L2, OBJPROP_TEXT, StringFormat("Bearish Score: %d", bearishScore));
   ObjectSetString(0, LABEL_L3, OBJPROP_TEXT, "--------------------");
   ObjectSetString(0, LABEL_L4, OBJPROP_TEXT, StringFormat("Signal: %s", signal_text));
  }
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE orderType)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;
   double price = 0, sl = 0, tp = 0;
   if(orderType == ORDER_TYPE_BUY)
      price = tick.ask;
   else
      price = tick.bid;
   if(InpUseAtrSLTP)
     {
      double currentATR = atrBuffer[0];
      if(orderType == ORDER_TYPE_BUY)
        {
         sl = price - (currentATR * InpAtrSLMultiplier);
         tp = price + (currentATR * InpAtrTPMultiplier);
        }
      else
        {
         sl = price + (currentATR * InpAtrSLMultiplier);
         tp = price - (currentATR * InpAtrTPMultiplier);
        }
     }
   else
     {
      if(orderType == ORDER_TYPE_BUY)
        {
         sl = price - (InpStopLoss * _Point);
         tp = price + (InpTakeProfit * _Point);
        }
      else
        {
         sl = price + (InpStopLoss * _Point);
         tp = price - (InpTakeProfit * _Point);
        }
     }
   if(sl == 0 || tp == 0)
     {
      Print("Error: SL/TP could not be calculated. Trade aborted.");
      return;
     }
   trade.SetExpertMagicNumber(InpMagicNumber);
   if(orderType == ORDER_TYPE_BUY)
      trade.Buy(InpLotSize, _Symbol, price, sl, tp, "Golden7 Buy");
   else
      if(orderType == ORDER_TYPE_SELL)
         trade.Sell(InpLotSize, _Symbol, price, sl, tp, "Golden7 Sell");
  }
//+------------------------------------------------------------------+
void ManageTrailingStop()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      long positionMagic = PositionGetInteger(POSITION_MAGIC);
      if(PositionGetSymbol(i) == _Symbol && (positionMagic == InpMagicNumber || (InpManageManualTrades && positionMagic == 0)))
        {
         ulong  ticket      = PositionGetTicket(i);
         double openPrice   = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentSL   = PositionGetDouble(POSITION_SL);
         double currentTP   = PositionGetDouble(POSITION_TP);
         long   type        = PositionGetInteger(POSITION_TYPE);
         MqlTick tick;
         SymbolInfoTick(_Symbol,tick);
         double currentPrice = (type == POSITION_TYPE_BUY) ? tick.bid : tick.ask;

         if(InpUseBreakevenPlus)
           {
            if(type == POSITION_TYPE_BUY)
              {
               double bePlusSL = openPrice + (InpBEPlusPoints * _Point);
               if(currentPrice >= openPrice + (InpBEPlusTrigger * _Point) && currentSL < bePlusSL)
                 {
                  trade.PositionModify(ticket, bePlusSL, currentTP);
                  continue;
                 }
              }
            else
              {
               double bePlusSL = openPrice - (InpBEPlusPoints * _Point);
               if(currentPrice <= openPrice - (InpBEPlusTrigger * _Point) && (currentSL > bePlusSL || currentSL == 0))
                 {
                  trade.PositionModify(ticket, bePlusSL, currentTP);
                  continue;
                 }
              }
           }
         if(InpUseTrailingStop)
           {
            double newSL = 0;
            if(type == POSITION_TYPE_BUY)
              {
               if(currentPrice > openPrice + (InpTrailStart * _Point))
                 {
                  newSL = currentPrice - (InpTrailDistance * _Point);
                  if(newSL > currentSL)
                     trade.PositionModify(ticket, newSL, currentTP);
                 }
              }
            else
              {
               if(currentPrice < openPrice - (InpTrailStart * _Point))
                 {
                  newSL = currentPrice + (InpTrailDistance * _Point);
                  if(newSL < currentSL || currentSL == 0)
                     trade.PositionModify(ticket, newSL, currentTP);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
