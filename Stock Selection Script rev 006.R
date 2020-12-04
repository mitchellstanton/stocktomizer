
# STOCK PROGRAM -----------------------------------------------------------
# Choose stocks with best position relative to last month or week close
# Choose stocks that have most decernable daily, weekly, and monthly highs and lows
# PRE-IMPORT --------------------------------------------------------------

# load packages
library(alphavantager)
library(data.table)
library(lubridate)
library(tidyverse)
library(mlr3)
library(mlr3learners)
library(mlr3measures)
library(mlr3misc)
library(openxlsx)

# SET CONSTANTS -----------------------------------------------------------

# establish timeline beginning 
years_before <- 10
# find earliest date from "y" years ago
earliest_date <- floor_date(Sys.Date() - years(years_before), unit = "year") 
# change this to TRUE if researching the night of the end of the month
EOM <- FALSE 
# markets
sp500 <- c("MMM",	"ABT",	"ABBV",	"ABMD",	"ACN",	"ATVI",	"ADBE",	"AMD",	"AAP",	"AES",	"AFL",	"A",	"APD",	"AKAM",	"ALK",	"ALB",	"ARE",	"ALXN",	"ALGN",	"ALLE",	"AGN",	"ADS",	"LNT",	"ALL",	"GOOGL",	"GOOG",	"MO",	"AMZN",	"AMCR",	"AEE",	"AAL",	"AEP",	"AXP",	"AIG",	"AMT",	"AWK",	"AMP",	"ABC",	"AME",	"AMGN",	"APH",	"ADI",	"ANSS",	"ANTM",	"AON",	"AOS",	"APA",	"AIV",	"AAPL",	"AMAT",	"APTV",	"ADM",	"ARNC",	"ANET",	"AJG",	"AIZ",	"ATO",	"T",	"ADSK",	"ADP",	"AZO",	"AVB",	"AVY",	"BKR",	"BLL",	"BAC",	"BK",	"BAX",	"BDX",	"BBY",	"BIIB",	"BLK",	"BA",	"BKNG",	"BWA",	"BXP",	"BSX",	"BMY",	"AVGO",	"BR",	"CHRW",	"COG",	"CDNS",	"CPB",	"COF",	"CPRI",	"CAH",	"KMX",	"CCL",	"CAT",	"CBOE",	"CBRE",	"CDW",	"CE",	"CNC",	"CNP",	"CTL",	"CERN",	"CF",	"SCHW",	"CHTR",	"CVX",	"CMG",	"CB",	"CHD",	"CI",	"XEC",	"CINF",	"CTAS",	"CSCO",	"C",	"CFG",	"CTXS",	"CLX",	"CME",	"CMS",	"KO",	"CTSH",	"CL",	"CMCSA",	"CMA",	"CAG",	"CXO",	"COP",	"ED",	"STZ",	"COO",	"CPRT",	"GLW",	"CTVA",	"COST",	"COTY",	"CCI",	"CSX",	"CMI",	"CVS",	"DHI",	"DHR",	"DRI",	"DVA",	"DE",	"DAL",	"XRAY",	"DVN",	"FANG",	"DLR",	"DFS",	"DISCA",	"DISCK",	"DISH",	"DG",	"DLTR",	"D",	"DOV",	"DOW",	"DTE",	"DUK",	"DRE",	"DD",	"DXC",	"ETFC",	"EMN",	"ETN",	"EBAY",	"ECL",	"EIX",	"EW",	"EA",	"EMR",	"ETR",	"EOG",	"EFX",	"EQIX",	"EQR",	"ESS",	"EL",	"EVRG",	"ES",	"RE",	"EXC",	"EXPE",	"EXPD",	"EXR",	"XOM",	"FFIV",	"FB",	"FAST",	"FRT",	"FDX",	"FIS",	"FITB",	"FE",	"FRC",	"FISV",	"FLT",	"FLIR",	"FLS",	"FMC",	"F",	"FTNT",	"FTV",	"FBHS",	"FOXA",	"FOX",	"BEN",	"FCX",	"GPS",	"GRMN",	"IT",	"GD",	"GE",	"GIS",	"GM",	"GPC",	"GILD",	"GL",	"GPN",	"GS",	"GWW",	"HRB",	"HAL",	"HBI",	"HOG",	"HIG",	"HAS",	"HCA",	"PEAK",	"HP",	"HSIC",	"HSY",	"HES",	"HPE",	"HLT",	"HFC",	"HOLX",	"HD",	"HON",	"HRL",	"HST",	"HPQ",	"HUM",	"HBAN",	"HII",	"IEX",	"IDXX",	"INFO",	"ITW",	"ILMN",	"IR",	"INTC",	"ICE",	"IBM",	"INCY",	"IP",	"IPG",	"IFF",	"INTU",	"ISRG",	"IVZ",	"IPGP",	"IQV",	"IRM",	"JKHY",	"J",	"JBHT",	"SJM",	"JNJ",	"JCI",	"JPM",	"JNPR",	"KSU",	"K",	"KEY",	"KEYS",	"KMB",	"KIM",	"KMI",	"KLAC",	"KSS",	"KHC",	"KR",	"LB",	"LHX",	"LH",	"LRCX",	"LW",	"LVS",	"LEG",	"LDOS",	"LEN",	"LLY",	"LNC",	"LIN",	"LYV",	"LKQ",	"LMT",	"L",	"LOW",	"LYB",	"MTB",	"M",	"MRO",	"MPC",	"MKTX",	"MAR",	"MMC",	"MLM",	"MAS",	"MA",	"MKC",	"MXIM",	"MCD",	"MCK",	"MDT",	"MRK",	"MET",	"MTD",	"MGM",	"MCHP",	"MU",	"MSFT",	"MAA",	"MHK",	"TAP",	"MDLZ",	"MNST",	"MCO",	"MS",	"MOS",	"MSI",	"MSCI",	"MYL",	"NDAQ",	"NOV",	"NTAP",	"NFLX",	"NWL",	"NEM",	"NWSA",	"NWS",	"NEE",	"NLSN",	"NKE",	"NI",	"NBL",	"JWN",	"NSC",	"NTRS",	"NOC",	"NLOK",	"NCLH",	"NRG",	"NUE",	"NVDA",	"NVR",	"ORLY",	"OXY",	"ODFL",	"OMC",	"OKE",	"ORCL",	"PCAR",	"PKG",	"PH",	"PAYX",	"PYPL",	"PNR",	"PBCT",	"PEP",	"PKI",	"PRGO",	"PFE",	"PM",	"PSX",	"PNW",	"PXD", "PPG",	"PPL",	"PFG",	"PG",	"PGR",	"PLD",	"PRU",	"PEG",	"PSA",	"PHM",	"PVH",	"QRVO",	"PWR",	"QCOM",	"DGX",	"RL",	"RJF",	"O",	"REG",	"REGN",	"RF",	"RSG",	"RMD",	"RHI",	"ROK",	"ROL",	"ROP",	"ROST",	"RCL",	"SPGI",	"CRM",	"SBAC",	"SLB",	"STX",	"SEE",	"SRE",	"NOW",	"SHW",	"SPG",	"SWKS",	"SLG",	"SNA",	"SO",	"LUV",	"SWK",	"SBUX",	"STT",	"STE",	"SYK",	"SIVB",	"SYF",	"SNPS",	"SYY",	"TMUS",	"TROW",	"TTWO",	"TPR",	"TGT",	"TEL",	"FTI",	"TFX",	"TXN",	"TXT",	"TMO",	"TIF",	"TJX",	"TSCO",	"TDG",	"TRV",	"TFC",	"TWTR",	"TSN",	"UDR",	"ULTA",	"USB",	"UAA",	"UA",	"UNP",	"UAL",	"UNH",	"UPS",	"URI",	"UTX",	"UHS",	"UNM",	"VFC",	"VLO",	"VAR",	"VTR",	"VRSN",	"VRSK",	"VZ",	"VRTX",	"VIAC",	"V",	"VNO",	"VMC",	"WRB",	"WAB",	"WMT",	"WBA",	"DIS",	"WM",	"WAT",	"WEC",	"WCG",	"WFC",	"WELL",	"WDC",	"WU",	"WRK",	"WY",	"WHR",	"WMB",	"WLTW",	"WYNN",	"XEL",	"XRX",	"XLNX",	"XYL",	"YUM",	"ZBRA",	"ZBH",	"ZION",	"ZTS")
sp400 <- c("AAN",	"ACHC",	"ACIW",	"ADNT",	"ATGE",	"ACM",	"ACC",	"AEO",	"AFG",	"AGCO",	"ALE",	"ALEX",	"AMED",	"AM",	"APY",	"ATI",	"AMCX",	"AN",	"ARW",	"ASB",	"ASGN",	"ASH",	"ATO",	"ATR",	"AVNS",	"AVT",	"AYI",	"AAXN",	"BBBY",	"BC",	"BCO",	"BDC",	"BIO",	"BKH",	"BLKB",	"BOH",	"BRO",	"BXS",	"BYD",	"BHF",	"BRX",	"CABO",	"CZR",	"CAKE",	"CAR",	"CACI",	"CASY",	"CATY",	"CFX",	"CBSH",	"CBT",	"CC",	"CDK",	"CFR",	"CGNX",	"CHE",	"CHDN",	"CHK",	"CIEN",	"CLB",	"CLGX",	"CLH",	"CLI",	"CMC",	"CMD",	"CMP",	"CNK",	"CNO",	"COHR",	"CONE",	"COR",	"CPT",	"CR",	"CREE",	"CRI",	"CRL",	"CRS",	"CRUS",	"CNX",	"CSL",	"CTLT",	"CUZ",	"CVLT",	"CXW",	"CVET",	"CW",	"CBRL",	"CY",	"DAN",	"DCI",	"DDS",	"DECK",	"DEI",	"DKS",	"DLPH",	"DLX",	"DNKN",	"DNOW",	"DPZ",	"DY",	"EAT",	"EGP",	"EHC",	"EME",	"ENR",	"ENS",	"EPC",	"EPR",	"EQT",	"ERI",	"ETRN",	"ETSY",	"EV",	"EVR",	"EWBC",	"EXEL",	"EXP",	"FAF",	"FDS",	"FCFS",	"FFIN",	"FHN",	"FICO",	"FII",	"FIVE",	"FLO",	"FLR",	"FR",	"FNB",	"FSLR",	"FL",	"FULT",	"GATX",	"GEF",	"GEO",	"GGG",	"GHC",	"GME",	"GMED",	"GNTX",	"GNW",	"GT",	"GVA",	"GDOT",	"GRUB",	"GWR",	"HAE",	"HAIN",	"HWC",	"HCSG",	"HE",	"HELE",	"HIW",	"HNI",	"HOMB",	"HPT",	"HQY",	"HR",	"HRC",	"HUBB",	"ICUI",	"IDA",	"IIVI",	"NGVT",	"NSP",	"IART",	"IBKR",	"IBOC",	"IDCC",	"INGR",	"INT",	"ITT",	"JACK",	"JBGS",	"JBL",	"JHG",	"JEF",	"JBLU",	"JCOM",	"JLL",	"KAR",	"KBH",	"KBR",	"KEX",	"KMPR",	"KMT",	"KNX",	"KRC",	"LAMR",	"LANC",	"LGND",	"LECO",	"LFUS",	"LII",	"LITE",	"LIVN",	"RAMP",	"LM",	"LOGM",	"LPT",	"LPX",	"LSI",	"LSTR",	"LYV",	"MAN",	"MANH",	"MASI",	"MCY",	"MD",	"MDP",	"MDRX",	"MDSO",	"MDU",	"MKSI",	"MLHR",	"MMS",	"MOH",	"MPW",	"MRCY",	"MPWR",	"MSA",	"MSM",	"MTDR",	"MAT",	"MTX",	"MTZ",	"MUR",	"MUSA",	"NATI",	"NAVI",	"NCR",	"NDSN",	"NEU",	"NFG",	"NJR",	"NNN",	"NKTR",	"NTCT",	"NUS",	"NUVA",	"NVT",	"NWE",	"NYCB",	"NYT",	"OAS",	"ODFL",	"ODP",	"OFC",	"OGE",	"OGS",	"OHI",	"OII",	"OLED",	"OLLI",	"OLN",	"OI",	"ORI",	"OSK",	"OC",	"OZK",	"PACW",	"PK",	"PBF",	"PB",	"PBH",	"PCH",	"PDCO",	"PEB",	"PENN",	"PEN",	"PPC",	"PII",	"PLT",	"PNFP",	"PNM",	"POL",	"POOL",	"POST",	"PRAH",	"PSB",	"PRI",	"PTC",	"PTEN",	"PZZA",	"R",	"RBC",	"RGA",	"RGEN",	"RGLD",	"RIG",	"RNR",	"ROL",	"RPM",	"RS",	"RYN",	"SABR",	"SAFM",	"SAIC",	"SAM",	"SBH",	"SBNY",	"SBRA",	"SIGI",	"SMTC",	"SCI",	"SEIC",	"SF",	"SFM",	"SGMS",	"SIX",	"SKT",	"SKX",	"SLAB",	"SLGN",	"SLM",	"SMG",	"SNH",	"SNV",	"SNX",	"SEDG",	"SON",	"SRC",	"STE",	"STL",	"SRCL",	"STLD",	"SWN",	"SWX",	"SXT",	"SYNA",	"SYNH",	"TTEK",	"TCBI",	"TCO",	"TDC",	"TDS",	"TDY",	"TECD",	"TECH",	"TER",	"TEX",	"TGNA",	"THC",	"THG",	"THO",	"THS",	"TKR",	"TOL",	"TPH",	"TPX",	"TR",	"TREE",	"TREX",	"TRMB",	"TRMK",	"TRN",	"TTC",	"TXRH",	"TYL",	"UBSI",	"UE",	"UFS",	"UGI",	"UMBF",	"UMPQ",	"UNFI",	"UTHR",	"UNIT",	"URBN",	"VAC",	"VC",	"VLY",	"VMI",	"VVV",	"VSAT",	"VSH",	"WRB",	"WAFD",	"WBS",	"WEN",	"WERN",	"WEX",	"WOR",	"WPX",	"WRI",	"WSM",	"WSO",	"WST",	"WTFC",	"WTR",	"WW",	"WWD",	"WWE",	"WYND",	"X",	"Y",	"XPO",	"YELP",	"ZBRA")
# change this to change market
index_choice <- sp500 
# model threshold
thresh <- 0.15

# build the ticker list
# change this there is a subscription wall
N <- 100 # number of stocks to get data for
# change this for system sleep time to speed up or slow down import
sleep <- 30 
# assign random seed number
s <- floor(as.numeric(Sys.Date()))
set.seed(s+10)
index_choice_setlist <- sample(index_choice, N)

# IMPORT ------------------------------------------------------------------

# iteration: import data
monthly_data <- list()
for (i in seq_along(index_choice_setlist)) {
  # load api key
  av_api_key("QNFRUV3KCUNEEMVN")
  
  # print ticker
  print(index_choice_setlist[[i]])
  
  # import data
  monthly_raw_data <- av_get(symbol = index_choice_setlist[[i]], av_fun = "TIME_SERIES_MONTHLY_ADJUSTED", outputsize = "full")
  
  # clean, tidy, transform 001
  dat_raw <- monthly_raw_data %>% 
    filter(timestamp >= earliest_date) %>% 
    mutate(Ticker = index_choice_setlist[[i]],
           Prev_Close = dplyr::lag(adjusted_close),
           `%Change` = ((adjusted_close - Prev_Close)/Prev_Close)*100,
           adj_factor = adjusted_close/close,
           Low = low*adj_factor,
           High = high*adj_factor,
           `%up` = ((High - Prev_Close)/Prev_Close)*100,
           `%down` = ((Low - Prev_Close)/Prev_Close)*100,
           `%up-down Range` = `%up` - `%down`,
           `%up Percentile` = ecdf(`%up`)(`%Change`),
           `%down Percentile` = ecdf(`%down`)(`%Change`),
           `%up-down Range Percentile` = ecdf(`%up-down Range`)(`%up-down Range`)) %>%
    rename(Date = timestamp) %>% 
    drop_na() 
  
  # clean, tidy, transform 002
  dat_x <- dat_raw %>% 
    select(`%up`, `%down`) %>% 
    pivot_longer(cols = `%up`:`%down`, names_to = "Direction", values_to = "Percent") %>% 
    mutate(Direction = factor(Direction, levels = c("%up", "%down")))
  
  # MODEL + VISUALIZE
  # ML
  task <- TaskClassif$new(id = "dat", backend = dat_x, target = "Direction", positive = "%up")
  learner <- mlr_learners$get("classif.lda")
  resampling <- rsmp("repeated_cv", folds = 10L, repeats = 10)
  resampling$instantiate(task)
  rr <- resample(task, learner, resampling, store_models = TRUE)
  # Positioning
  Low <- dat_raw %>% filter(Date == max(Date)) %>% pull("%down Percentile")
  
  # Result + format
  monthly_data[[i]] <- tibble(avg_performance = rr$aggregate(msr("classif.ce")), Ticker = index_choice_setlist[[i]], Low_Percentile_Current_Price = Low)
  
  # wait before next iteration
  Sys.sleep(sleep + rnorm(1, mean = 0, sd = 1))
}

# CLEAN, TIDY, TRANSFORM --------------------------------------------------

# data: aggregated data
monthly_history <- rbindlist(monthly_data) %>% arrange(Low_Percentile_Current_Price)

# MODEL + VISUALIZE -------------------------------------------------------

# EXPORT ------------------------------------------------------------------

# data: tickers with minimal %up or %down deviation2
all_choices <- monthly_history %>% 
  filter(avg_performance <= thresh) %>% 
  filter(Low_Percentile_Current_Price <= thresh) %>% 
  mutate(Time_Series = "Monthly")

openxlsx::write.xlsx(all_choices, file = "choices.xlsx")
