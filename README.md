# Pitching

Mainplot

Looking at a single season for a pitcher, which stats from that season give us the most information about how much longer his career will last?
	
---

Based on single season data from the last 15 years for currently inactive pitchers, who pitched at least 100 innings in that season. Y values represent the coefficients obtained from doing simple linear regression on the z score for each of the stats against the years remaining in a pitchers career

Note that the graph refrences an "improvement" in each stat (meaning ERA down, K% up, etc). If we measure in terms of *increasing* each stat the graph looks like this

sd chart

Standard deviation was used instead of real values to give us a better idea of how "exceptional" a pitcher needs to be to extend his career. Remember that 1 std dev above average is the 85th percentile of pitchers and 2 std dev is the 97th percentile

For a better idea of this relationship in terms of real values take a look at these scatter plots:

---

Predicting career lengths for currently active pitchers

A surprisingly accurate model for career length can be made using only three predictors: Age, Innings Pitched, and W-L%

The model trained here with these three predictors has an RMSE of 2.45 years (think of this as average error of prediction), and actually gets worse when you add in seemingly important stats like ERA. This is probably beacause there is a high correlation between W-L% and ERA, and any new information added by it will likely contain a lot of noise.

Here are some predictions made by the model based of of performances by pitchers this season:

Who will retire the soonest?
Who will be around the longest?
Who will be the oldest?

---

Data taken from baseball-reference

Analysis/Visualizations done with R using the packages:  
dplyr  
magrittr  
ggplot2  
stringr  

I would have liked to include more detailed data in the model such as avg fastaball speed and pitch selection but this information is not widely available past 2016. If anyone knows good sources for this sort of data please let me know!
