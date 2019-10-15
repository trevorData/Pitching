setwd("~/Projects/PitchingCareers")

library(dplyr)
library(ggplot2)
library(stringr)

# Import single season and player data
pitchers.raw <- read.csv('pitchers.csv')
seasons.raw  <- read.csv('seasons.csv')

pitchers.raw %>% colnames
# "Player" "SO"     "IP"     "From"   "To"     "Age"    "G"      "GS"     "CG"     "SHO"    "GF"     "W"      "L"      "W.L."   "SV"     "H"      "R"      "ER"     "BB"     "ERA"   
# "FIP"    "K."     "BB."    "ERA."   "BAbip"  "HR"     "BF"     "IBB"    "HBP"    "BK"     "WP"     "Tm" 

seasons.raw %>% colnames
# "Player" "SO"     "IP"     "Year"   "Age"    "Tm"     "Lg"     "G"      "GS"     "CG"     "SHO"    "GF"     "W"      "L"      "W.L."   "SV"     "H"      "R"      "ER"     "BB"    
# "ERA"    "FIP"    "K."     "BB."    "ERA."   "BAbip"  "HR"     "BF"     "AB"     "X2B"    "X3B"    "IBB"    "HBP"    "SH"     "SF"     "GDP"    "SB"     "CS"     "PO"     "BK"    
# "WP"     "BA"     "OBP"    "SLG"    "OPS"    "OPS."   "Pit"    "Str"

pitchers <- pitchers.raw %>% select(c('Player', 'To'))
seasons  <- seasons.raw  %>% select(c('Player', 'Year', 'ERA', 'Age', 'IP', 'BB', 'H', 'K.', 'BB.', 'W.L.', 'Pit'))

# Rename percentage columns
names(seasons)[names(seasons) == 'K.']  <- 'Kper'
names(seasons)[names(seasons) == 'BB.'] <- 'BBper'

seasons$Kper  <- seasons$Kper  %>% str_replace('%', '') %>% as.numeric
seasons$BBper <- seasons$BBper %>% str_replace('%', '') %>% as.numeric

# Adjust Innings Pitched to be a real number
seasons$IP <- (seasons$IP %>% round) + (seasons$IP %% 1 * (10/3))

# Calculate additional columns
seasons$WHIP <- (seasons$BB + seasons$H)/seasons$IP
seasons$PIP  <- seasons$Pit/seasons$IP

# Merge data
df <- merge(x=seasons, y=pitchers, 
            by='Player', 
            all.x=TRUE
            )

# Calculate the number of years remaining
df$Years.Left <- df$To - df$Year

# Standardize the independent variables
df$ERA.z   <- df$ERA   %>% scale
df$Age.z   <- df$Age   %>% scale
df$IP.z    <- df$IP    %>% scale
df$Kper.z  <- df$Kper  %>% scale
df$BBper.z <- df$BBper %>% scale
df$W.L.z   <- df$W.L.  %>% scale
df$WHIP.z  <- df$WHIP  %>% scale
df$PIP.z   <- df$PIP   %>% scale

# Perform simple linear regression on each of the variables of interest
lm(data = df, Years.Left ~ ERA.z)   %>% summary # -0.47976
lm(data = df, Years.Left ~ Age.z)   %>% summary # -1.23009
lm(data = df, Years.Left ~ IP.z)    %>% summary #  0.62475
lm(data = df, Years.Left ~ Kper.z)  %>% summary #  0.48724
lm(data = df, Years.Left ~ BBper.z) %>% summary #  0.02244 low significance
lm(data = df, Years.Left ~ W.L.z)   %>% summary #  0.58836
lm(data = df, Years.Left ~ WHIP.z)  %>% summary # -0.40593
lm(data = df, Years.Left ~ PIP.z)   %>% summary # -0.06299 low significance

# Graph simple regression coefficients
vars <- c('ERA', 'Age', 'IP', 'K%', 'BB%', 'W-L%', 'WHIP', 'Pit/IP')
coef <- c(-0.47976, -1.23009, 0.62475, 0.48724, 0.02244, 0.58836, -0.40593, -0.06299)
coef.df <- data.frame(vars, coef)

ggplot(coef.df) +
  geom_bar(aes(x = reorder(vars, coef), y = coef, fill = vars), stat = 'identity') + 
  labs(title = 'How much would a 1 std dev increase in each stat affect the length of a pitching career?') +
  ylab('Change in years') + 
  theme(legend.position = 'none', 
        axis.title.x = element_blank(),
        axis.text.x = element_text(vjust = 96, size = 10, face = 'bold'),
        plot.title = element_text(size=11)
        )
  








# Graph smooth scatter plot for each

# Build a multiple linear regression model
  # Split into test/train
  # feature selection
  # Predict for some prospects - choose some that are "average" among this data set









