setwd("~/Projects/PitchingCareers")

library(dplyr)
library(magrittr)
library(ggplot2)
library(stringr)

# Import single season and player data
pitchers.raw <- read.csv('pitchers.csv')
seasons.raw  <- read.csv('seasons.csv')

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

# Summarize descriptive stats for data
df$ERA   %>% mean # 4.310249
df$Age   %>% mean # 29.50523
df$IP    %>% mean # 169.5165
df$Kper  %>% mean # 16.707
df$BBper %>% mean # 7.561706
df$W.L.  %>% mean # 0.5060467
df$WHIP  %>% mean # 1.354138
df$PIP   %>% mean # 16.06522
df$Years.Left %>% mean # 4.422365

df$ERA   %>% sd #  0.9090519
df$Age   %>% sd #  4.602275
df$IP    %>% sd # 37.81397
df$Kper  %>% sd #  4.168754
df$BBper %>% sd #  2.106117
df$W.L.  %>% sd #  0.1300825
df$WHIP  %>% sd #  0.1610054
df$PIP   %>% sd #  0.9343541
df$Years.Left %>% sd # 2.875749

# Graph smooth scatter plot for each
scatter.smooth(x = df$Age,   y = df$Years.Left, xlab = 'Age'   , ylab = 'Years Left')
scatter.smooth(x = df$IP,    y = df$Years.Left, xlab = 'IP'    , ylab = 'Years Left')
scatter.smooth(x = df$W.L.,  y = df$Years.Left, xlab = 'W-L%'  , ylab = 'Years Left')
scatter.smooth(x = df$Kper,  y = df$Years.Left, xlab = 'K%'    , ylab = 'Years Left')
scatter.smooth(x = df$ERA,   y = df$Years.Left, xlab = 'ERA'   , ylab = 'Years Left')
scatter.smooth(x = df$WHIP,  y = df$Years.Left, xlab = 'WHIP'  , ylab = 'Years Left')
scatter.smooth(x = df$PIP,   y = df$Years.Left, xlab = 'Pit/IP', ylab = 'Years Left')
scatter.smooth(x = df$BBper, y = df$Years.Left, xlab = 'BB%'   , ylab = 'Years Left')

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
lm(data = df, Years.Left ~ BBper.z) %>% summary #  0.02244 not significant
lm(data = df, Years.Left ~ W.L.z)   %>% summary #  0.58836
lm(data = df, Years.Left ~ WHIP.z)  %>% summary # -0.40593
lm(data = df, Years.Left ~ PIP.z)   %>% summary # -0.06299 not significant

# Graph simple regression coefficients
vars     <- c('ERA', 'Age', 'IP', 'K%', 'BB%', 'W-L%', 'WHIP', 'Pit/IP')
coef     <- c(-0.47976, -1.23009, 0.62475, 0.48724, 0.02244, 0.58836, -0.40593, -0.06299)
coef.abs <- coef %>% abs
coef.df  <- data.frame(vars, coef, coef.abs)

# Absolute Value plot
ggplot(coef.df) +
  geom_bar(aes(x = reorder(vars, abs(coef)), y = abs(coef), fill = vars), stat = 'identity') +
  ylab('Change (in years)') + 
  labs(title = 'Which stats best predict the length of a pitching career?', 
       subtitle = 'Change in expected career length resulting from a 1 std dev change in each stat') +
  theme(legend.position = 'none', 
        axis.title.x = element_blank(),
        axis.text.x = element_text(vjust = 9, size = 10, face = 'bold'),
        plot.title = element_text(size=14, face = 'bold'),
        plot.subtitle = element_text(size=8)
        )

# Regular Plot
ggplot(coef.df) +
  geom_bar(aes(x = reorder(vars, coef), y = coef, fill = vars), stat = 'identity') +
  ylab('Change (in years)') + 
  labs(subtitle = 'Change in expected career length resulting from a 1 std dev increase in each stat') +
  theme(legend.position = 'none', 
        axis.title.x = element_blank(),
        axis.text.x = element_text(vjust = 95, size = 10, face = 'bold')
        )

# Build linear regression model
# Split train/test
set.seed(101)
sample <- sample(1:nrow(df), size = .7 * nrow(df))

train.df <- df[sample,]
test.df  <- df[-sample,]

# Select features 
df %>% names # "ERA" "Age" "IP" "Kper" "BBper" "W.L." "WHIP" "PIP" These are the features of interest

# A predictive model will almost certainly include age so our feature selection will start there
# Use forward stepwise selection to build models by adding features that improve the training RSS
lm(data = train.df, Years.Left ~ Age) %>% deviance # 5919.682

lm(data = train.df, Years.Left ~ Age + ERA)   %>% deviance # 5742.34
lm(data = train.df, Years.Left ~ Age + IP)    %>% deviance # 5360.736 *
lm(data = train.df, Years.Left ~ Age + Kper)  %>% deviance # 5818.525
lm(data = train.df, Years.Left ~ Age + BBper) %>% deviance # 5836.431
lm(data = train.df, Years.Left ~ Age + W.L.)  %>% deviance # 5624.958
lm(data = train.df, Years.Left ~ Age + WHIP)  %>% deviance # 5732.84
lm(data = train.df, Years.Left ~ Age + PIP)   %>% deviance # 5863.011

lm(data = train.df, Years.Left ~ Age + IP + ERA)   %>% deviance # 5348.715
lm(data = train.df, Years.Left ~ Age + IP + Kper)  %>% deviance # 5337.066
lm(data = train.df, Years.Left ~ Age + IP + BBper) %>% deviance # 5352.203
lm(data = train.df, Years.Left ~ Age + IP + W.L.)  %>% deviance # 5273.627 *
lm(data = train.df, Years.Left ~ Age + IP + WHIP)  %>% deviance # 5341.58
lm(data = train.df, Years.Left ~ Age + IP + PIP)   %>% deviance # 5360.16

lm(data = train.df, Years.Left ~ Age + IP + W.L. + ERA)   %>% deviance # 5268.9
lm(data = train.df, Years.Left ~ Age + IP + W.L. + Kper)  %>% deviance # 5269.331
lm(data = train.df, Years.Left ~ Age + IP + W.L. + BBper) %>% deviance # 5269.225
lm(data = train.df, Years.Left ~ Age + IP + W.L. + WHIP)  %>% deviance # 5273.62
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP)   %>% deviance # 5265.637 * 

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + ERA)   %>% deviance # 5263.874
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + Kper)  %>% deviance # 5263.358
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper) %>% deviance # 5232.855 * 
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + WHIP)  %>% deviance # 5263.164

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA)   %>% deviance # 5231.391 *
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + Kper)  %>% deviance # 5231.724
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + WHIP)  %>% deviance # 5232.826

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA + Kper)  %>% deviance # 5227.741 *
lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA + WHIP)  %>% deviance # 5228.941

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA + Kper + WHIP) %>% deviance # 5227.442

# Among the 7 models built by each step of the selection, choose the one with the best RSS against the test data
lm(data = train.df, Years.Left ~ Age + IP) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2306.41

lm(data = train.df, Years.Left ~ Age + IP + W.L.) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2247.41 *

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2247.623

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper ) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2255.452

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA ) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2254.064

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA + Kper) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2249.706

lm(data = train.df, Years.Left ~ Age + IP + W.L. + PIP + BBper + ERA + Kper + WHIP) %>% 
  predict.lm(newdata = test.df) %>% subtract(test.df$Years.Left) %>% raise_to_power(2) %>% sum # 2248.417

# What is the RMSE on the test data? - 2.454634
lm(data = train.df, Years.Left ~ Age + IP + W.L.) %>% 
  predict.lm(newdata = test.df) %>% 
  subtract(test.df$Years.Left) %>% 
  raise_to_power(2) %>% 
  sum %>% 
  divide_by(nrow(test.df)) %>% 
  raise_to_power(.5)

# The best model here includes only the features Age, IP, and W.L.
lm <- lm(data = df, Years.Left ~ Age + IP + W.L.) 
lm %>% summary
"
Residuals:
Min     1Q      Median   3Q      Max 
-6.9335 -1.7924 -0.3129  1.5352  9.6622 

Coefficients:
  Estimate   Std. Error   t value   Pr(>|t|)    
(Intercept)    8.480935   0.557933  15.201  < 2e-16 ***
  Age         -0.283076   0.015293 -18.510  < 2e-16 ***
  IP           0.016933   0.001991   8.506  < 2e-16 ***
  W.L.         2.812543   0.575064   4.891 1.14e-06 ***
"

# Make predictions for current players
# Import and format data for 2019 pitching seasons
current.raw <- read.csv('current.csv')
current <- current.raw %>% select(c('Player', 'Year', 'ERA', 'Age', 'IP', 'BB', 'H', 'K.', 'BB.', 'W.L.', 'Pit'))

names(current)[names(current) == 'K.']  <- 'Kper'
names(current)[names(current) == 'BB.'] <- 'BBper'
current$Kper  <- current$Kper  %>% str_replace('%', '') %>% as.numeric
current$BBper <- current$BBper %>% str_replace('%', '') %>% as.numeric
current$IP <- (current$IP %>% round) + (current$IP %% 1 * (10/3))

current <- data.frame(current, lm %>% predict.lm(newdata = current)) 

names(current)[ncol(current)] <- 'Years.Left.p'
current$Final.Age.p <- current$Age + current$Years.Left.p

# Who has the most years left? Who will be the oldest?
current[order(current$Years.Left.p),] %>% select(c('Player', 'Age', 'Years.Left.p', 'Final.Age.p')) %>% head(5)
current[order(current$Years.Left.p),] %>% select(c('Player', 'Age', 'Years.Left.p', 'Final.Age.p')) %>% tail(5)

current[order(current$Age),] %>% select(c('Player', 'Age', 'Years.Left.p', 'Final.Age.p')) %>% tail(5)
